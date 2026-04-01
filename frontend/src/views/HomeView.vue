<script setup>
import CurrencyConverter from '../components/CurrencyConverter.vue';
</script>

<template>
  <main class="page-shell">
    <section class="hero-card">
      <div>
        <p class="eyebrow"> Sample App for Nosto Demo </p>
        <h1>Currency converter</h1>
        <p class="hero-copy">
          Sample Fullstack Currency Converter App (Vue.js + Spring Boot with GraphQL) for Nosto demo.
        </p>
      </div>

      <CurrencyConverter />
    </section>
  </main>
</template>

