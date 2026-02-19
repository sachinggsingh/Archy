#!/bin/bash

PROJECT_NAME="{{.Project}}"

echo "Creating Django monolith: $PROJECT_NAME"

# create project
django-admin startproject config "$PROJECT_NAME" || exit 1
cd "$PROJECT_NAME" || exit 1

# apps container
mkdir apps core

# install env loader
pip install python-dotenv || echo "Warning: pip install failed, continuing anyway..."

# move settings into folder
cd config
mkdir settings
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

# example app
python manage.py startapp users apps/users

echo "Django monolith ready"
