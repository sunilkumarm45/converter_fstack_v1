# Currency Converter Full-Stack

**Author:** Sunilkumar Mohandas

Spring Boot (Java 21) + Vue 3 + GraphQL currency converter with monitoring (InfluxDB + Grafana).

## Status

- ✅ Backend: Java 21, all tests pass (15/15), runs on `http://localhost:8080`
- ✅ Frontend: Vue 3 + Vite, runs on `http://localhost:5173`
- ✅ GraphQL API: `http://localhost:8080/graphql`
- ✅ Docker Compose configured with full monitoring stack

## Quick Start

### Prerequisites

**With Docker (Recommended):**
- Docker Desktop 20.10+ with Compose 2.0+
- SWOP API Key from [swop.cx](https://swop.cx)

**Without Docker:**
- Java 21 (Amazon Corretto 21.0.10+)
- Maven 3.9+
- Node.js 22+
- SWOP API Key from [swop.cx](https://swop.cx)

### Run with Docker

```bash
# Verify Docker is running
./check-docker-status.sh

# Start with API key
./run-docker.sh dev YOUR_API_KEY

# Or use .env file
cp .env.dev .env.dev  # Edit to add your API key
./run-docker.sh dev
```

### Run Locally

```bash
# Install frontend dependencies
cd frontend && npm install && cd ..

# Start with API key
./run-env.sh dev YOUR_API_KEY
```

### Access Services

- Frontend: http://localhost:5173 (local) or http://localhost:80 (Docker)
- Backend API: http://localhost:8080
- GraphQL: http://localhost:8080/graphql
- Grafana: http://localhost:3000 (Docker only, admin/admin)
- InfluxDB: http://localhost:8086 (Docker only)

## GraphQL API

**Endpoint:** `http://localhost:8080/graphql`

**Example Query:**
```graphql
{
  convert(sourceCurrency: "USD", targetCurrency: "EUR", amount: 100) {
    sourceCurrency
    targetCurrency
    originalAmount
    convertedAmount
    exchangeRate
  }
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ convert(sourceCurrency:\"USD\", targetCurrency:\"EUR\", amount:100) { sourceCurrency targetCurrency originalAmount convertedAmount exchangeRate } }"}'
```

## Testing

```bash
cd backend
mvn test  # 15 tests, all passing
```

## Environment Configuration

**Command-line (Quick):**
```bash
./run-docker.sh dev YOUR_API_KEY
./run-env.sh dev YOUR_API_KEY
```

**Environment files:**
- `.env.dev` - Development configuration
- `.env.prod` - Production configuration

**CORS Configuration:**
```bash
# Development
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000

# Production
CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

See [CORS_CONFIGURATION.md](./CORS_CONFIGURATION.md) for details.

## Available Scripts

| Script | Description |
|--------|-------------|
| `./run-docker.sh dev [API_KEY]` | Start with Docker |
| `./run-env.sh dev [API_KEY]` | Start locally |
| `./check-docker-status.sh` | Verify Docker |
| `./validate-java21.sh` | Verify Java setup |
| `./setup-wizard.sh` | Interactive setup |
| `./test-cors.sh` | Test CORS |

## Documentation

- [CORS_CONFIGURATION.md](./CORS_CONFIGURATION.md) - CORS setup
- [API_KEY_SETUP.md](./API_KEY_SETUP.md) - API key configuration
