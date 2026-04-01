#!/bin/zsh
# Check Docker and Docker Compose status
# Usage: ./check-docker-status.sh

echo "🔍 Checking Docker Installation & Status"
echo "=========================================="
echo ""

# Check if Docker CLI is installed
echo "1️⃣  Docker CLI Installation:"
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>&1)
    echo "   ✅ Docker CLI installed: $DOCKER_VERSION"
else
    echo "   ❌ Docker CLI not found"
    echo "   📥 Install Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo ""

# Check if Docker daemon is running
echo "2️⃣  Docker Daemon Status:"
if docker info &> /dev/null; then
    echo "   ✅ Docker daemon is running"
    DOCKER_SERVER_VERSION=$(docker version --format '{{.Server.Version}}' 2>&1)
    echo "   🐳 Server Version: $DOCKER_SERVER_VERSION"

    # Show some basic info
    DOCKER_CPUS=$(docker info --format '{{.NCPU}}' 2>&1)
    DOCKER_MEM=$(docker info --format '{{.MemTotal}}' 2>&1)
    echo "   💻 CPUs: $DOCKER_CPUS"
    echo "   🧠 Memory: $(echo "$DOCKER_MEM / 1024 / 1024 / 1024" | bc)GB"
else
    echo "   ❌ Docker daemon is NOT running"
    echo ""
    echo "   💡 To start Docker Desktop:"
    echo "      • Option 1: Open Docker Desktop from Applications"
    echo "      • Option 2: Run: open -a Docker"
    echo ""
    echo "   ⏳ Attempting to start Docker Desktop..."
    if open -a Docker 2>/dev/null; then
        echo "   ✅ Docker Desktop is starting..."
        echo "   ⏰ Please wait 10-30 seconds for it to fully start"
        echo "   🔄 Then run this script again to verify"
    else
        echo "   ⚠️  Could not start Docker Desktop"
        echo "   Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    fi
    exit 1
fi
echo ""

# Check if Docker Compose is available
echo "3️⃣  Docker Compose Status:"
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version 2>&1)
    echo "   ✅ Docker Compose v2: $COMPOSE_VERSION"
elif command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version 2>&1)
    echo "   ✅ Docker Compose v1: $COMPOSE_VERSION"
else
    echo "   ❌ Docker Compose not found"
    echo "   📥 Install: brew install docker-compose"
    exit 1
fi
echo ""

# Check for running containers
echo "4️⃣  Running Containers:"
RUNNING_CONTAINERS=$(docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>&1)
CONTAINER_COUNT=$(docker ps -q 2>&1 | wc -l | xargs)
if [ "$CONTAINER_COUNT" -gt 0 ]; then
    echo "   🟢 $CONTAINER_COUNT container(s) running:"
    echo "$RUNNING_CONTAINERS" | sed 's/^/      /'
else
    echo "   ⚪ No containers currently running"
fi
echo ""

# Summary
echo "✅ Docker Environment Ready!"
echo ""
echo "📝 Next Steps:"
echo "   • To start the app in dev mode:"
echo "     ./run-docker.sh dev YOUR_API_KEY"
echo ""
echo "   • To start the app in production mode:"
echo "     ./run-docker.sh prod YOUR_API_KEY"
echo ""
echo "   • Get your API key from: https://swop.cx"
echo ""

