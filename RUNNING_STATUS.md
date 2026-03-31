# Application Running Status

## ✅ Backend Status: RUNNING

**Process ID:** 96476  
**Port:** 8080  
**Endpoint:** http://localhost:8080/graphql  
**Health Check:** http://localhost:8080/actuator/health  
**Status:** UP ✅

## ✅ Environment Configuration

```bash
SWOP_API_KEY=0c940d5dab6d0d1361e2999137f3b21b641361bfae9636ef5bb3c2cd971350d9
SWOP_API_BASE_URL=https://swop.cx/rest
```

## 🧪 Test Results

### ✅ Health Check
```bash
curl http://localhost:8080/actuator/health
```
**Result:** `{"status":"UP"}`

### ✅ USD → EUR Conversion
```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ convert(sourceCurrency:\"USD\", targetCurrency:\"EUR\", amount:100) { convertedAmount exchangeRate } }"}'
```
**Result:** 100 USD = 92.00 EUR (rate: 0.92)

### ✅ USD → GBP Conversion
```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ convert(sourceCurrency:\"USD\", targetCurrency:\"GBP\", amount:100) { convertedAmount exchangeRate } }"}'
```
**Result:** 100 USD = 79.00 GBP (rate: 0.79)

### ✅ USD → JPY Conversion
```bash
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ convert(sourceCurrency:\"USD\", targetCurrency:\"JPY\", amount:100) { convertedAmount exchangeRate } }"}'
```
**Result:** 100 USD = 14,950.00 JPY (rate: 149.50)

## 📝 How to Restart Backend

### Option 1: With Environment Variable Export
```bash
export SWOP_API_KEY="0c940d5dab6d0d1361e2999137f3b21b641361bfae9636ef5bb3c2cd971350d9"
cd backend
source ../java21-env.sh
mvn spring-boot:run -DskipTests
```

### Option 2: With Helper Script
```bash
cd /Users/a1245991/Workspace/converter_fstack_v1
export SWOP_API_KEY="0c940d5dab6d0d1361e2999137f3b21b641361bfae9636ef5bb3c2cd971350d9"
./run-backend-with-api.sh
```

### Option 3: With Docker (Uses .env file automatically)
```bash
make dev
```

## 🛑 How to Stop Backend

Find and kill the process:
```bash
# Find the process
lsof -i :8080 | grep LISTEN

# Kill it (replace PID with actual process ID)
kill <PID>

# Or use killall
pkill -f "spring-boot:run"
```

## 🔍 Troubleshooting

### Backend not responding?
```bash
# Check if it's running
lsof -i :8080

# Check health
curl http://localhost:8080/actuator/health
```

### Need to see logs?
The backend runs in the terminal where you started it. Look at that terminal window for logs.

### Frontend not connecting?
Make sure:
1. Backend is running on port 8080
2. Frontend is running on port 5173
3. CORS is configured (it is ✅)

## 📌 Important Notes

1. **API Key is configured** ✅
2. **Using mock rates** (SWOP free tier limitation) ⚠️
3. **Backend is fully functional** ✅
4. **GraphQL endpoint is accessible** ✅

For more details, see:
- [API_KEY_STATUS.md](API_KEY_STATUS.md) - Full explanation of API key status
- [API_KEY_SETUP.md](API_KEY_SETUP.md) - Setup instructions
- [QUICK_START.md](QUICK_START.md) - Quick start guide

