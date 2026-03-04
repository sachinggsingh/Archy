#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating $PROJECT_NAME"


# Initialize go module
go mod init "$PROJECT_NAME"

# Create folders

mkdir -p cmd/"$PROJECT_NAME"
mkdir -p internal/{config,handlers,models,repositories,services}
mkdir -p pkg/logger

#Dockerfile
if [ "$USE_DOCKER" = "true" ]; then
    cat <<EOF > Dockerfile
FROM golang:1.21-alpine
WORKDIR /app
COPY go.mod ./
RUN go mod download
COPY . .
RUN go build -o main cmd/"$PROJECT_NAME"/main.go
CMD ["./main"]
EOF
fi

# Create main.go
cat <<EOF > cmd/"$PROJECT_NAME"/main.go
package main
import(
    "fmt"
    "log"
    "github.com/labstack/echo/v4"
    "net/http"
)

// Dont forgot the run go mod tidy

func Info(msg string) {
    log.Println("[INFO] " + msg)
}

func main() {
    fmt.Println("Hello World")
    e := echo.New()
    e.GET("/health",func(c echo.Context)error{
        return c.JSON(http.StatusOK,"Hello from the Server")
    })
	e.Logger.Fatal(e.Start(":8080"))
}
EOF

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
    "github.com/labstack/echo/v4"
    "net/http"
)

func GetUser(c echo.Context) error {
    return c.JSON(http.StatusOK, map[string]string{"user": "John Doe"})
}
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