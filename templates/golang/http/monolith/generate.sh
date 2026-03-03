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

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("OK"))
	})
	fmt.Println("Server listening on :8080")
	http.ListenAndServe(":8080", nil)
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
	"net/http"
)

func GetUser(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("John Doe"))
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
RUN go build -o main cmd/"$PROJECT_NAME"/main.go
CMD ["./main"]
EOF
fi

# Test Script
if [ "$USE_TEST_SCRIPT" = "true" ]; then
    cat > test.sh <<EOF
#!/bin/bash
echo "Testing HTTP Monolith..."
curl -s http://localhost:8080/health | grep "OK" && echo "Service is UP" || echo "Service is DOWN"
EOF
    chmod +x test.sh
fi

