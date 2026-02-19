#!/bin/bash

PROJECT_NAME="{{.Project}}"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

echo "Creating FastAPI monolith..."

pip install fastapi uvicorn python-dotenv || echo "Warning: pip install failed, continuing anyway..."

mkdir -p app/{api,core,models,schemas,services,db}

touch app/main.py

cat > app/main.py <<EOF
from fastapi import FastAPI
from app.api import user

app = FastAPI()

@app.get("/health")
def health():
    return {"status":"ok"}

app.include_router(user.router, prefix="/api")
EOF


mkdir app/api
cat > app/api/user.py <<EOF
from fastapi import APIRouter

router = APIRouter()

@router.get("/users")
def get_users():
    return {"users":[]}
EOF

echo "✅ FastAPI monolith ready"
