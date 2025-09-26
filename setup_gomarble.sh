#!/bin/bash

# GoMarble MCP + LibreChat Setup Script
# Run this script after Docker is installed

set -e  # Exit on any error

echo "🚀 GoMarble MCP + LibreChat Setup Script"
echo "========================================"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first:"
    echo "   Refer to GOMARBLE_INTEGRATION_SETUP.md for installation instructions"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose plugin"
    exit 1
fi

echo "✅ Docker and Docker Compose found"

# Set UID and GID if not already set
if ! grep -q "UID=" .env; then
    echo "Setting UID=$(id -u) in .env"
    echo "UID=$(id -u)" >> .env
fi

if ! grep -q "GID=" .env; then
    echo "Setting GID=$(id -g) in .env"
    echo "GID=$(id -g)" >> .env
fi

echo "✅ UID/GID configured"

# Check if GoMarble API key is set
if grep -q "your_gomarble_api_key_here" .env; then
    echo "⚠️  GoMarble API key not configured"
    echo "   Please:"
    echo "   1. Go to apps.gomarble.ai"
    echo "   2. Login and copy your API key"
    echo "   3. Replace 'your_gomarble_api_key_here' in .env file"
    echo ""
    read -p "Have you set your GoMarble API key? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Please set your API key before continuing"
        exit 1
    fi
fi

echo "✅ Environment configured"

# Build and start LibreChat
echo "🔧 Building and starting LibreChat..."
docker compose up -d

echo "📊 Checking service status..."
sleep 10
docker compose ps

echo ""
echo "🎉 Setup Complete!"
echo "========================================"
echo "📱 LibreChat is available at: http://localhost:3080"
echo ""
echo "🧪 Test GoMarble integration with these prompts:"
echo "   • Give me the ROAS of my Facebook Ad Accounts in the past week"
echo "   • Analyze which audience segments have the highest ROAS across Facebook Ads and Google Ads"
echo "   • Generate a weekly performance report comparing my Google Ads and Facebook Ads campaigns"
echo ""
echo "📋 To view logs:"
echo "   docker compose logs -f api"
echo ""
echo "🛑 To stop services:"
echo "   docker compose down"