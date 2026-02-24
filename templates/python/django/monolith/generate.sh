#!/bin/bash

PROJECT_NAME="{{.Project}}"

echo "Creating Django monolith: $PROJECT_NAME"

# Create project in current directory
django-admin startproject config . || exit 1

# Create structure
mkdir -p apps core
touch apps/__init__.py
touch core/__init__.py

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

echo "Django monolith $PROJECT_NAME ready"
