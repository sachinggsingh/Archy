#!/bin/bash

PROJECT_NAME="{{.Project}}"

mkdir -p "$PROJECT_NAME/app/handlers" "$PROJECT_NAME/app/models" "$PROJECT_NAME/app/utils"
cd "$PROJECT_NAME" || exit 1

# Entry point
cat > main.py << 'EOF'
import logging
from app.server import run

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    run()
EOF

# Server setup
cat > app/server.py << 'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer
from .routes import router

HOST = "0.0.0.0"
PORT = 8000

class App(BaseHTTPRequestHandler):
    def do_GET(self):
        router(self)

    def do_POST(self):
        router(self)

def run():
    print(f"Server running at http://localhost:{PORT}")
    HTTPServer((HOST, PORT), App).serve_forever()
EOF

# Routing
cat > app/routes.py << 'EOF'
from .handlers.home import home_handler
from .handlers.health import health_handler

def router(req):
    if req.path == "/":
        home_handler(req)
    elif req.path == "/health":
        health_handler(req)
    else:
        req.send_response(404)
        req.end_headers()
        req.wfile.write(b"Not Found")
EOF

# Handlers
cat > app/handlers/home.py << 'EOF'
def home_handler(req):
    req.send_response(200)
    req.send_header("Content-type", "application/json")
    req.end_headers()
    req.wfile.write(b'{"message": "Python HTTP Monolith Running \ud83d\ude80"}')
EOF

cat > app/handlers/health.py << 'EOF'
def health_handler(req):
    req.send_response(200)
    req.send_header("Content-type", "application/json")
    req.end_headers()
    req.wfile.write(b'{"status": "healthy"}')
EOF

cat > app/models/__init__.py << 'EOF'
# Models for the application
EOF

cat > app/utils/__init__.py << 'EOF'
# Utility functions
EOF

touch app/__init__.py
touch app/handlers/__init__.py
echo "" > requirements.txt

cat > .env.example << 'EOF'
PORT=8000
HOST=0.0.0.0
EOF

cat > README.md << 'EOF'
# Python HTTP Monolith

A robust Python HTTP server using only the standard library.

## Getting Started

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Run the server:
   ```bash
   python main.py
   ```

## Structure
- `main.py`: Entry point.
- `app/server.py`: HTTP server configuration.
- `app/routes.py`: Request routing logic.
- `app/handlers/`: Request handlers.
- `app/models/`: Data models.
- `app/utils/`: Utility functions.
EOF

