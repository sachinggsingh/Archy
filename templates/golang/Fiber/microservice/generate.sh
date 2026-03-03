#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating $PROJECT_NAME"


# Create 3 services
for i in {1..3}
do
    SERVICE_NAME="service-$i"
    mkdir -p "$SERVICE_NAME"
    cd "$SERVICE_NAME" || exit

    echo "Creating $SERVICE_NAME"

    # Initialize go module
    go mod init "$SERVICE_NAME"

    # Create folders
    mkdir -p cmd/"$SERVICE_NAME"
    mkdir -p internal/{config,handlers,models,repositories,services}
    mkdir -p pkg/logger

    # Create main.go
    cat <<EOF > cmd/"$SERVICE_NAME"/main.go
package main
import(
    "fmt"
    "github.com/gofiber/fiber/v2"
)

func main() {
    app := fiber.New()
    app.Get("/health",func(c *fiber.Ctx)error{
        return c.JSON(fiber.Map{
            "status":"ok",
            "service": "$SERVICE_NAME",
        })
    })
    port := $((8080 + i))
    app.Listen(fmt.Sprintf(":%d", port))
}
EOF

    # Config
    cat <<EOF > internal/config/config.go
package config

type Config struct {
    Port string
}

func LoadConfig() *Config {
    return &Config{Port: "$((8080 + i))"}
}
EOF

    # Handler
    cat <<EOF > internal/handlers/user_handler.go
package handlers

import (
    "github.com/gofiber/fiber/v2"
)

func GetUser(c *fiber.Ctx) error {
    return c.JSON(fiber.Map{"user": "John Doe"})
}
EOF

    # Model
    cat <<EOF > internal/models/user.go
package models

type User struct {
    ID    string \`json:"id"\`
    Name  string \`json:"name"\`
    Email string \`json:"email"\`
}
EOF

    # Repository
    cat <<EOF > internal/repositories/user_repository.go
package repositories
EOF

    # Service
    cat <<EOF > internal/services/user_service.go
package services
EOF

    # Logger
    cat <<EOF > pkg/logger/logger.go
package logger

import "log"

func Info(msg string) {
    log.Println("[INFO] " + msg)
}
EOF

    # Dockerfile
    if [ "$USE_DOCKER" = "true" ]; then
        cat <<EOF > Dockerfile
FROM golang:1.21-alpine
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -o main cmd/"$SERVICE_NAME"/main.go
CMD ["./main"]
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
      - "8081:8081"
  service-2:
    build: ./service-2
    ports:
      - "8082:8082"
  service-3:
    build: ./service-3
    ports:
      - "8083:8083"
EOF
fi

# Root Test Script
if [ "$USE_TEST_SCRIPT" = "true" ]; then
    cat > test.sh <<EOF
#!/bin/bash
echo "Testing Fiber services..."
for i in {1..3}
do
    PORT=\$((8080 + i))
    echo "Checking service-\$i on port \$PORT..."
    curl -s http://localhost:\$PORT/health | grep "ok" && echo "service-\$i is UP" || echo "service-\$i is DOWN"
done
EOF
    chmod +x test.sh
fi


