#!/bin/bash

PROJECT_NAME="{{.Project}}"

echo "Creating Django microservice: $PROJECT_NAME"

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
    return JsonResponse({"status":"ok"})
EOF

# Add health url
# Using perl for slightly better cross-platform sed if needed, but keeping sed for now
# I'll use a more robust way to add health urls if possible, but keeping current logic simplified
sed -i '' "s/from django.urls import path/from django.urls import path\nfrom core.health import health/" config/urls.py
sed -i '' "s/urlpatterns = \[/urlpatterns = \[\n    path('health/', health),/" config/urls.py

echo "Django microservice $PROJECT_NAME ready"