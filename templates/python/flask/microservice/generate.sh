#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"


# No installation per user request

# Create 3 services
for i in {1..3}
do
    SERVICE_NAME="service-$i"
    mkdir -p "$SERVICE_NAME"/app/{routes,models,services,core}
    touch "$SERVICE_NAME"/app/__init__.py

    cat > "$SERVICE_NAME"/app/main.py <<EOF
from flask import Flask
from app.routes.user import user_bp

def create_app():
    app = Flask(__name__)
    app.register_blueprint(user_bp, url_prefix="/api")

    @app.route("/health")
    def health():
        return {"status":"ok", "service": "$SERVICE_NAME"}

    return app

app = create_app()

if __name__ == "__main__":
    app.run(port=$((8080 + i)))
EOF

    mkdir -p "$SERVICE_NAME"/app/routes

    cat > "$SERVICE_NAME"/app/routes/user.py <<EOF
from flask import Blueprint

user_bp = Blueprint("user", __name__)

@user_bp.route("/users", methods=["POST"])
def create_user():
    return {"created":True, "service": "$SERVICE_NAME"}
EOF
    # Dockerfile
    if [ "$USE_DOCKER" = "true" ]; then
        cat > "$SERVICE_NAME"/Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
RUN pip install flask
COPY . .
CMD ["python", "app/main.py"]
EOF
    fi
done

# Root Docker Compose
if [ "$USE_DOCKER" = "true" ]; then
    cat > docker-compose.yml <<EOF
version: '3.8'
services:
  service-1:
    build: ./service-1
    ports:
      - "8081:8081"
  service-2:
    build: ./service-2
    ports:
      - "8082:8082"
  service-3:
    build: ./service-3
    ports:
      - "8083:8083"
EOF
fi

# Root Test Script
if [ "$USE_TEST_SCRIPT" = "true" ]; then
    cat > test.sh <<EOF
#!/bin/bash
echo "Testing services..."
for i in {1..3}
do
    PORT=\$((8080 + i))
    echo "Checking service-\$i on port \$PORT..."
    curl -s http://localhost:\$PORT/health | grep "ok" && echo "service-\$i is UP" || echo "service-\$i is DOWN"
done
EOF
    chmod +x test.sh
fi



# No final echo per user request
