#!/bin/zsh
# Docker Compose wrapper with environment support
# Usage: ./run-docker.sh [dev|prod] [SWOP_API_KEY]
# Example: ./run-docker.sh dev your_api_key_here

set -e

REPO_ROOT="../converter_fstack_v1"
cd "$REPO_ROOT"

# Determine environment (default to dev)
ENV=${1:-dev}
SWOP_API_KEY_ARG=${2:-}

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

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo "❌ Docker daemon is not running"
    echo ""
    echo "   On macOS, you need to start Docker Desktop:"
    echo "   • Open Docker Desktop from Applications"
    echo "   • Or run: open -a Docker"
    echo "   • Wait for Docker to finish starting (look for the whale icon in menu bar)"
    echo ""
    echo "   Starting Docker Desktop automatically..."

    # Try to start Docker Desktop
    if open -a Docker 2>/dev/null; then
        echo "   ⏳ Docker Desktop is starting..."
        echo "   Please wait for it to finish starting and run this script again."
        echo ""
        echo "   You can check Docker status with: docker info"
        echo "   Once ready, run: ./run-docker.sh $ENV ${2:+$2}"
    else
        echo "   ⚠️  Could not start Docker Desktop automatically"
        echo "   Please start it manually from your Applications folder"
    fi
    exit 1
fi
echo "✅ Docker daemon is running"
echo ""

# Detect which Docker Compose command to use
DOCKER_COMPOSE_CMD=""
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
    echo "✅ Using Docker Compose v2 (docker compose)"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker-compose"
    echo "✅ Using Docker Compose v1 (docker-compose)"
else
    echo "❌ Docker Compose is not available"
    echo ""
    echo "   Please install Docker Compose:"
    echo "   • For macOS with Homebrew:"
    echo "     brew install docker-compose"
    echo ""
    echo "   • Or install Docker Desktop which includes Compose v2"
    echo "   • Or install the Docker Compose plugin:"
    echo "     mkdir -p ~/.docker/cli-plugins"
    echo "     curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-darwin-$(uname -m) -o ~/.docker/cli-plugins/docker-compose"
    echo "     chmod +x ~/.docker/cli-plugins/docker-compose"
    exit 1
fi
echo ""

# Check if .env file exists
ENV_FILE=".env.$ENV"
TEMP_ENV_FILE=""

# If API key provided via command line, create a temporary env file
if [ -n "$SWOP_API_KEY_ARG" ]; then
    echo "🔑 Using SWOP_API_KEY from command line argument"
    TEMP_ENV_FILE="/tmp/.env.$ENV.$$"

    # Copy existing env file or create new one
    if [ -f "$ENV_FILE" ]; then
        cp "$ENV_FILE" "$TEMP_ENV_FILE"
        # Replace or append SWOP_API_KEY
        if grep -q "^SWOP_API_KEY=" "$TEMP_ENV_FILE"; then
            sed -i '' "s|^SWOP_API_KEY=.*|SWOP_API_KEY=$SWOP_API_KEY_ARG|" "$TEMP_ENV_FILE"
        else
            echo "SWOP_API_KEY=$SWOP_API_KEY_ARG" >> "$TEMP_ENV_FILE"
        fi
    else
        echo "SWOP_API_KEY=$SWOP_API_KEY_ARG" > "$TEMP_ENV_FILE"
    fi

    ENV_FILE="$TEMP_ENV_FILE"
elif [ ! -f "$ENV_FILE" ]; then
    echo "❌ Environment file not found: $ENV_FILE"
    echo "   Please create it from the template and fill in your values"
    echo ""
    echo "   Example:"
    echo "   cp .env.$ENV .env.$ENV"
    echo "   # Edit .env.$ENV and add your SWOP_API_KEY"
    echo ""
    echo "   Or provide the API key as an argument:"
    echo "   ./run-docker.sh $ENV YOUR_API_KEY"
    exit 1
fi

# Check for required SWOP_API_KEY
if ! grep -q "^SWOP_API_KEY=..*" "$ENV_FILE"; then
    echo "⚠️  Warning: SWOP_API_KEY is not set in $ENV_FILE"
    echo "   The application will fail when attempting currency conversions"
    echo "   Get your API key from https://swop.cx"
    echo ""
    echo "   You can also provide the API key as an argument:"
    echo "   ./run-docker.sh $ENV YOUR_API_KEY"
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

# Run docker compose (using eval to properly handle multi-word commands)
eval "$DOCKER_COMPOSE_CMD -f \"$COMPOSE_FILE\" --env-file \"$ENV_FILE\" up --build"

# Cleanup on exit
cleanup() {
    eval "$DOCKER_COMPOSE_CMD -f \"$COMPOSE_FILE\" down"
    [ -n "$TEMP_ENV_FILE" ] && [ -f "$TEMP_ENV_FILE" ] && rm -f "$TEMP_ENV_FILE"
    echo
    echo '👋 Docker stack stopped'
}

trap "cleanup" INT TERM EXIT

