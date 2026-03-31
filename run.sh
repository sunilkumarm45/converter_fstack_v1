#!/bin/zsh
set -e

export JAVA_HOME="/Users/a1245991/Downloads/amazon-corretto-21.jdk/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
REPO_ROOT="/Users/a1245991/Workspace/converter_fstack_v1"

echo "🚀 Starting Converter Full-Stack Application"
echo "==========================================="
echo ""

# Start backend
echo "📦 Starting Spring Boot backend on port 8080..."
cd "$REPO_ROOT/backend"
mvn spring-boot:run > /tmp/converter-backend.log 2>&1 &
BACKEND_PID=$!
echo "   Backend PID: $BACKEND_PID"

# Start frontend
echo "🎨 Starting Vue/Vite frontend on port 5173..."
cd "$REPO_ROOT/frontend"
npm run dev > /tmp/converter-frontend.log 2>&1 &
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
    echo "❌ Backend failed to start - check /tmp/converter-backend.log"
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
    echo "⚠️  Frontend may still be starting - check /tmp/converter-frontend.log"
  fi
  sleep 1
done

echo ""
echo "==========================================="
echo "✨ Application is running!"
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
echo "   Backend:  tail -f /tmp/converter-backend.log"
echo "   Frontend: tail -f /tmp/converter-frontend.log"
echo ""
echo "Press Ctrl+C to stop all services"
echo ""

# Keep the script running and clean up on exit
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo; echo '👋 Services stopped'; exit 0" INT TERM

wait

