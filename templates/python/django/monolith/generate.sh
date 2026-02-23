#!/bin/bash

PROJECT_NAME="{{.Project}}"

echo "Creating Django monolith: $PROJECT_NAME"

# Create project
django-admin startproject config "$PROJECT_NAME" || exit 1
cd "$PROJECT_NAME" || exit 1

# Create structure
mkdir -p apps core
touch apps/__init__.py
touch core/__init__.py

# Move settings into folder
cd config
mkdir -p settings
touch settings/__init__.py
mv settings.py settings/base.py
touch settings/dev.py settings/prod.py

cat > settings/dev.py <<EOF
from .base import *
DEBUG = True
EOF

cat > settings/prod.py <<EOF
from .base import *
DEBUG = False
EOF

# .env
cd ..
cat > .env <<EOF
DEBUG=True
SECRET_KEY=django-secret
EOF

# Example app
mkdir -p apps/users
python manage.py startapp users apps/users

echo "Django monolith $PROJECT_NAME ready"
