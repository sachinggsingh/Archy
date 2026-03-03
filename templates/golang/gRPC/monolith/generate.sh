#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating $PROJECT_NAME"


# Optional bit: git init
# git init

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
echo "Testing gRPC Monolith..."
nc -zv localhost 50051 && echo "Service is UP" || echo "Service is DOWN"
EOF
    chmod +x test.sh
fi

# Initialize go module
go mod init "$PROJECT_NAME"

# Create folders

mkdir -p cmd/"$PROJECT_NAME"
mkdir -p internal/{config,handlers,models,repositories,services}
mkdir -p pkg/logger
mkdir -p pb

# Create main.go
cat <<EOF > cmd/"$PROJECT_NAME"/main.go
package main

import (
	"log"
	"net"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"{{.ProjectName}}/internal/handlers"
	"{{.ProjectName}}/pb"
)

func main() {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterUserServiceServer(s, &handlers.UserHandler{})

	// Register reflection service on gRPC server.
	reflection.Register(s)

	log.Printf("Server listening at %v", lis.Addr())
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
	"{{.ProjectName}}/pb"
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