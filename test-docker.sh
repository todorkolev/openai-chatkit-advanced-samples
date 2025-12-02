#!/bin/bash

echo "🔍 Docker Environment Check"
echo "============================"
echo ""

# Check if Docker command exists
if ! command -v docker &> /dev/null; then
    echo "❌ Docker command not found"
    echo "Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "✅ Docker command found"
echo ""

# Check if Docker daemon is running
echo "Checking Docker daemon..."
if docker info > /dev/null 2>&1; then
    echo "✅ Docker daemon is running"
    echo ""
    
    # Show Docker version
    echo "Docker version:"
    docker version --format '  Client: {{.Client.Version}}'
    docker version --format '  Server: {{.Server.Version}}'
    echo ""
    
    # Check if image exists
    if docker images chatkit-examples | grep -q chatkit-examples; then
        echo "✅ Image 'chatkit-examples' exists"
        docker images chatkit-examples --format "  Size: {{.Size}}"
    else
        echo "⚠️  Image 'chatkit-examples' not found"
        echo "  Run './run-docker.sh' to build it"
    fi
    echo ""
    
    # Check if container is running
    if docker ps | grep -q chatkit-examples; then
        echo "✅ Container 'chatkit-examples' is running"
        docker ps --filter name=chatkit-examples --format "  Ports: {{.Ports}}"
        echo ""
        echo "🌐 Access the app at: http://localhost"
    else
        echo "⚠️  Container 'chatkit-examples' is not running"
        echo "  Run './run-docker.sh' to start it"
    fi
    
else
    echo "❌ Docker daemon is not running"
    echo ""
    echo "To start Docker:"
    echo "  1. Open Docker Desktop from Applications"
    echo "  2. Wait for the Docker icon in the menu bar to show 'Docker Desktop is running'"
    echo "  3. Run this script again"
    echo ""
    echo "Or run: open /Applications/Docker.app"
    exit 1
fi

echo ""
echo "Environment check complete!"

