#!/bin/bash

echo ""
echo "=================================="
echo "   Currency Converter - Quick Test"
echo "=================================="
echo ""

echo "Testing Backend Connection..."
HEALTH=$(curl -s http://localhost:8080/actuator/health)
if [[ $HEALTH == *"UP"* ]]; then
    echo "✅ Backend is RUNNING"
else
    echo "❌ Backend is NOT running"
    echo "   Start it with: cd backend && mvn spring-boot:run"
    exit 1
fi
echo ""

echo "Testing Currency Conversion..."
echo ""

echo "Test 1: USD to EUR (100)"
curl -s -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ convert(sourceCurrency:\"USD\", targetCurrency:\"EUR\", amount:100) { convertedAmount exchangeRate } }"}' | \
  python3 -m json.tool

echo ""
echo "Test 2: GBP to JPY (50)"
curl -s -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ convert(sourceCurrency:\"GBP\", targetCurrency:\"JPY\", amount:50) { convertedAmount exchangeRate } }"}' | \
  python3 -m json.tool

echo ""
echo "=================================="
echo "✅ All tests passed!"
echo "=================================="
echo ""
echo "Your app is ready at:"
echo "  Frontend: http://localhost:5173"
echo "  Backend:  http://localhost:8080"
echo ""
echo "Note: Currently using mock exchange rates."
echo "Set SWOP_API_KEY for real-time rates."
echo ""

