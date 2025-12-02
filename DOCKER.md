# Running All ChatKit Examples in Docker

This guide explains how to run all 4 ChatKit examples in a single Docker container.

## Prerequisites

1. **Docker Desktop** installed and running
   - Download from: https://www.docker.com/products/docker-desktop
   - Make sure Docker Desktop is running (check the menu bar icon)

2. **OpenAI API Key**
   - Get your key from: https://platform.openai.com/api-keys
   - See [ENV_SETUP.md](ENV_SETUP.md) for detailed setup instructions

## Quick Start

### Step 1: Set Up Environment Variables

**Option A: Interactive Setup (Recommended)**
```bash
./setup-env.sh
```

**Option B: Manual Setup**
```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your OpenAI API key
nano .env
```

**Option C: Export in Terminal**
```bash
export OPENAI_API_KEY=sk-proj-your-key-here
```

See [ENV_SETUP.md](ENV_SETUP.md) for more details.

### Step 2: Check Docker Status

```bash
./test-docker.sh
```

This will verify:
- ✅ Docker is installed
- ✅ Docker daemon is running
- ✅ Image status
- ✅ Container status

### Step 3: Build and Run

```bash
# The script will automatically load .env if it exists
./run-docker.sh
```

### Step 3: Open in Browser

Once the container is running, open your browser to:

- **Landing page**: http://localhost/
- **Cat Lounge**: http://localhost/cat-lounge/
- **Customer Support**: http://localhost/customer-support/
- **Metro Map**: http://localhost/metro-map/
- **News Guide**: http://localhost/news-guide/

## Manual Commands

If you prefer to run commands manually:

```bash
# Build the image
docker build -t chatkit-examples .

# Run the container
docker run --name chatkit-examples \
  -p 80:80 \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  chatkit-examples

# Stop the container
docker stop chatkit-examples

# Remove the container
docker rm chatkit-examples

# View logs
docker logs chatkit-examples

# View logs in real-time
docker logs -f chatkit-examples
```

## Troubleshooting

### Docker is not running

**Error**: `Cannot connect to the Docker daemon`

**Solution**:
```bash
# Start Docker Desktop
open /Applications/Docker.app

# Wait 30-60 seconds for Docker to fully start
# Check the menu bar icon - it should say "Docker Desktop is running"

# Verify Docker is ready
docker ps
```

### Port 80 is already in use

**Error**: `Bind for 0.0.0.0:80 failed: port is already allocated`

**Solution**: Use a different port:
```bash
docker run --name chatkit-examples \
  -p 8080:80 \
  -e OPENAI_API_KEY=$OPENAI_API_KEY \
  chatkit-examples
```

Then access at: http://localhost:8080/

### Container won't start

**Check logs**:
```bash
docker logs chatkit-examples
```

**Common issues**:
- Missing OPENAI_API_KEY
- Invalid API key
- Port conflicts

### Rebuild the image

If you made changes to the code:
```bash
# Stop and remove old container
docker stop chatkit-examples
docker rm chatkit-examples

# Rebuild the image
docker build -t chatkit-examples . --no-cache

# Run again
./run-docker.sh
```

## Architecture

The Docker container runs:
- **nginx** (port 80) - Reverse proxy and static file server
- **4 FastAPI backends** (ports 8000-8003 internally)
  - Cat Lounge: 8000
  - Customer Support: 8001
  - Metro Map: 8002
  - News Guide: 8003
- **supervisord** - Process manager for all services

All services start automatically when the container starts.

## Development

To see what's happening inside the container:

```bash
# Execute a shell inside the running container
docker exec -it chatkit-examples bash

# Check supervisor status
docker exec chatkit-examples supervisorctl status

# Check nginx logs
docker exec chatkit-examples tail -f /var/log/nginx/access.log
docker exec chatkit-examples tail -f /var/log/nginx/error.log
```

## Stopping the Container

Press `Ctrl+C` in the terminal where the container is running, or:

```bash
docker stop chatkit-examples
```

To remove the container completely:

```bash
docker rm chatkit-examples
```

