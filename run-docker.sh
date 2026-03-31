#!/bin/zsh
# Docker Compose wrapper with environment support
# Usage: ./run-docker.sh [dev|prod]

set -e

REPO_ROOT="/Users/a1245991/Workspace/converter_fstack_v1"
cd "$REPO_ROOT"

# Determine environment (default to dev)
ENV=${1:-dev}

echo "🐳 Starting Docker Compose Stack"
echo "==========================================="
echo "🌍 Environment: $ENV"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed or not in PATH"
    echo "   Please install Docker Desktop for macOS"
    exit 1
fi

# Check if .env file exists
ENV_FILE=".env.$ENV"
if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Environment file not found: $ENV_FILE"
    echo "   Please create it from the template and fill in your values"
    echo ""
    echo "   Example:"
    echo "   cp .env.$ENV .env.$ENV"
    echo "   # Edit .env.$ENV and add your SWOP_API_KEY"
    exit 1
fi

# Check for required SWOP_API_KEY
if ! grep -q "^SWOP_API_KEY=..*" "$ENV_FILE"; then
    echo "⚠️  Warning: SWOP_API_KEY is not set in $ENV_FILE"
    echo "   The application will fail when attempting currency conversions"
    echo "   Get your API key from https://swop.cx"
    echo ""
    read "?Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Select docker-compose file
COMPOSE_FILE="docker-compose.$ENV.yml"
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Docker Compose file not found: $COMPOSE_FILE"
    exit 1
fi

echo "📋 Using configuration: $COMPOSE_FILE"
echo "📋 Using environment: $ENV_FILE"
echo ""

# Run docker compose
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up --build

# Cleanup on exit
trap "docker compose -f $COMPOSE_FILE down; echo; echo '👋 Docker stack stopped'" INT TERM

