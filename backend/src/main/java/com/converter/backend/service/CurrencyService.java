package com.converter.backend.service;

import com.fasterxml.jackson.databind.JsonNode;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.util.Locale;
import java.util.Map;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.stream.Collectors;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Value;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import javax.annotation.PostConstruct;

@Service
public class CurrencyService {

    private static final Logger logger = LoggerFactory.getLogger(CurrencyService.class);
    private static final String BASE_CURRENCY = "EUR"; // SWOP free tier uses EUR as base

    private final WebClient swopClient;
    private final MeterRegistry meterRegistry;
    private final Map<String, BigDecimal> eurRates = new HashMap<>();

    public CurrencyService(WebClient.Builder builder, 
                          MeterRegistry meterRegistry,
                          @Value("${swop.api.base-url}") String swopApiBaseUrl) {
        this.swopClient = builder.baseUrl(swopApiBaseUrl).build();
        this.meterRegistry = meterRegistry;
    }

    @PostConstruct
    public void init() {
        logger.info("Initializing CurrencyService and loading exchange rates from SWOP...");
        loadEurRates();
    }

    @Cacheable(value = "rates", key = "(#source ?: '').toUpperCase() + ':' + (#target ?: '').toUpperCase()")
    public BigDecimal getExchangeRate(String source, String target) {
        String normalizedSource = normalizeCurrency(source);
        String normalizedTarget = normalizeCurrency(target);

        if (normalizedSource.equals(normalizedTarget)) {
            return BigDecimal.ONE;
        }

        BigDecimal remoteRate = fetchRemoteRate(normalizedSource, normalizedTarget);
        if (remoteRate != null) {
            return remoteRate;
        }

        return getFallbackRate(normalizedSource, normalizedTarget);
    }

    public BigDecimal convert(String source, String target, BigDecimal amount) {
        BigDecimal normalizedAmount = amount == null ? BigDecimal.ZERO : amount;
        return normalizedAmount.multiply(getExchangeRate(source, target)).setScale(2, RoundingMode.HALF_UP);
    }

    /**
     * Get list of available currencies from cached SWOP data.
     * Returns all currencies for which we have exchange rates, including the base currency (EUR).
     */
    @Cacheable(value = "currencies")
    public List<String> getAvailableCurrencies() {
        // If EUR rates are loaded from SWOP, return those currencies
        if (!eurRates.isEmpty()) {
            List<String> currencies = new ArrayList<>(eurRates.keySet());
            // Add base currency (EUR) if not already present
            if (!currencies.contains(BASE_CURRENCY)) {
                currencies.add(BASE_CURRENCY);
            }
            currencies.sort(String::compareTo);
            logger.debug("Returning {} available currencies from SWOP cache", currencies.size());
            return currencies;
        }

        // Fallback: Return currencies with mock rates available
        logger.debug("SWOP rates not available, returning default currency list");
        return List.of("USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF");
    }

    private BigDecimal fetchRemoteRate(String source, String target) {
        String apiKey = System.getenv("SWOP_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            logger.debug("SWOP_API_KEY not configured, using fallback rates for {}/{}", source, target);
            return null;
        }

        // Refresh EUR rates if cache is empty
        if (eurRates.isEmpty()) {
            loadEurRates();
        }

        // If still empty, API is not available
        if (eurRates.isEmpty()) {
            logger.warn("Unable to load rates from SWOP API, using fallback for {}/{}", source, target);
            return null;
        }

        // Calculate cross-rate using EUR as intermediary
        BigDecimal rate = calculateCrossRate(source, target);
        if (rate != null) {
            logger.info("✅ SWOP API cross-rate {}/{} = {} (via EUR)", source, target, rate);
            meterRegistry.counter("swop.api.success", "base", source, "target", target).increment();
            return rate;
        }

        logger.warn("Currency pair {}/{} not available in SWOP data", source, target);
        return null;
    }

    /**
     * Load all EUR-based exchange rates from SWOP API
     */
    private void loadEurRates() {
        String apiKey = System.getenv("SWOP_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            logger.debug("SWOP_API_KEY not configured, skipping rate load");
            return;
        }

        try {
            logger.info("Fetching all EUR-based rates from SWOP API...");
            JsonNode response = swopClient.get()
                    .uri("/rates")
                    .header("Authorization", "ApiKey " + apiKey)
                    .retrieve()
                    .bodyToMono(JsonNode.class)
                    .block(Duration.ofSeconds(10));

            if (response == null || !response.isArray()) {
                logger.error("Invalid response from SWOP API");
                return;
            }

            eurRates.clear();
            int count = 0;
            for (JsonNode rate : response) {
                String quoteCurrency = rate.path("quote_currency").asText();
                BigDecimal quote = rate.path("quote").decimalValue();
                
                if (quoteCurrency != null && !quoteCurrency.isBlank() && quote != null) {
                    eurRates.put(quoteCurrency, quote);
                    count++;
                }
            }

            logger.info("✅ Loaded {} currency rates from SWOP (base: EUR, date: {})", 
                       count, response.get(0).path("date").asText("N/A"));
            meterRegistry.gauge("swop.rates.loaded", count);
            
        } catch (Exception e) {
            logger.error("Failed to load rates from SWOP API: {}", e.getMessage(), e);
            meterRegistry.counter("swop.api.load.failure").increment();
        }
    }

    /**
     * Calculate cross-rate using EUR as intermediary currency
     * For example: USD/GBP = (1 / EUR/USD) * EUR/GBP
     */
    private BigDecimal calculateCrossRate(String source, String target) {
        // Direct EUR conversion
        if (BASE_CURRENCY.equals(source)) {
            return eurRates.get(target);
        }
        
        if (BASE_CURRENCY.equals(target)) {
            BigDecimal eurToSource = eurRates.get(source);
            if (eurToSource == null) return null;
            return BigDecimal.ONE.divide(eurToSource, 6, RoundingMode.HALF_UP);
        }

        // Cross-rate calculation: source/target = (EUR/target) / (EUR/source)
        BigDecimal eurToSource = eurRates.get(source);
        BigDecimal eurToTarget = eurRates.get(target);
        
        if (eurToSource == null || eurToTarget == null) {
            return null;
        }

        return eurToTarget.divide(eurToSource, 6, RoundingMode.HALF_UP);
    }

    private BigDecimal getFallbackRate(String source, String target) {
        meterRegistry.counter("conversion.fallback.rates", "base", source, "target", target).increment();
        
        // Development mode: Provide mock exchange rates when API key is not configured
        // This allows testing without requiring an external API key
        BigDecimal mockRate = getMockExchangeRate(source, target);
        if (mockRate != null) {
            logger.info("⚠️  Using MOCK rate {}/{} = {} (SWOP API not available)", source, target, mockRate);
            return mockRate;
        }
        
        // No mock rate available and API is not accessible
        logger.error("Unsupported currency pair: {}/{}", source, target);
        throw new IllegalArgumentException(
            "Unsupported currency pair: " + source + "/" + target + 
            ". Please ensure SWOP_API_KEY is configured to access live rates for all currency pairs."
        );
    }

    private String normalizeCurrency(String currency) {
        if (currency == null || currency.isBlank()) {
            throw new IllegalArgumentException("Currency code must not be blank");
        }

        return currency.trim().toUpperCase(Locale.ROOT);
    }

    /**
     * Provides mock exchange rates for development/testing when SWOP API is not available.
     * Returns null if no mock rate is available for the given currency pair.
     */
    private BigDecimal getMockExchangeRate(String source, String target) {
        // Common currency pairs with approximate rates
        String pair = source + "/" + target;
        
        return switch (pair) {
            case "USD/EUR" -> new BigDecimal("0.92");
            case "EUR/USD" -> new BigDecimal("1.09");
            case "USD/GBP" -> new BigDecimal("0.79");
            case "GBP/USD" -> new BigDecimal("1.27");
            case "USD/JPY" -> new BigDecimal("149.50");
            case "JPY/USD" -> new BigDecimal("0.0067");
            case "EUR/GBP" -> new BigDecimal("0.86");
            case "GBP/EUR" -> new BigDecimal("1.16");
            case "USD/CAD" -> new BigDecimal("1.36");
            case "CAD/USD" -> new BigDecimal("0.74");
            case "USD/AUD" -> new BigDecimal("1.52");
            case "AUD/USD" -> new BigDecimal("0.66");
            case "USD/CHF" -> new BigDecimal("0.88");
            case "CHF/USD" -> new BigDecimal("1.14");
            case "EUR/JPY" -> new BigDecimal("162.50");
            case "JPY/EUR" -> new BigDecimal("0.0062");
            default -> null; // No mock rate available
        };
    }
}