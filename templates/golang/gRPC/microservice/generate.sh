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
    mkdir -p pb

    # Create main.go
    cat <<EOF > cmd/"$SERVICE_NAME"/main.go
package main

import (
	"log"
	"net"
	"fmt"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"$SERVICE_NAME/internal/handlers"
	"$SERVICE_NAME/pb"
)

func main() {
	port := $((50050 + i))
	lis, err := net.Listen("tcp", fmt.Sprintf(":%d", port))
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterUserServiceServer(s, &handlers.UserHandler{})

	// Register reflection service on gRPC server.
	reflection.Register(s)

	log.Printf("Server $SERVICE_NAME listening at %v", lis.Addr())
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}
EOF

    # Handler
    cat <<EOF > internal/handlers/user_handler.go
package handlers

import (
	"context"
	"$SERVICE_NAME/pb"
)

type UserHandler struct {
	pb.UnimplementedUserServiceServer
}

func (h *UserHandler) CreateUser(ctx context.Context, req *pb.CreateUserRequest) (*pb.CreateUserResponse, error) {
	return &pb.CreateUserResponse{
		User: &pb.User{
			Id:    "1",
			Name:  req.Name,
			Email: req.Email,
		},
	}, nil
}

func (h *UserHandler) GetUser(ctx context.Context, req *pb.GetUserRequest) (*pb.GetUserResponse, error) {
	return &pb.GetUserResponse{
		User: &pb.User{
			Id:    req.Id,
			Name:  "John Doe",
			Email: "john@example.com",
		},
	}, nil
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

    cat <<EOF > pb/user.proto
syntax = "proto3";

package pb;
option go_package = "./pb";

message User {
    string id = 1;
    string name = 2;
    string email = 3;
}

message CreateUserRequest {
    string name = 1;
    string email = 2;
}

message CreateUserResponse {
    User user = 1;
}

message GetUserRequest {
    string id = 1;
}

message GetUserResponse {
    User user = 1;
}

message UpdateUserRequest {
    string id = 1;
    string name = 2;
    string email = 3;
}

message UpdateUserResponse {
    User user = 1;
}

message DeleteUserRequest {
    string id = 1;
}

message DeleteUserResponse {
    User user = 1;
}

service UserService {
    rpc CreateUser(CreateUserRequest) returns (CreateUserResponse);
    rpc GetUser(GetUserRequest) returns (GetUserResponse);
    rpc UpdateUser(UpdateUserRequest) returns (UpdateUserResponse);
    rpc DeleteUser(DeleteUserRequest) returns (DeleteUserResponse);
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
      - "50051:50051"
  service-2:
    build: ./service-2
    ports:
      - "50052:50052"
  service-3:
    build: ./service-3
    ports:
      - "50053:50053"
EOF
fi



