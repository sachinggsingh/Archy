#!/bin/bash

# Exit on error
set -e

echo "🚀 Starting Archy Project Tests..."

# 1. Run Unit Tests
echo "🧪 Running Go unit tests..."
go test -v ./...

# 2. Smoke Tests for Project Generation
echo "🏗️  Running smoke tests for project generation..."

# Function to test generation
test_gen() {
    local lang=$1
    local fw=$2
    local arch=$3
    local project="test-project-$lang-$fw-$arch"
    
    echo "  Testing: $lang $fw $arch..."
    go run main.go -lang "$lang" -fw "$fw" -arch "$arch" -project "$project" -docker=false -tests=false -skip-deps=true

    
    if [ -d "$project" ]; then
        echo "  ✅ Success: $project created"
        rm -rf "$project"
    else
        echo "  ❌ Failure: $project NOT created"
        exit 1
    fi
}

# Test a few combinations (not all, to keep it fast)
test_gen "python" "flask" "microservice"
test_gen "golang" "gin" "microservice"
test_gen "typescript" "express" "microservice"

# Test Monolith
test_gen "python" "flask" "monolith"

# 3. Test Feature Flags (Microservice)
echo "🐳 Testing Feature Flags (Microservice)..."
go run main.go -lang python -fw flask -arch microservice -project test-features-micro -docker=true -tests=true -skip-deps=true

if [ -f "test-features-micro/docker-compose.yml" ] && [ -f "test-features-micro/test.sh" ]; then
    echo "  ✅ Success: Microservice flags work"
else
    echo "  ❌ Failure: Microservice flags failed"
    exit 1
fi
rm -rf test-features-micro

# 4. Test Feature Flags (Monolith)
echo "🐳 Testing Feature Flags (Monolith)..."
go run main.go -lang python -fw flask -arch monolith -project test-features-mono -docker=true -tests=true -skip-deps=true

if [ -f "test-features-mono/Dockerfile" ] && [ -f "test-features-mono/test.sh" ]; then
    echo "  ✅ Success: Monolith flags work"
else
    echo "  ❌ Failure: Monolith flags failed"
    exit 1
fi
rm -rf test-features-mono

echo "🎉 All tests passed successfully!"
