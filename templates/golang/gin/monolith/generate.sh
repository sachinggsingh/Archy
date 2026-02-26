#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating Gin monolith: $PROJECT_NAME"


# Initialize go module
go mod init "$PROJECT_NAME"

# Create folders
mkdir -p cmd/"$PROJECT_NAME"
mkdir -p internal/config internal/handlers internal/models internal/repositories internal/services
mkdir -p pkg/logger

# Create main.go
cat <<EOF > cmd/"$PROJECT_NAME"/main.go
package main

import (
    "fmt"
    "net/http"
    "github.com/gin-gonic/gin"
)

func main() {
    fmt.Printf("Starting %s...\n", "$PROJECT_NAME")
    r := gin.Default()
    r.GET("/health", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "status": "ok",
        })
    })
    r.Run(":8080")
}
EOF

# Model
touch internal/models/user.go
# Repository
touch internal/repositories/user_repository.go
# Service
touch internal/services/user_service.go
# Logger
touch pkg/logger.go


# Config
cat <<EOF > internal/config/config.go
package config

type Config struct {
    Port string
}

func LoadConfig() *Config {
    return &Config{Port: "8080"}
}
EOF

# Handler
cat <<EOF > internal/handlers/user_handler.go
package handlers

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func GetUser(c *gin.Context) {
    c.JSON(http.StatusOK, gin.H{"user": "John Doe"})
}
EOF

cat <<EOF > internal/models/user.go 
package models
EOF
cat <<EOF > internal/services/user_service.go
package services
EOF
cat <<EOF > internal/repositories/user_repository.go
package repositories
EOF

cat <<EOF > pkg/logger.go
package logger
EOF

cat > README.md <<EOF
# $PROJECT_NAME 🚀

Gin Monolith in Go

## Getting Started

1. Initialize dependencies:
   \`\`\`bash
   go mod tidy
   \`\`\`

2. Run the application:
   \`\`\`bash
   go run cmd/$PROJECT_NAME/main.go
   \`\`\`
EOF

# Run go mod tidy to ensure everything works perfectly
# go mod tidy