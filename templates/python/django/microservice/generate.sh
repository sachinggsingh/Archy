#!/bin/bash

PROJECT_NAME="{{.Project}}"

echo "Creating Django microservice: $PROJECT_NAME"

django-admin startproject config "$PROJECT_NAME" || exit 1
cd "$PROJECT_NAME" || exit 1

# create structure
mkdir apps core

# create example app
python manage.py startapp users apps/users

# split settings
cd config
mkdir settings
mv settings.py settings/base.py

cat > settings/dev.py <<EOF
from .base import *
DEBUG=True
EOF

cat > settings/prod.py <<EOF
from .base import *
DEBUG=False
EOF

# health endpoint
cd ..
mkdir -p core

cat > core/health.py <<EOF
from django.http import JsonResponse

def health(request):
    return JsonResponse({"status":"ok"})
EOF

# add health url
sed -i '' "s/from django.urls import path/from django.urls import path\nfrom core.health import health/" config/urls.py
sed -i '' "s/urlpatterns = \[/urlpatterns = \[\n    path('health/', health),/" config/urls.py

echo "Django microservice $PROJECT_NAME ready"