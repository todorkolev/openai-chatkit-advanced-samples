# Multi-stage Dockerfile to serve all ChatKit examples
# Each example is served at its own path: /cat-lounge, /customer-support, /metro-map, /news-guide

# =============================================================================
# Stage 1: Build all frontends
# =============================================================================
FROM node:20-alpine AS frontend-builder

WORKDIR /build

# Copy all frontend package files first for layer caching
COPY examples/cat-lounge/frontend/package*.json ./cat-lounge/
COPY examples/customer-support/frontend/package*.json ./customer-support/
COPY examples/metro-map/frontend/package*.json ./metro-map/
COPY examples/news-guide/frontend/package*.json ./news-guide/

# Install dependencies for all frontends
RUN cd cat-lounge && npm ci
RUN cd customer-support && npm ci
RUN cd metro-map && npm ci
RUN cd news-guide && npm ci

# Copy frontend source code
COPY examples/cat-lounge/frontend ./cat-lounge
COPY examples/customer-support/frontend ./customer-support
COPY examples/metro-map/frontend ./metro-map
COPY examples/news-guide/frontend ./news-guide

# Build each frontend with base path and API URLs configured for subpath serving
RUN cd cat-lounge && \
    VITE_CHATKIT_API_URL=/cat-lounge/chatkit \
    VITE_CAT_STATE_API_URL=/cat-lounge/cats \
    npm run build -- --base=/cat-lounge/

RUN cd customer-support && \
    VITE_SUPPORT_API_BASE=/customer-support/support \
    npm run build -- --base=/customer-support/

RUN cd metro-map && \
    VITE_CHATKIT_API_URL=/metro-map/chatkit \
    VITE_MAP_API_URL=/metro-map/map \
    npm run build -- --base=/metro-map/

RUN cd news-guide && \
    VITE_CHATKIT_API_URL=/news-guide/chatkit \
    VITE_ARTICLES_API_URL=/news-guide/articles \
    npm run build -- --base=/news-guide/

# =============================================================================
# Stage 2: Python backend base with uv
# =============================================================================
FROM python:3.11-slim AS backend-base

# Install uv for fast Python package management
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# =============================================================================
# Stage 3: Install backend dependencies
# =============================================================================
FROM backend-base AS backend-builder

# Copy all backend pyproject.toml and lock files
COPY examples/cat-lounge/backend/pyproject.toml examples/cat-lounge/backend/uv.lock ./cat-lounge/
COPY examples/customer-support/backend/pyproject.toml examples/customer-support/backend/uv.lock ./customer-support/
COPY examples/metro-map/backend/pyproject.toml examples/metro-map/backend/uv.lock ./metro-map/
COPY examples/news-guide/backend/pyproject.toml examples/news-guide/backend/uv.lock ./news-guide/

# Install dependencies for each backend
RUN cd cat-lounge && uv sync --frozen --no-dev
RUN cd customer-support && uv sync --frozen --no-dev
RUN cd metro-map && uv sync --frozen --no-dev
RUN cd news-guide && uv sync --frozen --no-dev

# Copy backend application code
COPY examples/cat-lounge/backend/app ./cat-lounge/app
COPY examples/customer-support/backend/app ./customer-support/app
COPY examples/metro-map/backend/app ./metro-map/app
COPY examples/news-guide/backend/app ./news-guide/app

# =============================================================================
# Stage 4: Final runtime image
# =============================================================================
FROM python:3.11-slim AS runtime

# Install nginx and supervisor
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy uv from backend-base
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Copy backend applications with their virtual environments
COPY --from=backend-builder /app/cat-lounge /app/cat-lounge
COPY --from=backend-builder /app/customer-support /app/customer-support
COPY --from=backend-builder /app/metro-map /app/metro-map
COPY --from=backend-builder /app/news-guide /app/news-guide

# Copy built frontends
COPY --from=frontend-builder /build/cat-lounge/dist /var/www/cat-lounge
COPY --from=frontend-builder /build/customer-support/dist /var/www/customer-support
COPY --from=frontend-builder /build/metro-map/dist /var/www/metro-map
COPY --from=frontend-builder /build/news-guide/dist /var/www/news-guide

# Create nginx configuration
RUN cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;
    server_name _;

    # Cat Lounge
    location /cat-lounge/ {
        alias /var/www/cat-lounge/;
        try_files $uri $uri/ /cat-lounge/index.html;
    }
    location /cat-lounge/chatkit { proxy_pass http://127.0.0.1:8000/chatkit; }
    location /cat-lounge/cats/ { proxy_pass http://127.0.0.1:8000/cats/; }

    # Customer Support
    location /customer-support/ {
        alias /var/www/customer-support/;
        try_files $uri $uri/ /customer-support/index.html;
    }
    location /customer-support/support/ { proxy_pass http://127.0.0.1:8001/support/; }

    # Metro Map
    location /metro-map/ {
        alias /var/www/metro-map/;
        try_files $uri $uri/ /metro-map/index.html;
    }
    location /metro-map/chatkit { proxy_pass http://127.0.0.1:8002/chatkit; }
    location /metro-map/map { proxy_pass http://127.0.0.1:8002/map; }

    # News Guide
    location /news-guide/ {
        alias /var/www/news-guide/;
        try_files $uri $uri/ /news-guide/index.html;
    }
    location /news-guide/chatkit { proxy_pass http://127.0.0.1:8003/chatkit; }
    location /news-guide/articles { proxy_pass http://127.0.0.1:8003/articles; }

    # Root landing page
    location = / {
        default_type text/html;
        return 200 '<!DOCTYPE html><html><head><title>ChatKit Examples</title><style>
            body{font-family:system-ui,sans-serif;max-width:600px;margin:50px auto;padding:20px}
            h1{color:#333}a{display:block;padding:15px;margin:10px 0;background:#f0f0f0;
            text-decoration:none;color:#333;border-radius:8px}a:hover{background:#e0e0e0}
        </style></head><body><h1>ChatKit Examples</h1>
        <a href="/cat-lounge/">🐱 Cat Lounge</a>
        <a href="/customer-support/">✈️ Customer Support</a>
        <a href="/metro-map/">🚇 Metro Map</a>
        <a href="/news-guide/">📰 News Guide</a></body></html>';
    }
}
EOF

# Create supervisor configuration
RUN cat > /etc/supervisor/conf.d/chatkit.conf << 'EOF'
[supervisord]
nodaemon=true
user=root

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true

[program:cat-lounge]
command=/app/cat-lounge/.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8000
directory=/app/cat-lounge
autostart=true
autorestart=true
environment=PYTHONPATH="/app/cat-lounge"

[program:customer-support]
command=/app/customer-support/.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8001
directory=/app/customer-support
autostart=true
autorestart=true
environment=PYTHONPATH="/app/customer-support"

[program:metro-map]
command=/app/metro-map/.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8002
directory=/app/metro-map
autostart=true
autorestart=true
environment=PYTHONPATH="/app/metro-map"

[program:news-guide]
command=/app/news-guide/.venv/bin/uvicorn app.main:app --host 127.0.0.1 --port 8003
directory=/app/news-guide
autostart=true
autorestart=true
environment=PYTHONPATH="/app/news-guide"
EOF

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

