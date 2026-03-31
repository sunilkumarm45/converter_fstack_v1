# SWOP API Key Setup

## Quick Fix for "Failed to fetch" Error

The "Failed to fetch" error occurs when:
1. The backend cannot connect to the SWOP currency API
2. The `SWOP_API_KEY` environment variable is not set

## Solution

### Option 1: Get a Free API Key (Recommended)

1. **Sign up at https://swop.cx**
2. **Get your API key** from the dashboard
3. **Set the environment variable:**

```bash
export SWOP_API_KEY="your-api-key-here"
```

4. **Restart the backend:**

```bash
cd backend
export JAVA_HOME=/Users/a1245991/Downloads/amazon-corretto-21.jdk/Contents/Home
mvn spring-boot:run -DskipTests
```

### Option 2: Use Docker with Environment File

1. **Create `.env` file** in the project root:

```bash
SWOP_API_KEY=your-api-key-here
```

2. **Run with Docker:**

```bash
docker-compose up --build
```

### Option 3: Set in IDE Run Configuration

If running from IntelliJ IDEA or similar:

1. Go to Run → Edit Configurations
2. Add environment variable: `SWOP_API_KEY=your-api-key-here`
3. Run the application

## Verify It's Working

Test the conversion endpoint:

```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ convert(sourceCurrency:\"USD\", targetCurrency:\"EUR\", amount:100) { convertedAmount exchangeRate } }"
  }'
```

You should see a valid response with exchange rates.

## Current Status

✅ **CORS Configuration** - Added and working  
✅ **Apollo Client** - Fixed and configured  
✅ **Backend** - Running on http://localhost:8080  
✅ **Frontend** - Running on http://localhost:5173  
⚠️ **API Key** - Needs to be configured

## Troubleshooting

### Backend not starting?

Make sure JAVA_HOME is set:

```bash
export JAVA_HOME=/Users/a1245991/Downloads/amazon-corretto-21.jdk/Contents/Home
export PATH="$JAVA_HOME/bin:$PATH"
```

### Frontend can't connect?

1. Check backend is running: `curl http://localhost:8080/actuator/health`
2. Check frontend is on http://localhost:5173
3. Check browser console for errors

### Still getting errors?

The backend will work without an API key, but it will return fallback error messages. To get real currency conversion data, you must set the `SWOP_API_KEY`.

