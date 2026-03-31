import { createApp } from 'vue';
import { DefaultApolloClient } from '@vue/apollo-composable';
import App from './App.vue';
import i18n from './config/i18n';
import apolloClient from './config/apollo';
import './assets/style.css';

const app = createApp(App);
app.provide(DefaultApolloClient, apolloClient);
app.use(i18n);
app.mount('#app');

