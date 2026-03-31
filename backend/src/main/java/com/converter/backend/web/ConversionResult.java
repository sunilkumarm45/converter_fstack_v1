package com.converter.backend.web;

public class ConversionResult {

    private final String sourceCurrency;
    private final String targetCurrency;
    private final double originalAmount;
    private final double convertedAmount;
    private final double exchangeRate;

    public ConversionResult(
            String sourceCurrency,
            String targetCurrency,
            double originalAmount,
            double convertedAmount,
            double exchangeRate) {
        this.sourceCurrency = sourceCurrency;
        this.targetCurrency = targetCurrency;
        this.originalAmount = originalAmount;
        this.convertedAmount = convertedAmount;
        this.exchangeRate = exchangeRate;
    }

    public String getSourceCurrency() {
        return sourceCurrency;
    }

    public String getTargetCurrency() {
        return targetCurrency;
    }

    public double getOriginalAmount() {
        return originalAmount;
    }

    public double getConvertedAmount() {
        return convertedAmount;
    }

    public double getExchangeRate() {
        return exchangeRate;
    }
}

