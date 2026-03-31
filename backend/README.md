# Backend (Spring Boot)

This module contains the Spring Boot backend for the converter stack.

## Prerequisites

- Java 21+
- Maven 3.9+

## Run locally

```bash
mvn spring-boot:run
```

### Environment Variables

- `SWOP_API_KEY` - Your API key from swop.cx (required for live exchange rates)
- `SWOP_API_BASE_URL` - Base URL for Swop API (default: `https://swop.cx/rest`)

Example:
```bash
export SWOP_API_KEY=your_key_here
export SWOP_API_BASE_URL=https://swop.cx/rest
mvn spring-boot:run
```

## Run tests

```bash
mvn test
```

## Quick checks

After starting the app:

- Root endpoint: `http://localhost:8080/`
- Health endpoint: `http://localhost:8080/actuator/health`

