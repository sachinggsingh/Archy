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

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(fmt.Sprintf("OK from %s", "$SERVICE_NAME")))
	})
	port := $((8080 + i))
	fmt.Printf("Server listening on :%d\n", port)
	http.ListenAndServe(fmt.Sprintf(":%d", port), nil)
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

