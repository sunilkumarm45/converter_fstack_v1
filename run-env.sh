#!/bin/zsh
# Enhanced run script with environment support
# Usage: ./run-env.sh [dev|prod|local] [SWOP_API_KEY]
# Example: ./run-env.sh dev your_api_key_here

set -e

export JAVA_HOME=$(/usr/libexec/java_home -v 21)
export PATH="$JAVA_HOME/bin:$PATH"
REPO_ROOT="../converter_fstack_v1"

# Determine environment (default to dev)
ENV=${1:-dev}
SWOP_API_KEY_ARG=${2:-}

echo "🚀 Starting Converter Full-Stack Application"
echo "==========================================="
echo "🌍 Environment: $ENV"
echo ""

# Load environment variables based on environment
case "$ENV" in
  dev)
    if [ -f "$REPO_ROOT/.env.dev" ]; then
      echo "📋 Loading development environment variables from .env.dev"
      export $(cat "$REPO_ROOT/.env.dev" | grep -v '^#' | xargs)
    fi
    export SPRING_PROFILES_ACTIVE=dev
    ;;
  prod)
    if [ -f "$REPO_ROOT/.env.prod" ]; then
      echo "📋 Loading production environment variables from .env.prod"
      export $(cat "$REPO_ROOT/.env.prod" | grep -v '^#' | xargs)
    fi
    export SPRING_PROFILES_ACTIVE=prod
    ;;
  local)
    if [ -f "$REPO_ROOT/.env.local" ]; then
      echo "📋 Loading local environment variables from .env.local"
      source "$REPO_ROOT/.env.local"
    fi
    ;;
  *)
    echo "❌ Unknown environment: $ENV"
    echo "Usage: ./run.sh [dev|prod|local]"
    exit 1
    ;;
esac

# Override SWOP_API_KEY if provided via command line
if [ -n "$SWOP_API_KEY_ARG" ]; then
  echo "🔑 Using SWOP_API_KEY from command line argument"
  export SWOP_API_KEY="$SWOP_API_KEY_ARG"
fi

# Check for SWOP_API_KEY
if [ -z "$SWOP_API_KEY" ]; then
  echo "⚠️  Warning: SWOP_API_KEY is not set"
  echo "   The application will fail when attempting currency conversions"
  echo "   Get your API key from https://swop.cx and set it in .env.$ENV"
  echo ""
  echo "   Or provide the API key as an argument:"
  echo "   ./run-env.sh $ENV YOUR_API_KEY"
  echo ""
fi

# Start backend
echo "📦 Starting Spring Boot backend on port 8080..."
cd "$REPO_ROOT/backend"
mvn spring-boot:run > /tmp/converter-backend-$ENV.log 2>&1 &
BACKEND_PID=$!
echo "   Backend PID: $BACKEND_PID"

# Start frontend
echo "🎨 Starting Vue/Vite frontend..."
cd "$REPO_ROOT/frontend"
npm run dev > /tmp/converter-frontend-$ENV.log 2>&1 &
FRONTEND_PID=$!
echo "   Frontend PID: $FRONTEND_PID"

echo ""
echo "⏳ Waiting for services to start (up to 60 seconds)..."
echo ""

# Wait for backend
for i in {1..60}; do
  if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo "✅ Backend ready on http://localhost:8080"
    break
  fi
  if [ $i -eq 60 ]; then
    echo "❌ Backend failed to start - check /tmp/converter-backend-$ENV.log"
    kill $BACKEND_PID $FRONTEND_PID 2>/dev/null
    exit 1
  fi
  sleep 1
done

# Wait for frontend
for i in {1..30}; do
  if curl -s http://localhost:5173 > /dev/null 2>&1; then
    echo "✅ Frontend ready on http://localhost:5173"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "⚠️  Frontend may still be starting - check /tmp/converter-frontend-$ENV.log"
  fi
  sleep 1
done

echo ""
echo "==========================================="
echo "✨ Application is running in $ENV mode!"
echo "==========================================="
echo ""
echo "📍 Available endpoints:"
echo "   Frontend:         http://localhost:5173"
echo "   Backend:          http://localhost:8080"
echo "   GraphQL API:      http://localhost:8080/graphql"
echo "   Health check:     http://localhost:8080/actuator/health"
echo ""
echo "🧪 Example GraphQL query:"
echo "   POST http://localhost:8080/graphql"
echo '   {"query":"{ convert(sourceCurrency: \"USD\", targetCurrency: \"EUR\", amount: 100) { convertedAmount exchangeRate } }"}'
echo ""
echo "📋 Logs:"
echo "   Backend:  tail -f /tmp/converter-backend-$ENV.log"
echo "   Frontend: tail -f /tmp/converter-frontend-$ENV.log"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Keep the script running and clean up on exit
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo; echo '👋 Services stopped'; exit 0" INT TERM

wait

