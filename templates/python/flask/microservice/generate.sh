#!/bin/bash

PROJECT_NAME="{{.Project}}"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

echo " Creating Flask microservice..."

pip install flask python-dotenv || echo "Warning: pip install failed, continuing anyway..."

mkdir -p app/{routes,models,services,core}

touch app/__init__.py
touch app/main.py

cat > app/main.py <<EOF
from flask import Flask
from app.routes.user import user_bp

def create_app():
    app = Flask(__name__)
    app.register_blueprint(user_bp, url_prefix="/api")

    @app.route("/health")
    def health():
        return {"status":"ok"}

    return app

app = create_app()

if __name__ == "__main__":
    app.run()
EOF

mkdir app/routes

cat > app/routes/user.py <<EOF
from flask import Blueprint

user_bp = Blueprint("user", __name__)

@user_bp.route("/users", methods=["POST"])
def create_user():
    return {"created":True}
EOF

echo "Flask microservice ready"
