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

    <section class="info-grid">
      <article>
        <h2>What's included</h2>
        <ul>
          <li>Vue 3 single-file components with responsible UI</li>
          <li>API written in Java.</li>
          <li>Formatted the resultant value using the Web i18n framework</li>
          <li>Implemented Spring In-Memory Cache (ConcurrentMapCacheManager) for the backend</li>
          <li>Implemented Apollo InMemoryCache for the front end</li>
          <li>Containerized with Docker for consistent deployment across different environments (dev/prod)</li>
          <li>Instrumented with Micrometer metrics and Spring Boot Actuator for comprehensive monitoring</li>
          <li>Real-time analytics using InfluxDB for metrics storage and Grafana for visualization dashboards</li>
        </ul>
      </article>
    </section>
  </main>
</template>

