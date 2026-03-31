<script setup>
import { ref, onMounted } from 'vue';
import gql from 'graphql-tag';
import apolloClient from '../config/apollo';
import { currencyLabels } from '../constants/currencies';

const currencies = ref([]);
const amount = ref(100);
const fromCurrency = ref('USD');
const targetCurrency = ref('EUR');
const result = ref(null);
const loading = ref(false);
const errorMsg = ref(null);
const loadingCurrencies = ref(true);

const CURRENCIES_QUERY = gql`
  query GetCurrencies {
    currencies
  }
`;

const CONVERT_QUERY = gql`
  query ConvertCurrency($sourceCurrency: String!, $targetCurrency: String!, $amount: Float!) {
    convert(sourceCurrency: $sourceCurrency, targetCurrency: $targetCurrency, amount: $amount) {
      sourceCurrency
      targetCurrency
      originalAmount
      convertedAmount
      exchangeRate
    }
  }
`;

// Fetch available currencies on component mount
async function fetchCurrencies() {
  loadingCurrencies.value = true;
  try {
    const response = await apolloClient.query({
      query: CURRENCIES_QUERY,
      fetchPolicy: 'network-only'
    });

    if (response?.data?.currencies) {
      currencies.value = response.data.currencies.map(code => ({
        code,
        label: currencyLabels[code] || code
      }));

      // Set default currencies if they exist in the list
      if (currencies.value.length > 0) {
        const codes = currencies.value.map(c => c.code);
        if (codes.includes('USD')) fromCurrency.value = 'USD';
        else fromCurrency.value = codes[0];

        if (codes.includes('EUR')) targetCurrency.value = 'EUR';
        else if (codes.length > 1) targetCurrency.value = codes[1];
        else targetCurrency.value = codes[0];
      }
    }
  } catch (err) {
    console.error('Error fetching currencies:', err);
    // Fallback to a minimal list if fetch fails
    currencies.value = [
      { code: 'USD', label: 'US Dollar' },
      { code: 'EUR', label: 'Euro' }
    ];
  } finally {
    loadingCurrencies.value = false;
  }
}

async function convert() {
  if (!fromCurrency.value || !targetCurrency.value || !Number.isFinite(amount.value) || amount.value < 0) {
    result.value = null;
    return;
  }

  loading.value = true;
  errorMsg.value = null;

  try {
    // Use the Apollo client directly for on-demand queries
    const response = await apolloClient.query({
      query: CONVERT_QUERY,
      variables: {
        sourceCurrency: fromCurrency.value,
        targetCurrency: targetCurrency.value,
        amount: amount.value
      },
      fetchPolicy: 'network-only'
    });

    if (response?.data?.convert) {
      result.value = response.data.convert;
    }
    loading.value = false;
  } catch (err) {
    console.error('Conversion error:', err);

    // Provide helpful error messages
    let message = 'Failed to convert currency';
    if (err.message?.includes('fetch')) {
      message = 'Cannot connect to backend. Make sure the backend is running on http://localhost:8080';
    } else if (err.graphQLErrors?.length > 0) {
      const graphqlError = err.graphQLErrors[0];
      if (graphqlError.message?.includes('SWOP_API_KEY') || graphqlError.message?.includes('Exchange rate service unavailable')) {
        message = 'Backend API key not configured. Please set SWOP_API_KEY environment variable and restart the backend.';
      } else {
        message = graphqlError.message || message;
      }
    } else if (err.networkError) {
      message = 'Network error: ' + (err.networkError.message || 'Cannot reach backend');
    } else {
      message = err.message || message;
    }

    errorMsg.value = message;
    result.value = null;
    loading.value = false;
  }
}

function swapCurrencies() {
  [fromCurrency.value, targetCurrency.value] = [targetCurrency.value, fromCurrency.value];

  if (result.value) {
    convert();
  }
}

// Fetch currencies when component mounts
onMounted(() => {
  fetchCurrencies();
});
</script>

<template>
  <div class="converter-card">
    <label>
      <span>Amount</span>
      <input v-model.number="amount" type="number" min="0" step="0.01" />
    </label>

    <div class="row">
      <label>
        <span>From</span>
        <select v-model="fromCurrency">
          <option
            v-for="currency in currencies"
            :key="`from-${currency.code}`"
            :value="currency.code"
          >
            {{ currency.code }} — {{ currency.label }}
          </option>
        </select>
      </label>

      <label>
        <span>To</span>
        <select v-model="targetCurrency">
          <option
            v-for="currency in currencies"
            :key="`to-${currency.code}`"
            :value="currency.code"
          >
            {{ currency.code }} — {{ currency.label }}
          </option>
        </select>
      </label>
    </div>

    <div class="actions">
      <button class="convert-button" type="button" @click="convert" :disabled="loading">
        {{ loading ? 'Converting...' : 'Convert' }}
      </button>
      <button class="swap-button swap-button-secondary" type="button" @click="swapCurrencies">
        Swap currencies
      </button>
    </div>

    <div v-if="errorMsg" class="error-panel">
      <p class="error-message">{{ errorMsg }}</p>
    </div>

    <div v-if="result" class="result-panel">
      <p class="result-label">Result</p>
      <p class="result-value">
        {{ $n(result.convertedAmount, { key: 'currency', currency: result.targetCurrency }) }}
      </p>
      <p class="rate-copy">
        1 {{ result.sourceCurrency }} =
        {{ $n(result.exchangeRate, { key: 'rate' }) }} {{ result.targetCurrency }}
      </p>
    </div>
    <p v-else-if="!loading && !errorMsg" class="helper-copy">
      Choose currencies and click Convert to format the result with i18n.
    </p>
  </div>
</template>

