import { createI18n } from 'vue-i18n';

const numberFormats = {
  'en-US': {
    currency: {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2
    },
    rate: {
      style: 'decimal',
      minimumFractionDigits: 2,
      maximumFractionDigits: 4
    }
  }
};

export default createI18n({
  legacy: false,
  locale: 'en-US',
  fallbackLocale: 'en-US',
  globalInjection: true,
  numberFormats
});

