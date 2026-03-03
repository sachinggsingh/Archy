# Variables at top
BINARY_NAME=archy
VERSION=1.0.0
BUILD_DIR=bin

# Default target
.PHONY: all
all: build test

# Build binary
.PHONY: build
build:
	go build -ldflags "-s -w" -o $(BUILD_DIR)/$(BINARY_NAME) .

# Run tests
.PHONY: test
test:
	go test -v -race -cover ./...

# Generate coverage report
.PHONY: cover
cover:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

# Lint code
.PHONY: lint
lint:
	golangci-lint run

# Clean artifacts
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR) coverage.out

# Cross-compile for multiple platforms
.PHONY: release
release:
	GOOS=linux GOARCH=amd64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 ./cmd/archy
	GOOS=darwin GOARCH=arm64 go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 ./cmd/archy

# Format code
.PHONY: fmt
fmt:
	go fmt ./...
	gofmt -w -s .

# Install tools
.PHONY: tools
tools:
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Help (shows all targets)
.PHONY: help
help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
