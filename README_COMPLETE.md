# Currency Converter Full-Stack Application

A production-ready currency converter application built with Spring Boot (Java), Vue.js 3, GraphQL, and complete monitoring stack (InfluxDB + Grafana).

## 📋 Features

### Core Functionality
- ✅ **GraphQL API** - Modern API using GraphQL for currency conversion
- ✅ **Real-time Exchange Rates** - Integration with [Swop.cx API](https://swop.cx/)
- ✅ **Fallback Mechanism** - Built-in reference rates when API is unavailable
- ✅ **Input Validation** - Comprehensive validation on all inputs
- ✅ **Error Handling** - Graceful error handling with user-friendly messages

### Technical Features
- ✅ **Caching** - Response caching using Caffeine (1-hour TTL, 1000 entries max)
- ✅ **Internationalization (i18n)** - Vue i18n for formatting currency and numbers
- ✅ **Monitoring & Instrumentation** - InfluxDB metrics export with Grafana dashboards
- ✅ **Containerization** - Docker and Docker Compose for easy deployment
- ✅ **Testing** - Comprehensive unit and integration tests
- ✅ **Production-Ready** - Health checks, metrics, proper error handling

## 🏗️ Architecture

```
┌─────────────────┐      GraphQL       ┌──────────────────┐      REST API      ┌─────────────┐
│   Vue.js 3      │ ◄──────────────── │  Spring Boot     │ ◄────────────────► │  Swop.cx    │
│   Frontend      │    Apollo Client   │  Backend (Java)  │   WebClient        │  API        │
│   (Port 5173)   │                    │  (Port 8080)     │                    └─────────────┘
└─────────────────┘                    └──────────────────┘
                                              │
                                              │ Metrics
                                              ▼
                                       ┌──────────────────┐
                                       │    InfluxDB      │
                                       │  (Port 8086)     │
                                       └──────────────────┘
                                              │
                                              │ Query
                                              ▼
                                       ┌──────────────────┐
                                       │     Grafana      │
                                       │  (Port 3000)     │
                                       └──────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- **Java 11+** (tested with Amazon Corretto 11.0.24)
- **Maven 3.9+**
- **Node.js 18+** (tested with Node 22)
- **Docker & Docker Compose** (for containerized deployment)

### Option 1: Docker Compose (Recommended)

The easiest way to run the entire stack:

```bash
# Clone the repository
cd /path/to/converter_fstack_v1

# Copy environment file
cp .env.example .env

# (Optional) Add your Swop.cx API key to .env
# SWOP_API_KEY=your_api_key_here

# Start all services
docker compose up --build
```

**Services will be available at:**
- Frontend: http://localhost:80
- Backend API: http://localhost:8080
- GraphQL Endpoint: http://localhost:8080/graphql
- Grafana: http://localhost:3000 (admin/admin)
- InfluxDB: http://localhost:8086

### Option 2: Local Development

#### Start Backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

#### Start Frontend

```bash
cd frontend
npm install
npm run dev
```

**Services will be available at:**
- Frontend: http://localhost:5173
- Backend: http://localhost:8080

### Option 3: Using the Run Script

```bash
chmod +x run.sh
./run.sh
```

This script starts both backend and frontend, waits for services to be healthy, and provides helpful information.

## 📚 API Documentation

### GraphQL Endpoint

**URL:** `http://localhost:8080/graphql`

**Method:** POST

**Content-Type:** `application/json`

### Query: Convert Currency

```graphql
query {
  convert(
    sourceCurrency: "USD"
    targetCurrency: "EUR"
    amount: 100
  ) {
    sourceCurrency
    targetCurrency
    originalAmount
    convertedAmount
    exchangeRate
  }
}
```

### Example Request (cURL)

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ convert(sourceCurrency: \"USD\", targetCurrency: \"EUR\", amount: 100) { sourceCurrency targetCurrency originalAmount convertedAmount exchangeRate } }"
  }'
```

### Example Response

```json
{
  "data": {
    "convert": {
      "sourceCurrency": "USD",
      "targetCurrency": "EUR",
      "originalAmount": 100.0,
      "convertedAmount": 92.0,
      "exchangeRate": 0.92
    }
  }
}
```

### Supported Currencies

The application supports the following currencies with fallback rates:
- **USD** - US Dollar
- **EUR** - Euro
- **GBP** - British Pound
- **JPY** - Japanese Yen
- **SEK** - Swedish Krona

**Note:** With a valid Swop.cx API key, you can convert between any currencies supported by Swop.cx.

### Validation Rules

- `sourceCurrency`: Required, must not be blank
- `targetCurrency`: Required, must not be blank
- `amount`: Required, must be positive number

### Error Responses

```json
{
  "errors": [
    {
      "message": "Unsupported currency pair: USD to XYZ",
      "path": ["convert"]
    }
  ]
}
```

## 🧪 Testing

### Backend Tests

```bash
cd backend
mvn test
```

**Test Coverage:**
- ✅ Unit tests for `CurrencyService` (11 test cases)
- ✅ Integration tests for GraphQL controller (3 test cases)
- ✅ Application context loading test

### Test Classes

1. **CurrencyServiceTest** - Tests exchange rate calculation, validation, error handling
2. **ConversionGraphQlControllerTest** - Tests GraphQL queries with mocked service
3. **BackendApplicationTests** - Tests Spring Boot context and health endpoints

### Run Specific Test

```bash
mvn test -Dtest=CurrencyServiceTest
```

## 💾 Caching Strategy

The application implements caching to optimize performance:

- **Cache Provider:** Caffeine (high-performance Java caching library)
- **Cache Name:** `rates`
- **TTL:** 3600 seconds (1 hour)
- **Max Size:** 1000 entries
- **Cache Key:** `{sourceCurrency}:{targetCurrency}` (e.g., "USD:EUR")

### Cache Configuration

Located in `backend/src/main/resources/application.yml`:

```yaml
spring:
  cache:
    type: caffeine
    caffeine:
      spec: maximumSize=1000,expireAfterWrite=3600s
```

### Why Caching?

- Reduces external API calls to Swop.cx
- Improves response time for repeated queries
- Prevents rate limiting issues
- Provides better reliability

## 📊 Monitoring & Instrumentation

### Metrics Exported

The backend exports metrics to InfluxDB:

**Custom Business Metrics:**
- `swop.api.calls` - External API call count (tags: base, target)
- `swop.api.fallback` - API failure count (tags: reason)
- `conversion.fallback.rates` - Fallback rate usage (tags: base, target)

**Spring Boot Actuator Metrics:**
- JVM memory usage
- HTTP request metrics
- Thread pool statistics
- System CPU usage

### Grafana Dashboard

Pre-configured dashboard with 5 panels:
1. **API Request Rate** - Requests per second to external API
2. **Conversion Operations** - Total conversion count
3. **JVM Memory Usage** - Memory consumption over time
4. **API Fallback Rate** - How often fallback rates are used
5. **HTTP Response Times** - API latency metrics

**Access Dashboard:**
1. Open http://localhost:3000
2. Login with `admin/admin`
3. Navigate to Dashboards → Currency Converter Monitoring

### InfluxDB Configuration

Environment variables (set in `.env` or `docker-compose.yml`):

```bash
INFLUX_ENABLED=true
MANAGEMENT_METRICS_EXPORT_INFLUX_URI=http://influxdb:8086
INFLUX_BUCKET=metrics
INFLUX_ORG=converter
INFLUX_TOKEN=default-token
```

## 🐳 Docker Deployment

### Build Individual Services

**Backend:**
```bash
cd backend
docker build -t converter-backend .
docker run -p 8080:8080 converter-backend
```

**Frontend:**
```bash
cd frontend
docker build -t converter-frontend .
docker run -p 80:80 converter-frontend
```

### Docker Compose Services

The `docker-compose.yml` defines 4 services:

1. **influxdb** - Time-series database for metrics
2. **grafana** - Monitoring dashboard
3. **backend** - Spring Boot API
4. **frontend** - Vue.js application

### Health Checks

All services include health checks:
- **InfluxDB:** `influx ping`
- **Backend:** `curl http://localhost:8080/actuator/health`
- **Frontend:** Depends on backend health

### Volumes

Persistent data is stored in Docker volumes:
- `influxdb-data` - InfluxDB database
- `grafana-data` - Grafana dashboards and settings

## 🌐 Frontend (Vue.js 3)

### Features

- **Modern UI** - Responsive design with dark theme
- **Apollo Client** - GraphQL client for API communication
- **Vue i18n** - International number and currency formatting
- **Real-time Updates** - Direct connection to backend GraphQL API
- **Error Handling** - User-friendly error messages

### i18n Configuration

Located in `frontend/src/i18n.js`:

```javascript
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
```

### Environment Variables

Create `.env` file in frontend directory:

```bash
VITE_GRAPHQL_URL=http://localhost:8080/graphql
```

For production deployment, update this to point to your production backend.

## 📦 Project Structure

```
converter_fstack_v1/
├── backend/                          # Spring Boot backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/converter/backend/
│   │   │   │       ├── BackendApplication.java
│   │   │   │       ├── service/
│   │   │   │       │   └── CurrencyService.java       # Business logic
│   │   │   │       └── web/
│   │   │   │           ├── ConversionGraphQlController.java
│   │   │   │           ├── ConversionResult.java
│   │   │   │           └── HealthController.java
│   │   │   └── resources/
│   │   │       ├── application.yml                    # Configuration
│   │   │       └── graphql/
│   │   │           └── schema.graphqls                # GraphQL schema
│   │   └── test/                                      # Test suite
│   ├── Dockerfile
│   └── pom.xml                                        # Maven dependencies
├── frontend/                         # Vue.js 3 frontend
│   ├── src/
│   │   ├── App.vue                                   # Main component
│   │   ├── main.js                                   # App entry point
│   │   ├── apollo.js                                 # GraphQL client config
│   │   ├── i18n.js                                   # Internationalization
│   │   └── style.css                                 # Styles
│   ├── Dockerfile
│   ├── package.json
│   └── vite.config.js
├── monitoring/                       # Monitoring configurations
│   ├── grafana-dashboard.json                        # Dashboard definition
│   ├── grafana-datasource.yml                        # InfluxDB datasource
│   └── README.md
├── docker-compose.yml                                 # Full stack orchestration
├── .env.example                                       # Environment variables template
├── run.sh                                             # Local development script
└── README.md                                          # This file
```

## 🔧 Configuration

### Backend Configuration (`application.yml`)

```yaml
spring:
  application:
    name: converter-backend
  cache:
    type: caffeine
    caffeine:
      spec: maximumSize=1000,expireAfterWrite=3600s

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      influx:
        enabled: true
        uri: http://localhost:8086
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SWOP_API_KEY` | API key from swop.cx | None (uses fallback rates) |
| `INFLUX_ENABLED` | Enable InfluxDB metrics | `true` |
| `MANAGEMENT_METRICS_EXPORT_INFLUX_URI` | InfluxDB URL | `http://localhost:8086` |
| `INFLUX_BUCKET` | Metrics bucket | `metrics` |
| `INFLUX_ORG` | InfluxDB organization | `converter` |
| `INFLUX_TOKEN` | Auth token | `default-token` |
| `ENVIRONMENT` | Environment name | `development` |

## 🎯 Production Considerations

### Security
- [ ] Change default Grafana password
- [ ] Use secure InfluxDB token
- [ ] Implement API rate limiting
- [ ] Add CORS configuration for frontend
- [ ] Use HTTPS/TLS in production
- [ ] Secure Swop.cx API key (use secrets management)

### Performance
- ✅ Caching implemented (1-hour TTL)
- ✅ Connection pooling (WebClient)
- [ ] Consider CDN for frontend assets
- [ ] Add Redis for distributed caching (multi-instance deployments)

### Scalability
- ✅ Stateless backend (can scale horizontally)
- ✅ Docker containers ready for orchestration
- [ ] Configure load balancer for multiple instances
- [ ] Use managed InfluxDB service

### Monitoring
- ✅ Health checks configured
- ✅ Metrics exported to InfluxDB
- ✅ Grafana dashboard provided
- [ ] Add alerting rules
- [ ] Configure log aggregation (ELK stack)

## 🐛 Troubleshooting

### Backend won't start

```bash
# Check if port 8080 is already in use
lsof -i :8080

# Check logs
tail -f /tmp/converter-backend.log

# Verify Java version
java -version  # Should be 11+
```

### Frontend can't connect to backend

1. Verify backend is running: `curl http://localhost:8080/actuator/health`
2. Check CORS settings if running on different domains
3. Verify `.env` file has correct `VITE_GRAPHQL_URL`
4. Check browser console for errors

### Docker Compose fails

```bash
# Clean up and restart
docker compose down -v
docker compose up --build

# Check individual service logs
docker compose logs backend
docker compose logs frontend
docker compose logs influxdb
docker compose logs grafana
```

### No data in Grafana

1. Verify InfluxDB is healthy: `curl http://localhost:8086/health`
2. Check backend is exporting metrics: `curl http://localhost:8080/actuator/metrics`
3. Verify InfluxDB datasource in Grafana (Configuration → Data Sources)
4. Check InfluxDB bucket contains data

## 📄 License

This project is provided as-is for evaluation purposes.

## 👥 Authors

Created as a technical assessment demonstrating:
- Full-stack development (Java + Vue.js)
- GraphQL API design
- Production-ready code quality
- Testing best practices
- Monitoring and observability
- Containerization and deployment

## 🔗 External Resources

- [Swop.cx API Documentation](https://swop.cx/documentation)
- [Spring Boot GraphQL](https://spring.io/projects/spring-graphql)
- [Vue.js 3](https://vuejs.org/)
- [Apollo Client](https://www.apollographql.com/docs/react/)
- [InfluxDB](https://docs.influxdata.com/)
- [Grafana](https://grafana.com/docs/)

---

**Last Updated:** March 30, 2026

**Status:** ✅ All requirements fulfilled and tested

