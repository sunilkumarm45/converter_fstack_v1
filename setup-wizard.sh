#!/bin/zsh
# Quick setup helper for first-time users
# This script guides you through the initial setup

set -e

REPO_ROOT="../converter_fstack_v1"
cd "$REPO_ROOT"

echo "🎯 Converter Full-Stack - First Time Setup"
echo "============================================"
echo ""

# Step 1: Choose environment
echo "1️⃣  Choose your environment:"
echo "   [1] Development (recommended for first-time setup)"
echo "   [2] Production"
echo ""
read "?Select (1 or 2): " ENV_CHOICE

if [ "$ENV_CHOICE" = "2" ]; then
    ENV="prod"
    ENV_NAME="Production"
else
    ENV="dev"
    ENV_NAME="Development"
fi

echo ""
echo "Selected: $ENV_NAME"
echo ""

# Step 2: Create .env file
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists"
    read "?Overwrite with $ENV_NAME template? (y/N): " OVERWRITE
    if [[ $OVERWRITE =~ ^[Yy]$ ]]; then
        cp ".env.$ENV" .env
        echo "✅ Created .env from .env.$ENV"
    else
        echo "ℹ️  Keeping existing .env file"
    fi
else
    cp ".env.$ENV" .env
    echo "✅ Created .env from .env.$ENV"
fi

echo ""

# Step 3: Get API key
echo "2️⃣  SWOP API Key Setup"
echo ""
echo "You need an API key from https://swop.cx"
echo ""
read "?Do you have a SWOP API key? (y/N): " HAS_KEY

if [[ $HAS_KEY =~ ^[Yy]$ ]]; then
    echo ""
    read "?Enter your SWOP_API_KEY: " USER_KEY

    if [ -n "$USER_KEY" ]; then
        # Update the .env file
        if grep -q "^SWOP_API_KEY=" .env; then
            # Replace existing line (macOS compatible)
            sed -i '' "s|^SWOP_API_KEY=.*|SWOP_API_KEY=$USER_KEY|" .env
            echo "✅ Added SWOP_API_KEY to .env"
        else
            echo "SWOP_API_KEY=$USER_KEY" >> .env
            echo "✅ Added SWOP_API_KEY to .env"
        fi
    else
        echo "⚠️  No key provided - you'll need to edit .env manually"
        echo "   nano .env"
    fi
else
    echo ""
    echo "ℹ️  To get your API key:"
    echo "   1. Visit https://swop.cx"
    echo "   2. Sign up for an account"
    echo "   3. Get your API key from the dashboard"
    echo "   4. Edit .env and add: SWOP_API_KEY=your_key_here"
    echo ""
    echo "   Command: nano .env"
fi

echo ""

# Step 4: Production security check
if [ "$ENV" = "prod" ]; then
    echo "3️⃣  Production Security Setup"
    echo ""
    echo "⚠️  IMPORTANT: Change default passwords in .env"
    echo ""
    echo "   Required changes:"
    echo "   - DOCKER_INFLUXDB_INIT_PASSWORD (currently: adminpassword)"
    echo "   - INFLUX_TOKEN (currently: default-token)"
    echo "   - GF_SECURITY_ADMIN_PASSWORD (currently: admin)"
    echo ""
    read "?Open .env for editing now? (y/N): " EDIT_NOW

    if [[ $EDIT_NOW =~ ^[Yy]$ ]]; then
        ${EDITOR:-nano} .env
    else
        echo "   Remember to edit .env before deploying!"
    fi
    echo ""
fi

# Step 5: Check dependencies
echo "4️⃣  Checking dependencies..."
echo ""

MISSING_DEPS=0

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found - needed for Docker Compose"
    echo "   Install from: https://www.docker.com/products/docker-desktop"
    MISSING_DEPS=1
else
    echo "✅ Docker is installed"
fi

if ! command -v java &> /dev/null; then
    echo "⚠️  Java not found - needed for local backend development"
    MISSING_DEPS=1
else
    echo "✅ Java is installed"
fi

if ! command -v mvn &> /dev/null; then
    echo "⚠️  Maven not found - needed for local backend development"
    MISSING_DEPS=1
else
    echo "✅ Maven is installed"
fi

if ! command -v node &> /dev/null; then
    echo "⚠️  Node.js not found - needed for frontend development"
    MISSING_DEPS=1
else
    echo "✅ Node.js is installed"
fi

echo ""

# Step 6: Summary
echo "============================================"
echo "✨ Setup Summary"
echo "============================================"
echo ""
echo "Environment: $ENV_NAME"
echo "Config file: .env (created from .env.$ENV)"
echo ""

if [ -f ".env" ] && grep -q "^SWOP_API_KEY=..*" .env; then
    echo "✅ SWOP_API_KEY is configured"
else
    echo "⚠️  SWOP_API_KEY needs to be set in .env"
fi

echo ""
echo "📚 Documentation:"
echo "   Quick Start:  cat ENV_SETUP.md"
echo "   Full Guide:   cat ENVIRONMENT_GUIDE.md"
echo ""

if [ $MISSING_DEPS -eq 0 ]; then
    echo "🚀 Ready to start!"
    echo ""
    echo "   Start with Docker:  ./run-docker.sh $ENV"
    echo "   Start locally:      ./run-env.sh $ENV"
    echo "   Validate config:    ./validate-env.sh $ENV"
else
    echo "⚠️  Some dependencies are missing"
    echo "   Install missing tools to get started"
fi

echo ""

