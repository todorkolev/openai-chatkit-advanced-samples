#!/bin/bash
set -e

echo "🐳 ChatKit Examples Docker Setup"
echo "================================="
echo ""

# Load environment variables from .env file if it exists
if [ -f .env ]; then
  echo "📄 Loading environment variables from .env file..."
  set -a
  source .env
  set +a
  echo "✅ Environment variables loaded"
  echo ""
fi

# Check if Docker is running
echo "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo ""
    echo "Please start Docker Desktop and try again."
    echo "You can start it by running:"
    echo "  open /Applications/Docker.app"
    echo ""
    echo "Wait for Docker to fully start (check the menu bar icon),"
    echo "then run this script again."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Check if image exists
if docker images chatkit-examples | grep -q chatkit-examples; then
    echo "📦 Image 'chatkit-examples' already exists"
    read -p "Do you want to rebuild it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping build..."
    else
        echo ""
        echo "🔨 Building ChatKit Examples Docker image..."
        echo "This may take 5-10 minutes on first build..."
        echo ""
        docker build -t chatkit-examples . --progress=plain
        echo ""
        echo "✅ Build complete!"
    fi
else
    echo "🔨 Building ChatKit Examples Docker image..."
    echo "This may take 5-10 minutes on first build..."
    echo ""
    docker build -t chatkit-examples . --progress=plain
    echo ""
    echo "✅ Build complete!"
fi

echo ""
echo "🚀 Starting container..."
echo ""

# Check if OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OPENAI_API_KEY not set!"
    echo ""
    echo "Please set your OpenAI API key in one of these ways:"
    echo "  1. Add it to the .env file:"
    echo "     OPENAI_API_KEY=sk-proj-your-key-here"
    echo ""
    echo "  2. Export it in your terminal:"
    echo "     export OPENAI_API_KEY=sk-proj-your-key-here"
    echo ""
    echo "Get your API key from: https://platform.openai.com/api-keys"
    echo ""
    exit 1
fi

# Stop any existing container
if docker ps -a | grep -q chatkit-examples; then
    echo "Stopping existing container..."
    docker stop chatkit-examples 2>/dev/null || true
    docker rm chatkit-examples 2>/dev/null || true
fi

echo "Starting container..."
echo ""
echo "📍 Access the app at: http://localhost"
echo ""
echo "Available examples:"
echo "  • http://localhost/cat-lounge/"
echo "  • http://localhost/customer-support/"
echo "  • http://localhost/metro-map/"
echo "  • http://localhost/news-guide/"
echo ""
echo "Press Ctrl+C to stop the container"
echo ""

docker run --name chatkit-examples -p 80:80 -e OPENAI_API_KEY="$OPENAI_API_KEY" chatkit-examples

