#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"


# Create 3 services
for i in {1..3}
do
    SERVICE_NAME="service-$i"
    mkdir -p "$SERVICE_NAME"/src/{api/handlers,core,models,services}
    mkdir -p "$SERVICE_NAME"/tests

    # Entry point
    cat > "$SERVICE_NAME"/main.py << EOF
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
    cat > "$SERVICE_NAME"/src/core/config.py << EOF
import os

class Settings:
    PROJECT_NAME = "$SERVICE_NAME"
    HOST = os.getenv("HOST", "0.0.0.0")
    PORT = int(os.getenv("PORT", $((8000 + i))))
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

settings = Settings()
EOF

    # Server setup
    cat > "$SERVICE_NAME"/src/core/server.py << 'EOF'
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
    cat > "$SERVICE_NAME"/src/api/router.py << 'EOF'
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
    cat > "$SERVICE_NAME"/src/api/handlers/health.py << EOF
def handle(req):
    req.send_response(200)
    req.send_header("Content-type", "application/json")
    req.end_headers()
    req.wfile.write(b'{"status": "up", "service": "$SERVICE_NAME"}')
EOF

    cat > "$SERVICE_NAME"/src/api/handlers/welcome.py << EOF
def handle(req):
    req.send_response(200)
    req.send_header("Content-type", "application/json")
    req.end_headers()
    req.wfile.write(b'{"message": "Welcome to Python Microservice \ud83d\ude80", "service": "$SERVICE_NAME"}')
EOF

    # init files
    touch "$SERVICE_NAME"/src/services/__init__.py
    touch "$SERVICE_NAME"/src/models/__init__.py
    touch "$SERVICE_NAME"/src/api/__init__.py
    touch "$SERVICE_NAME"/src/api/handlers/__init__.py
    touch "$SERVICE_NAME"/src/core/__init__.py
    touch "$SERVICE_NAME"/src/__init__.py

    # Dockerfile
    if [ "$USE_DOCKER" = "true" ]; then
        cat > "$SERVICE_NAME"/Dockerfile << 'EOF'
FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
EOF
    fi


    echo "" > "$SERVICE_NAME"/requirements.txt

    # README
    cat > "$SERVICE_NAME"/README.md << EOF
# Python HTTP Microservice - $SERVICE_NAME

A production-ready microservice boilerplate.
EOF

    # Test placeholder
    cat > "$SERVICE_NAME"/tests/test_basic.py << 'EOF'
def test_placeholder():
    assert True
EOF
done

# Root Docker Compose
if [ "$USE_DOCKER" = "true" ]; then
    cat > docker-compose.yml << EOF
version: '3.8'
services:
  service-1:
    build: ./service-1
    ports:
      - "8001:8001"
  service-2:
    build: ./service-2
    ports:
      - "8002:8002"
  service-3:
    build: ./service-3
    ports:
      - "8003:8003"
EOF
fi

# Root Test Script
if [ "$USE_TEST_SCRIPT" = "true" ]; then
    cat > test.sh <<EOF
#!/bin/bash
echo "Testing services..."
for i in {1..3}
do
    PORT=\$((8000 + i))
    echo "Checking service-\$i on port \$PORT..."
    curl -s http://localhost:\$PORT/health | grep "up" && echo "service-\$i is UP" || echo "service-\$i is DOWN"
done
EOF
    chmod +x test.sh
fi


