# Currency Converter Full-Stack Application

**Author:** Sunilkumar Mohandas

Production-ready currency converter with Spring Boot, Vue.js 3, GraphQL, and monitoring (InfluxDB + Grafana).

## Features

- ✅ GraphQL API with real-time exchange rates ([Swop.cx API](https://swop.cx/))
- ✅ Fallback mechanism with reference rates
- ✅ Response caching (Caffeine, 1-hour TTL)
- ✅ Internationalization (Vue i18n)
- ✅ Monitoring & Instrumentation (InfluxDB + Grafana)
- ✅ Docker & Docker Compose ready
- ✅ Comprehensive testing (15 tests passing)

## Quick Start

### Prerequisites
- Java 11+ (tested with Amazon Corretto 11.0.24)
- Maven 3.9+
- Node.js 18+
- Docker & Docker Compose (for containerized deployment)

### Docker Compose (Recommended)

```bash
# Copy environment file
cp .env.example .env

# Add your Swop.cx API key to .env (optional)
# SWOP_API_KEY=your_api_key_here

# Start all services
docker compose up --build
```

**Services:**
- Frontend: http://localhost:80
- Backend API: http://localhost:8080
- GraphQL: http://localhost:8080/graphql
- Grafana: http://localhost:3000 (admin/admin)
- InfluxDB: http://localhost:8086

### Local Development

```bash
# Backend
cd backend
mvn clean install
mvn spring-boot:run

# Frontend (separate terminal)
cd frontend
npm install
npm run dev
```

**Services:**
- Frontend: http://localhost:5173
- Backend: http://localhost:8080


## API Documentation

### GraphQL Endpoint
**URL:** `http://localhost:8080/graphql`

### Query Example

```graphql
query {
  convert(sourceCurrency: "USD", targetCurrency: "EUR", amount: 100) {
    sourceCurrency
    targetCurrency
    originalAmount
    convertedAmount
    exchangeRate
  }
}
```

### cURL Example

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ convert(sourceCurrency: \"USD\", targetCurrency: \"EUR\", amount: 100) { sourceCurrency targetCurrency originalAmount convertedAmount exchangeRate } }"}'
```

### Response

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
USD, EUR, GBP, JPY, SEK (with fallback rates)

**Note:** With a valid Swop.cx API key, any supported currency can be used.

## Testing

```bash
cd backend
mvn test
```

**Test Coverage:**
- ✅ CurrencyService unit tests (11 test cases)
- ✅ GraphQL controller integration tests (3 test cases)
- ✅ Application context loading test

**Run specific test:**
```bash
mvn test -Dtest=CurrencyServiceTest
```

## Caching Strategy

- **Provider:** Caffeine (high-performance Java caching)
- **TTL:** 3600 seconds (1 hour)
- **Max Size:** 1000 entries
- **Cache Key:** `{sourceCurrency}:{targetCurrency}`

**Configuration** (`application.yml`):
```yaml
spring:
  cache:
    type: caffeine
    caffeine:
      spec: maximumSize=1000,expireAfterWrite=3600s
```


## Monitoring & Instrumentation

### Metrics Exported

**Custom Business Metrics:**
- `swop.api.calls` - External API call count
- `swop.api.fallback` - API failure count
- `conversion.fallback.rates` - Fallback rate usage

**Spring Boot Actuator Metrics:**
- JVM memory usage
- HTTP request metrics
- Thread pool statistics
- System CPU usage

### Grafana Dashboard

Pre-configured with 5 panels:
1. API Request Rate
2. Conversion Operations
3. JVM Memory Usage
4. API Fallback Rate
5. HTTP Response Times

**Access:** http://localhost:3000 (admin/admin)

### InfluxDB Configuration

```bash
INFLUX_ENABLED=true
MANAGEMENT_METRICS_EXPORT_INFLUX_URI=http://influxdb:8086
INFLUX_BUCKET=metrics
INFLUX_ORG=converter
INFLUX_TOKEN=default-token
```

## Frontend (Vue.js 3)

**Features:**
- Modern UI with responsive design
- Apollo Client for GraphQL
- Vue i18n for internationalization
- Real-time updates
- Error handling

**Environment Variables** (`.env`):
```bash
VITE_GRAPHQL_URL=http://localhost:8080/graphql
```


## Project Structure

```
converter_fstack_v1/
├── backend/                          # Spring Boot backend
│   ├── src/main/
│   │   ├── java/com/converter/backend/
│   │   │   ├── BackendApplication.java
│   │   │   ├── service/CurrencyService.java
│   │   │   └── web/ConversionGraphQlController.java
│   │   └── resources/
│   │       ├── application.yml
│   │       └── graphql/schema.graphqls
│   └── pom.xml
├── frontend/                         # Vue.js 3 frontend
│   ├── src/
│   │   ├── App.vue
│   │   ├── main.js
│   │   ├── apollo.js
│   │   └── i18n.js
│   ├── package.json
│   └── vite.config.js
├── monitoring/
│   ├── grafana-dashboard.json
│   └── grafana-datasource.yml
└── docker-compose.yml
```

## Configuration

### Backend (`application.yml`)

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
| `SWOP_API_KEY` | API key from swop.cx | None |
| `INFLUX_ENABLED` | Enable InfluxDB metrics | `true` |
| `INFLUX_BUCKET` | Metrics bucket | `metrics` |
| `INFLUX_ORG` | InfluxDB organization | `converter` |

## Production Considerations

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
- [ ] Add Redis for distributed caching

### Scalability
- ✅ Stateless backend (can scale horizontally)
- ✅ Docker containers ready for orchestration
- [ ] Configure load balancer
- [ ] Use managed InfluxDB service

### Monitoring
- ✅ Health checks configured
- ✅ Metrics exported to InfluxDB
- ✅ Grafana dashboard provided
- [ ] Add alerting rules
- [ ] Configure log aggregation

## Troubleshooting

### Backend won't start

```bash
# Check if port 8080 is in use
lsof -i :8080

# Verify Java version
java -version  # Should be 11+
```

### Frontend can't connect to backend

1. Verify backend: `curl http://localhost:8080/actuator/health`
2. Check CORS settings
3. Verify `.env` file has correct `VITE_GRAPHQL_URL`

### Docker Compose fails

```bash
# Clean up and restart
docker compose down -v
docker compose up --build

# Check logs
docker compose logs backend
```

### No data in Grafana

1. Verify InfluxDB: `curl http://localhost:8086/health`
2. Check backend metrics: `curl http://localhost:8080/actuator/metrics`
3. Verify InfluxDB datasource in Grafana

## License

This project is provided as-is for evaluation purposes.

## External Resources

- [Swop.cx API Documentation](https://swop.cx/documentation)
- [Spring Boot GraphQL](https://spring.io/projects/spring-graphql)
- [Vue.js 3](https://vuejs.org/)
- [Apollo Client](https://www.apollographql.com/docs/react/)
- [InfluxDB](https://docs.influxdata.com/)
- [Grafana](https://grafana.com/docs/)

---

**Last Updated:** March 30, 2026

**Status:** ✅ All requirements fulfilled and tested

