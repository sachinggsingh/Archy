#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating Django monolith: $PROJECT_NAME"

# Create project in current directory
django-admin startproject config . || exit 1

# Create structure
mkdir -p apps core
touch apps/__init__.py
touch core/__init__.py

# Create requirements.txt
cat > requirements.txt <<EOF
django
django-environ
psycopg2-binary
EOF

# Move settings into folder
mkdir -p config/settings
touch config/settings/__init__.py
mv config/settings.py config/settings/base.py
touch config/settings/dev.py config/settings/prod.py

cat > config/settings/dev.py <<EOF
from .base import *
DEBUG = True
EOF

cat > config/settings/prod.py <<EOF
from .base import *
DEBUG = False
EOF

# .env
cat > .env <<EOF
DEBUG=True
SECRET_KEY=django-secret
EOF

# Example app
mkdir -p apps/users
python manage.py startapp users apps/users

# Optional: Initialize git
# git init

# Dockerfile
if [ "$USE_DOCKER" = "true" ]; then
    cat > Dockerfile <<EOF
FROM python:3.9-slim
WORKDIR /app
RUN pip install django
COPY . .
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
EOF
fi

# Test Script
if [ "$USE_TEST_SCRIPT" = "true" ]; then
    cat > test.sh <<EOF
#!/bin/bash
echo "Testing Django Monolith..."
curl -s http://localhost:8000/health/ | grep "ok" && echo "Service is UP" || echo "Service is DOWN"
EOF
    chmod +x test.sh
fi

echo "Django monolith $PROJECT_NAME ready"
