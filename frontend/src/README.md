# Frontend Source Structure

This document describes the organized structure of the frontend source code.

## Directory Structure

```
src/
├── assets/              # Static assets (styles, images, fonts)
│   └── style.css       # Global CSS styles
├── components/          # Reusable Vue components
│   └── CurrencyConverter.vue  # Currency converter component
├── config/              # Application configuration
│   ├── apollo.js       # Apollo GraphQL client configuration
│   └── i18n.js         # Internationalization (i18n) configuration
├── constants/           # Application constants
│   └── currencies.js   # Currency codes and labels
├── views/               # Page-level components (routes)
│   └── HomeView.vue    # Home page view
├── App.vue             # Root application component
└── main.js             # Application entry point

```

## File Organization

### `/assets`
Contains static assets like stylesheets, images, and fonts.
- **style.css**: Global CSS styles with custom properties, component styles, and responsive design

### `/components`
Reusable Vue components that can be used across different views.
- **CurrencyConverter.vue**: The main currency converter component with GraphQL integration

### `/config`
Configuration files for various libraries and services.
- **apollo.js**: Apollo Client setup for GraphQL communication
- **i18n.js**: Vue I18n configuration for number formatting and localization

### `/constants`
Application-wide constants and enums.
- **currencies.js**: Currency code to label mappings

### `/views`
Page-level components that represent different routes/pages of the application.
- **HomeView.vue**: Main landing page with hero section and converter

## Benefits of This Structure

1. **Separation of Concerns**: Each directory has a clear purpose
2. **Scalability**: Easy to add new components, views, or configuration
3. **Maintainability**: Clear organization makes it easy to locate files
4. **Reusability**: Components are separated from views for better reuse
5. **Best Practices**: Follows Vue.js community conventions

## Adding New Files

### New Component
Create in `/components` directory:
```javascript
// components/NewComponent.vue
```

### New View/Page
Create in `/views` directory:
```javascript
// views/NewView.vue
```

### New Configuration
Add to `/config` directory:
```javascript
// config/router.js
```

### New Constants
Add to `/constants` directory:
```javascript
// constants/apiEndpoints.js
```

