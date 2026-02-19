#!/bin/bash

PROJECT_NAME="{{.Project}}"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

echo "Creating FastAPI microservice..."

pip install fastapi uvicorn python-dotenv || echo "Warning: pip install failed, continuing anyway..."

mkdir -p app/{api,core,models,schemas,services,db}

touch app/main.py

cat > app/main.py <<EOF
from fastapi import FastAPI

app = FastAPI(title="{{.Project}}")

@app.get("/health")
def health():
    return {"status":"ok"}
EOF

mkdir app/api

cat > app/api/user.py <<EOF
from fastapi import APIRouter
router = APIRouter()

@router.post("/users")
def create_user():
    return {"created":True}
EOF

echo "FastAPI microservice ready"
