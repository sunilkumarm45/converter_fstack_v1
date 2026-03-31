# Monitoring Configuration

This directory contains configuration files for the monitoring stack (InfluxDB + Grafana).

## Files

- **grafana-dashboard.json**: Pre-configured Grafana dashboard for monitoring currency converter metrics
- **grafana-datasource.yml**: InfluxDB datasource configuration for Grafana

## Dashboard Metrics

The Grafana dashboard tracks:

1. **API Request Rate**: Number of requests to the Swop.cx API per second
2. **Conversion Operations**: Count of currency conversions using fallback rates
3. **JVM Memory Usage**: Java Virtual Machine memory consumption
4. **API Fallback Rate**: How often the system falls back to hardcoded rates
5. **HTTP Response Times**: API endpoint response latencies

## Setup

### Automatic (Docker Compose)

The monitoring stack is automatically configured when using Docker Compose:

```bash
docker compose up -d
```

Access Grafana at: http://localhost:3000
- Default credentials: `admin/admin`
- Dashboard is auto-provisioned

### Manual Import

If running Grafana separately:

1. Log into Grafana (http://localhost:3000)
2. Go to Configuration → Data Sources
3. Import `grafana-datasource.yml` or add InfluxDB manually
4. Go to Dashboards → Import
5. Upload `grafana-dashboard.json`

## InfluxDB Configuration

The backend application exports metrics to InfluxDB using these environment variables:

- `INFLUX_ENABLED`: Enable/disable InfluxDB export (default: true)
- `MANAGEMENT_METRICS_EXPORT_INFLUX_URI`: InfluxDB URL (default: http://localhost:8086)
- `INFLUX_BUCKET`: Metrics bucket name (default: metrics)
- `INFLUX_ORG`: InfluxDB organization (default: converter)
- `INFLUX_TOKEN`: Authentication token (default: default-token)

## Custom Metrics

The application tracks custom business metrics:

- `swop.api.calls`: External API call count with tags for base/target currency
- `swop.api.fallback`: Count of API failures with reason tags
- `conversion.fallback.rates`: Count of conversions using hardcoded rates

These complement Spring Boot Actuator's built-in metrics (JVM, HTTP, etc.).

