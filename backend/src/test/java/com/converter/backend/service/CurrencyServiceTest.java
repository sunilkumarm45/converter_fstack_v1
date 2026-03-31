package com.converter.backend.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.web.reactive.function.client.WebClient;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.simple.SimpleMeterRegistry;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CurrencyServiceTest {

    @Mock
    private WebClient.Builder webClientBuilder;

    private CurrencyService currencyService;
    private MeterRegistry meterRegistry;

    @BeforeEach
    void setUp() {
        meterRegistry = new SimpleMeterRegistry();
        when(webClientBuilder.baseUrl(any())).thenReturn(webClientBuilder);
        when(webClientBuilder.build()).thenReturn(null);
        currencyService = new CurrencyService(webClientBuilder, meterRegistry, "https://swop.cx/rest");
    }

    @Test
    void shouldReturnOneForSameCurrency() {
        BigDecimal rate = currencyService.getExchangeRate("USD", "USD");
        assertThat(rate).isEqualByComparingTo(BigDecimal.ONE);
    }

    @Test
    void shouldHandleLowercaseCurrencyCodes() {
        BigDecimal rate = currencyService.getExchangeRate("usd", "eur");
        assertThat(rate).isNotNull();
        assertThat(rate).isGreaterThan(BigDecimal.ZERO);
    }

    @Test
    void shouldConvertUsingFallbackRates() {
        BigDecimal rate = currencyService.getExchangeRate("USD", "EUR");
        assertThat(rate).isNotNull();
        assertThat(rate).isGreaterThan(BigDecimal.ZERO);
        assertThat(rate).isLessThan(BigDecimal.ONE);
    }

    @Test
    void shouldConvertAmount() {
        BigDecimal converted = currencyService.convert("USD", "EUR", new BigDecimal("100"));
        assertThat(converted).isNotNull();
        assertThat(converted.scale()).isEqualTo(2);
        assertThat(converted).isGreaterThan(BigDecimal.ZERO);
    }

    @Test
    void shouldHandleZeroAmount() {
        BigDecimal converted = currencyService.convert("USD", "EUR", BigDecimal.ZERO);
        assertThat(converted).isEqualByComparingTo(BigDecimal.ZERO);
    }

    @Test
    void shouldRejectNullCurrency() {
        assertThatThrownBy(() -> currencyService.getExchangeRate(null, "EUR"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Currency code must not be blank");
    }

    @Test
    void shouldRejectBlankCurrency() {
        assertThatThrownBy(() -> currencyService.getExchangeRate("USD", "  "))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Currency code must not be blank");
    }

    @Test
    void shouldRejectUnsupportedCurrency() {
        assertThatThrownBy(() -> currencyService.getExchangeRate("USD", "XYZ"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Unsupported currency pair");
    }

    @Test
    void shouldHandleJPYConversion() {
        BigDecimal rate = currencyService.getExchangeRate("USD", "JPY");
        assertThat(rate).isGreaterThan(BigDecimal.ONE);
    }

    @Test
    void shouldConvertFromEURtoGBP() {
        BigDecimal converted = currencyService.convert("EUR", "GBP", new BigDecimal("100"));
        assertThat(converted).isNotNull();
        assertThat(converted).isGreaterThan(BigDecimal.ZERO);
    }

    // TODO: Add tests for getAvailableCurrencies() when method is implemented
    // @Test
    // void shouldReturnFallbackCurrenciesList() {
    //     List<Currency> currencies = currencyService.getAvailableCurrencies();
    //     
    //     assertThat(currencies).isNotNull();
    //     assertThat(currencies).isNotEmpty();
    //     assertThat(currencies).anyMatch(c -> c.getCode().equals("USD"));
    //     assertThat(currencies).anyMatch(c -> c.getCode().equals("EUR"));
    //     assertThat(currencies).anyMatch(c -> c.getCode().equals("GBP"));
    //     assertThat(currencies).anyMatch(c -> c.getCode().equals("JPY"));
    // }

    // @Test
    // void shouldReturnCurrenciesWithNamesAndCodes() {
    //     List<Currency> currencies = currencyService.getAvailableCurrencies();
    //     
    //     assertThat(currencies).allMatch(c -> c.getCode() != null && !c.getCode().isBlank());
    //     assertThat(currencies).allMatch(c -> c.getName() != null && !c.getName().isBlank());
    // }
}

