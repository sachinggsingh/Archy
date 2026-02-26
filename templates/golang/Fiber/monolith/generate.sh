#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating $PROJECT_NAME"


# Initialize go module
go mod init "$PROJECT_NAME"

# Create folders

mkdir -p cmd/"$PROJECT_NAME"
mkdir -p internal/{config,handlers,models,repositories,services}
mkdir -p pkg/logger

# Create main.go
cat <<EOF > cmd/"$PROJECT_NAME"/main.go
package main
import(
    "fmt"
    "github.com/gofiber/fiber/v2"
)

// Dont forgot the run go mod tidy

func main() {
    fmt.Println("Hello World")
    app := fiber.New()
    app.Get("/health",func(c *fiber.Ctx)error{
        return c.JSON(fiber.Map{
            "status":"ok"
        })
    })
    app.Listen(":8080")
}
EOF

# Config
cat <<EOF > internal/config/config.go
package config
EOF

# Handler
cat <<EOF > internal/handlers/user_handler.go
package handlers
EOF

# Model
cat <<EOF > internal/models/user.go
package models
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
EOF