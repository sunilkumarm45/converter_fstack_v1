#!/bin/zsh
# CORS Configuration Test Script
# Tests the CORS configuration of the backend

set -e

BACKEND_URL="${1:-http://localhost:8080}"
ORIGIN="${2:-http://localhost:5173}"

echo "🔍 Testing CORS Configuration"
echo "================================"
echo "Backend URL: $BACKEND_URL"
echo "Test Origin: $ORIGIN"
echo ""

# Test 1: OPTIONS preflight request
echo "1️⃣  Testing preflight OPTIONS request..."
RESPONSE=$(curl -s -I -X OPTIONS \
  -H "Origin: $ORIGIN" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  "$BACKEND_URL/graphql" 2>&1 || true)

if echo "$RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
    ALLOWED_ORIGIN=$(echo "$RESPONSE" | grep "Access-Control-Allow-Origin" | cut -d' ' -f2 | tr -d '\r')
    echo "   ✅ CORS headers present"
    echo "   📋 Allowed Origin: $ALLOWED_ORIGIN"
else
    echo "   ❌ No CORS headers found"
    echo ""
    echo "Response:"
    echo "$RESPONSE"
    exit 1
fi

# Test 2: Check allowed methods
if echo "$RESPONSE" | grep -q "Access-Control-Allow-Methods"; then
    METHODS=$(echo "$RESPONSE" | grep "Access-Control-Allow-Methods" | cut -d' ' -f2- | tr -d '\r')
    echo "   📋 Allowed Methods: $METHODS"
else
    echo "   ⚠️  No Access-Control-Allow-Methods header"
fi

# Test 3: Check credentials
if echo "$RESPONSE" | grep -q "Access-Control-Allow-Credentials"; then
    CREDENTIALS=$(echo "$RESPONSE" | grep "Access-Control-Allow-Credentials" | cut -d' ' -f2 | tr -d '\r')
    echo "   📋 Allow Credentials: $CREDENTIALS"
else
    echo "   ⚠️  No Access-Control-Allow-Credentials header"
fi

# Test 4: Check max age
if echo "$RESPONSE" | grep -q "Access-Control-Max-Age"; then
    MAX_AGE=$(echo "$RESPONSE" | grep "Access-Control-Max-Age" | cut -d' ' -f2 | tr -d '\r')
    echo "   📋 Max Age: $MAX_AGE seconds"
else
    echo "   ⚠️  No Access-Control-Max-Age header"
fi

echo ""
echo "2️⃣  Testing actual GraphQL request with CORS..."
GRAPHQL_RESPONSE=$(curl -s -i -X POST \
  -H "Origin: $ORIGIN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __typename }"}' \
  "$BACKEND_URL/graphql" 2>&1 || true)

if echo "$GRAPHQL_RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
    echo "   ✅ CORS headers present in POST response"
else
    echo "   ❌ No CORS headers in POST response"
fi

echo ""
echo "3️⃣  Testing health endpoint..."
HEALTH_RESPONSE=$(curl -s -i -X GET \
  -H "Origin: $ORIGIN" \
  "$BACKEND_URL/actuator/health" 2>&1 || true)

if echo "$HEALTH_RESPONSE" | grep -q "Access-Control-Allow-Origin"; then
    echo "   ✅ CORS headers present in health check"
else
    echo "   ⚠️  No CORS headers in health check (may be OK if not needed)"
fi

echo ""
echo "================================"
echo "✅ CORS Configuration Test Complete"
echo ""
echo "To test with different origins:"
echo "  $0 $BACKEND_URL http://your-origin.com"
echo ""
echo "To check backend logs:"
echo "  docker logs converter_backend 2>&1 | grep -i cors"

