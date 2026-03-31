package com.converter.backend.web;

import com.converter.backend.service.CurrencyService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.graphql.GraphQlTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.graphql.test.tester.GraphQlTester;

import java.math.BigDecimal;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@GraphQlTest(ConversionGraphQlController.class)
class ConversionlControllerTest {

    @Autowired
    private GraphQlTester graphQlTester;

    @MockBean
    private CurrencyService currencyService;

    @Test
    void shouldConvertCurrency() {
        when(currencyService.getExchangeRate("USD", "EUR"))
                .thenReturn(new BigDecimal("0.92"));
        when(currencyService.convert(eq("USD"), eq("EUR"), any(BigDecimal.class)))
                .thenReturn(new BigDecimal("92.00"));

        graphQlTester.document("""
                query {
                    convert(sourceCurrency: "USD", targetCurrency: "EUR", amount: 100) {
                        sourceCurrency
                        targetCurrency
                        originalAmount
                        convertedAmount
                        exchangeRate
                    }
                }
                """)
                .execute()
                .path("convert")
                .entity(ConversionResult.class)
                .satisfies(result -> {
                    assert result.getSourceCurrency().equals("USD");
                    assert result.getTargetCurrency().equals("EUR");
                    assert result.getOriginalAmount() == 100.0;
                    assert result.getConvertedAmount() == 92.0;
                    assert result.getExchangeRate() == 0.92;
                });
    }

    @Test
    void shouldHandleNegativeAmount() {
        // Negative amounts should be rejected by validation
        graphQlTester.document("""
                query {
                    convert(sourceCurrency: "USD", targetCurrency: "EUR", amount: -100) {
                        convertedAmount
                    }
                }
                """)
                .execute()
                .errors()
                .expect(error -> error.getMessage().contains("Amount must be positive"));
    }

    @Test
    void shouldHandleDifferentCurrencyPairs() {
        when(currencyService.getExchangeRate("GBP", "JPY"))
                .thenReturn(new BigDecimal("192.50"));
        when(currencyService.convert(eq("GBP"), eq("JPY"), any(BigDecimal.class)))
                .thenReturn(new BigDecimal("9625.00"));

        graphQlTester.document("""
                query {
                    convert(sourceCurrency: "GBP", targetCurrency: "JPY", amount: 50) {
                        sourceCurrency
                        targetCurrency
                        convertedAmount
                        exchangeRate
                    }
                }
                """)
                .execute()
                .path("convert")
                .entity(ConversionResult.class)
                .satisfies(result -> {
                    assert result.getSourceCurrency().equals("GBP");
                    assert result.getTargetCurrency().equals("JPY");
                });
    }
}
