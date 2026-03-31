package com.converter.backend.web;

import com.converter.backend.service.CurrencyService;
import java.math.BigDecimal;
import java.util.List;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Positive;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;

@Controller
@Validated
public class ConversionGraphQlController {

    private final CurrencyService currencyService;

    public ConversionGraphQlController(CurrencyService currencyService) {
        this.currencyService = currencyService;
    }

    @QueryMapping
    public ConversionResult convert(
            @Argument @NotBlank(message = "Source currency is required") String sourceCurrency,
            @Argument @NotBlank(message = "Target currency is required") String targetCurrency,
            @Argument @NotNull(message = "Amount is required") @Positive(message = "Amount must be positive") Double amount) {
        BigDecimal originalAmount = BigDecimal.valueOf(amount);
        BigDecimal exchangeRate = currencyService.getExchangeRate(sourceCurrency, targetCurrency);
        BigDecimal convertedAmount = currencyService.convert(sourceCurrency, targetCurrency, originalAmount);

        return new ConversionResult(
                sourceCurrency,
                targetCurrency,
                originalAmount.doubleValue(),
                convertedAmount.doubleValue(),
                exchangeRate.doubleValue());
    }

    @QueryMapping
    public List<String> currencies() {
        return currencyService.getAvailableCurrencies();
    }
}
