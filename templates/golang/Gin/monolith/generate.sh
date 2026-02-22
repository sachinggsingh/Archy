#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating $PROJECT_NAME"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit

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
    "net/http"
    "github.com/gin-gonic/gin"
)

# Dont forgot the run go mod tidy

func main() {
    fmt.Println("Hello World")
    r := gin.Default()
    r.GET("/health",func(c *gin.Context){
        c.JSON(http.StatusOK,gin.H{
            "status":"ok"
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