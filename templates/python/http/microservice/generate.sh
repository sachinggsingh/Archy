#!/bin/bash

PROJECT_NAME="{{.Project}}"


# Entry point
cat > main.py << 'EOF'
import logging
from src.core.server import run_server
from src.core.config import settings

if __name__ == "__main__":
    logging.basicConfig(
        level=settings.LOG_LEVEL,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    run_server()
EOF

# Configuration
cat > src/core/config.py << 'EOF'
import os

class Settings:
    PROJECT_NAME = "{{.Project}}"
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", 8000))
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

settings = Settings()
EOF

# Server setup
cat > src/core/server.py << 'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer
from src.api.router import handle_request
from .config import settings

class MicroserviceHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        handle_request(self)

    def do_POST(self):
        handle_request(self)

def run_server():
    print(f"Service running at http://{settings.HOST}:{settings.PORT}")
    server = HTTPServer((settings.HOST, settings.PORT), MicroserviceHandler)
    server.serve_forever()
EOF

# Router
cat > src/api/router.py << 'EOF'
from src.api.handlers import health, welcome

def handle_request(req):
    if req.path == "/":
        welcome.handle(req)
    elif req.path == "/health":
        health.handle(req)
    else:
        req.send_response(404)
        req.end_headers()
        req.wfile.write(b'{"error": "Not Found"}')
EOF

# Handlers
mkdir -p src/api/handlers
cat > src/api/handlers/health.py << 'EOF'
def handle(req):
    req.send_response(200)
    req.send_header("Content-type", "application/json")
    req.end_headers()
    req.wfile.write(b'{"status": "up"}')
EOF

cat > src/api/handlers/welcome.py << 'EOF'
def handle(req):
    req.send_response(200)
    req.send_header("Content-type", "application/json")
    req.end_headers()
    req.wfile.write(b'{"message": "Welcome to Python Microservice \ud83d\ude80"}')
EOF

# services/models/etc
touch src/services/__init__.py
touch src/models/__init__.py
touch src/api/__init__.py
touch src/api/handlers/__init__.py
touch src/core/__init__.py
touch src/__init__.py

# Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
EOF

# Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - HOST=0.0.0.0
      - PORT=8000
EOF

echo "" > requirements.txt

# README
cat > README.md << 'EOF'
# Python HTTP Microservice

A production-ready microservice boilerplate.

## Features
- Modular architecture
- Docker support
- Production-ready logging
- Configuration management

## Usage

### Local
```bash
python main.py
```

### Docker
```bash
docker-compose up --build
```
EOF

# Test placeholder
cat > tests/test_basic.py << 'EOF'
def test_placeholder():
    assert True
EOF
