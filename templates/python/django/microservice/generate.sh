#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating Django microservice: $PROJECT_NAME"

# Create 3 services
for i in {1..3}
do
    SERVICE_NAME="service-$i"
    mkdir -p "$SERVICE_NAME"
    cd "$SERVICE_NAME" || exit

    # Create project in current directory
    django-admin startproject config . || exit 1

    # Create structure
    mkdir -p apps core
    touch apps/__init__.py
    touch core/__init__.py

    # Example app
    mkdir -p apps/users
    python manage.py startapp users apps/users

    # Split settings
    mkdir -p config/settings
    touch config/settings/__init__.py
    mv config/settings.py config/settings/base.py

    cat > config/settings/dev.py <<EOF
from .base import *
DEBUG=True
EOF

    cat > config/settings/prod.py <<EOF
from .base import *
DEBUG=False
EOF

    # Health endpoint
    cat > core/health.py <<EOF
from django.http import JsonResponse

def health(request):
    return JsonResponse({"status":"ok", "service": "$SERVICE_NAME"})
EOF

    # Add health url
    sed -i '' "s/from django.urls import path/from django.urls import path\nfrom core.health import health/" config/urls.py
    sed -i '' "s/urlpatterns = \[/urlpatterns = \[\n    path('health\/', health),/" config/urls.py

    # Dockerfile
    if [ "$USE_DOCKER" = "true" ]; then
        cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
RUN pip install django
COPY . .
CMD ["python", "manage.py", "runserver", "0.0.0.0:800\$i"]
EOF
    fi

    cd .. || exit
done

# Root Docker Compose
if [ "$USE_DOCKER" = "true" ]; then
    cat > docker-compose.yml <<EOF
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
    PORT=\$((8080 + i))
    echo "Checking service-\$i on port \$PORT..."
    curl -s http://localhost:\$PORT/health/ | grep "ok" && echo "service-\$i is UP" || echo "service-\$i is DOWN"
done
EOF
    chmod +x test.sh
fi