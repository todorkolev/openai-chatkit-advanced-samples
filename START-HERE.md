# 🚀 Start Here - Running ChatKit Examples

## Current Status

✅ **Dockerfile created** - Multi-stage build for all 4 examples  
✅ **Helper scripts created** - Easy setup and testing  
✅ **Documentation created** - Complete guide in DOCKER.md  

⚠️ **Docker needs to be started** - See instructions below

---

## Next Steps

### 1️⃣ Start Docker Desktop

Docker is currently not running. Start it:

```bash
open /Applications/Docker.app
```

**Wait 30-60 seconds** for Docker to fully start. You'll see a whale icon in your menu bar that says "Docker Desktop is running".

### 2️⃣ Verify Docker is Ready

```bash
./test-docker.sh
```

You should see:
```
✅ Docker command found
✅ Docker daemon is running
```

### 3️⃣ Set Your OpenAI API Key

**Option A: Interactive Setup (Easiest)**
```bash
./setup-env.sh
```

**Option B: Create .env file**
```bash
cp .env.example .env
# Edit .env and add your key
```

**Option C: Export in terminal**
```bash
export OPENAI_API_KEY=sk-proj-your-actual-key-here
```

📚 See [ENV_SETUP.md](ENV_SETUP.md) for detailed instructions

### 4️⃣ Build and Run

```bash
./run-docker.sh
```

This will:
- Build the Docker image (5-10 minutes first time)
- Start all 4 examples in one container
- Show you the URLs to access

### 5️⃣ Open in Browser

Go to: **http://localhost/**

You'll see a landing page with links to all 4 examples:
- 🐱 Cat Lounge
- ✈️ Customer Support
- 🚇 Metro Map
- 📰 News Guide

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `./test-docker.sh` | Check Docker status |
| `./run-docker.sh` | Build and run everything |
| `docker ps` | See running containers |
| `docker logs chatkit-examples` | View container logs |
| `docker stop chatkit-examples` | Stop the container |

---

## Files Created

- **`Dockerfile`** - Multi-stage build configuration
- **`run-docker.sh`** - Main script to build and run
- **`test-docker.sh`** - Docker environment checker
- **`setup-env.sh`** - Interactive environment setup
- **`.env.example`** - Example environment variables
- **`.env`** - Your environment variables (git-ignored)
- **`ENV_SETUP.md`** - Environment setup guide
- **`DOCKER.md`** - Complete documentation
- **`START-HERE.md`** - This file

---

## Troubleshooting

### Docker won't start?

Try:
```bash
# Force restart Docker
pkill -9 Docker
sleep 3
open /Applications/Docker.app
```

Wait 60 seconds, then run `./test-docker.sh` again.

### Port 80 already in use?

Edit `run-docker.sh` and change `-p 80:80` to `-p 8080:80`, then access at http://localhost:8080/

### Need more help?

See **DOCKER.md** for detailed troubleshooting and manual commands.

---

## What's Inside the Container?

- **nginx** - Routes requests to the right backend
- **4 React frontends** - Built and served as static files
- **4 FastAPI backends** - Running on ports 8000-8003
- **supervisord** - Manages all processes

Everything starts automatically! 🎉

