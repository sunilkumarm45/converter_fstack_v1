#!/bin/bash
# Script to run the backend with SWOP API key
# Usage: ./run-backend-with-api.sh [your-api-key]

echo "🚀 Starting Backend with SWOP API"
echo "================================="
echo ""

# Check if API key is provided as argument
if [ ! -z "$1" ]; then
    export SWOP_API_KEY="$1"
    echo "✅ Using API key from command line argument"
elif [ ! -z "$SWOP_API_KEY" ]; then
    echo "✅ Using API key from environment: ${SWOP_API_KEY:0:8}...${SWOP_API_KEY: -4}"
else
    echo "❌ ERROR: SWOP_API_KEY not provided!"
    echo ""
    echo "Usage:"
    echo "  1. Pass as argument:      ./run-backend-with-api.sh YOUR_API_KEY"
    echo "  2. Export first:          export SWOP_API_KEY=YOUR_API_KEY && ./run-backend-with-api.sh"
    echo "  3. Use .env with Docker:  make dev"
    echo ""
    echo "Get your API key from: https://swop.cx"
    exit 1
fi

# Configure Java 21
echo ""
echo "📦 Configuring Java 21..."
if [ -f "java21-env.sh" ]; then
    source java21-env.sh
else
    echo "⚠️  java21-env.sh not found, using system Java"
fi

# Navigate to backend directory
cd "$(dirname "$0")/backend" || exit 1

echo ""
echo "🔨 Compiling backend..."
mvn clean compile -q

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed! Check the errors above."
    exit 1
fi

echo "✅ Compilation successful"
echo ""
echo "🌐 Starting Spring Boot application..."
echo "   Backend will be available at: http://localhost:8080"
echo "   GraphQL endpoint: http://localhost:8080/graphql"
echo "   Health check: http://localhost:8080/actuator/health"
echo ""
echo "   Press Ctrl+C to stop"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Start the application
mvn spring-boot:run

