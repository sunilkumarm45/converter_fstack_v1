# converter_fstack_v1

Full-stack currency converter workspace with:

- a Spring Boot backend in `backend/`
- a Vue 3 + Vite frontend in `frontend/`
- a `docker-compose.yml` intended to run frontend, backend, InfluxDB, and Grafana together

## Current status

Verified from this workspace on **2026-03-31**:

- ✅ Frontend installs and builds successfully
- ✅ Frontend dev server responds on `http://localhost:5173`
- ✅ Backend compiles, all tests pass (15/15), and the app starts on `http://localhost:8080`
- ✅ Backend upgraded to **Java 21** (Amazon Corretto 21.0.10)
- ✅ GraphQL endpoint responds on `http://localhost:8080/graphql`
- ✅ **SWOP API integration fixed** - See [SWOP_API_RESOLUTION.md](./SWOP_API_RESOLUTION.md)
- ⚠️ Full Docker Compose stack requires Docker Desktop — Docker is not available in this environment

> ☕ **Java 21 Configuration:** Run `./validate-java21.sh` to verify your Java setup.
> 
> 🔑 **SWOP API Setup:** Run `./run-backend-with-api.sh YOUR_KEY` or see [SWOP_API_FIX.md](./SWOP_API_FIX.md)

## 🌍 NEW: Environment Configuration

This project now supports **separate Development and Production environments**!

### Quick Setup (3 Steps)

1. **Get API Key:** Register at https://swop.cx
2. **Configure:** Run `./setup-wizard.sh` or `make setup-dev`
3. **Start:** Run `./run-docker.sh dev` or `make dev`

### Available Commands

| Command | Description |
|---------|-------------|
| `make setup` | Interactive setup wizard |
| `make dev` | Start development environment |
| `make prod` | Start production environment |
| `make validate` | Validate your configuration |
| `make test` | Run backend tests |
| `make help` | Show all available commands |

### Environment Files

- **`.env.dev`** → Development configuration (debug mode, simple passwords)
- **`.env.prod`** → Production configuration (optimized, secure)
- **`.env.local.example`** → Local development without Docker

### Documentation

- **[ENV_SETUP.md](./ENV_SETUP.md)** - Quick reference (start here!)
- **[ENVIRONMENT_GUIDE.md](./ENVIRONMENT_GUIDE.md)** - Complete guide
- **[ENV_MATRIX.md](./ENV_MATRIX.md)** - Configuration comparison
- **[ENVIRONMENT_OVERVIEW.md](./ENVIRONMENT_OVERVIEW.md)** - Architecture diagrams
- **[CORS_CONFIGURATION.md](./CORS_CONFIGURATION.md)** - CORS setup and troubleshooting

### 🔒 Security Configuration

#### CORS (Cross-Origin Resource Sharing)

The backend now supports **full CORS configuration** via environment variables:

```bash
# Development (permissive)
CORS_ALLOWED_ORIGINS=http://localhost:5173,http://localhost:3000,http://localhost:8080

# Production (strict - MUST be set!)
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

**Key Features:**
- ✅ Environment-aware defaults (dev vs prod)
- ✅ Configurable via environment variables
- ✅ Secure production defaults
- ✅ Automatic logging on startup
- ✅ Test script included (`./test-cors.sh`)

📚 **See [CORS_CONFIGURATION.md](./CORS_CONFIGURATION.md)** for complete documentation, examples, and troubleshooting.

**Quick Test:**
```bash
./test-cors.sh http://localhost:8080 http://localhost:5173
```

---

## What I ran

### Frontend

Verified successfully:

```zsh
cd "/Users/a1245991/Workspace/converter_fstack_v1/frontend"
npm install
npm run build
npm run dev
```

Dev server responded HTTP 200 on `http://localhost:5173`.

### Backend

Verified successfully:

```zsh
cd "/Users/a1245991/Workspace/converter_fstack_v1/backend"
mvn test
mvn spring-boot:run
```

Results:
- `Tests run: 15, Failures: 0, Errors: 0`
- App started on port 8080 in ~4 s

Endpoint spot-checks:

```zsh
# Root
curl http://localhost:8080/
# → {"service":"converter-backend","status":"ok"}

# Health
curl http://localhost:8080/actuator/health
# → {"status":"UP"}

# GraphQL — convert 100 USD → EUR
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ convert(sourceCurrency:\"USD\", targetCurrency:\"EUR\", amount:100) { sourceCurrency targetCurrency originalAmount convertedAmount exchangeRate } }"}'
# → {"data":{"convert":{"sourceCurrency":"USD","targetCurrency":"EUR","originalAmount":100.0,"convertedAmount":92.0,"exchangeRate":0.92}}}
```

## Prerequisites

### For the frontend

- Node.js 22+ recommended
- npm

### For the backend

- **Java 21** (Amazon Corretto 21.0.10+) - **REQUIRED**
- Maven 3.9+

> ☕ **Java 21 Upgrade:** This application has been upgraded to Java 21. See [JAVA21_UPGRADE.md](./JAVA21_UPGRADE.md) for details.
> 
> **Validate your setup:** Run `./validate-java21.sh` to verify Java 21 is correctly configured.

### For Docker Compose

- Docker Desktop / Docker Engine with Compose support

## 🌍 Environment Configuration

This project supports separate **Development** and **Production** environment configurations.

**Quick Start:**
```bash
# For development
cp .env.dev .env
# Edit .env and add your SWOP_API_KEY from https://swop.cx

# Run with Docker
./run-docker.sh dev

# Or run locally
./run-env.sh dev
```

📚 **See [ENV_SETUP.md](./ENV_SETUP.md)** for quick reference or [ENVIRONMENT_GUIDE.md](./ENVIRONMENT_GUIDE.md) for complete documentation.

## Run the frontend locally

```zsh
cd "/Users/a1245991/Workspace/converter_fstack_v1/frontend"
npm install
npm run dev
```

Open:

- `http://localhost:5173`

## Build the frontend

```zsh
cd "/Users/a1245991/Workspace/converter_fstack_v1/frontend"
npm run build
```

## Run the backend locally

```zsh
cd "/Users/a1245991/Workspace/converter_fstack_v1/backend"
mvn spring-boot:run
```

Endpoints once running:

| Endpoint | Description |
|---|---|
| `http://localhost:8080/` | Service info (REST) |
| `http://localhost:8080/actuator/health` | Spring actuator health |
| `http://localhost:8080/graphql` | GraphQL API (HTTP POST) |

GraphQL example — convert 100 USD to EUR:

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

To use live rates from [swop.cx](https://swop.cx), set the environment variables before starting:

```zsh
export SWOP_API_KEY=your_key_here
export SWOP_API_BASE_URL=https://swop.cx/rest  # Optional, uses this as default
mvn spring-boot:run
```

**Note:** Without a valid `SWOP_API_KEY`, the application will return an error when attempting conversions.

## Docker Compose status

The repository includes `docker-compose.yml` with these services:

- `influxdb`
- `grafana`
- `backend`
- `frontend`

Intended command:

```zsh
cd "/Users/a1245991/Workspace/converter_fstack_v1"
docker compose up --build
```

Known issues in the current repo state:

1. Docker could not be verified in this environment because the `docker` command is not installed here
2. `backend` requires a valid `SWOP_API_KEY` for currency conversions; without it, conversion requests will fail

## Project structure

```text
converter_fstack_v1/
├── backend/
├── frontend/
├── docker-compose.yml
└── README.md
```

## Recommended next fixes

To complete the Docker Compose stack:

1. Provide `SWOP_API_KEY` in a `.env` file at the repo root before starting Compose (required for currency conversions)
2. Optionally set `SWOP_API_BASE_URL` to customize the API endpoint
3. Configure InfluxDB credentials in `docker-compose.yml` to enable metrics export from the backend
