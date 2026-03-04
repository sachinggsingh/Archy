#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating Gin monolith: $PROJECT_NAME"

# Initialize go module
go mod init "$PROJECT_NAME"

# Create folder structure
mkdir -p cmd/$PROJECT_NAME
mkdir -p internal/{config,handlers,models,repositories,services}
mkdir -p pkg/logger

# Dockerfile
if [ "$USE_DOCKER" = "true" ]; then
cat <<EOF > Dockerfile
FROM golang:1.21-alpine
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -o main cmd/$PROJECT_NAME/main.go
CMD ["./main"]
EOF
fi

# main.go
cat <<EOF > cmd/$PROJECT_NAME/main.go
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

# Config
cat <<EOF > internal/config/config.go
package config

type Config struct {
	Port string
}

func LoadConfig() *Config {
	return &Config{
		Port: "8080",
	}
}
EOF

# Handler
cat <<EOF > internal/handlers/user_handler.go
package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

func GetUser(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"user": "John Doe",
	})
}
EOF

# Model
cat <<EOF > internal/models/user.go
package models

type User struct {
	ID   int
	Name string
}
EOF

# Repository
cat <<EOF > internal/repositories/user_repository.go
package repositories

type UserRepository struct{}
EOF

# Service
cat <<EOF > internal/services/user_service.go
package services

type UserService struct{}
EOF

# Logger
cat <<EOF > pkg/logger/logger.go
package logger
EOF

# README
cat <<EOF > README.md
# $PROJECT_NAME 🚀

Gin Monolith in Go

## Getting Started

1. Install dependencies

\`\`\`bash
go mod tidy
\`\`\`

2. Run the application

\`\`\`bash
go run cmd/$PROJECT_NAME/main.go
\`\`\`
EOF

echo "Project $PROJECT_NAME created successfully!"