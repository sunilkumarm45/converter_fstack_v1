#!/bin/bash
# Quick start script for backend with API key from .env file
# This loads the .env file and starts the backend

set -e

echo "🚀 Quick Start - Converter Backend"
echo "===================================="
echo ""

# Load environment from .env file
if [ -f ".env" ]; then
    echo "📦 Loading environment from .env..."
    export $(cat .env | grep -v '^#' | grep -v '^$' | xargs)
    echo "✅ Environment loaded"
else
    echo "⚠️  No .env file found. Run 'make setup-dev' first."
    exit 1
fi

# Check if API key is set
if [ -z "$SWOP_API_KEY" ]; then
    echo "❌ SWOP_API_KEY not found in .env file"
    exit 1
fi

echo "✅ API Key configured: ${SWOP_API_KEY:0:8}...${SWOP_API_KEY: -4}"

# Configure Java 21
if [ -f "java21-env.sh" ]; then
    echo "📦 Loading Java 21 environment..."
    source java21-env.sh
fi

# Navigate to backend
cd backend

echo ""
echo "🔨 Starting backend..."
echo "   Backend: http://localhost:8080"
echo "   GraphQL: http://localhost:8080/graphql"
echo "   Health:  http://localhost:8080/actuator/health"
echo ""
echo "Press Ctrl+C to stop"
echo ""

# Start backend
mvn spring-boot:run -DskipTests

