#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating HTTP microservice - TypeScript: $PROJECT_NAME"

# Create project directory

echo "HTTP monolith created successfully!"

# Create src directory
mkdir -p src
mkdir -p src/config
mkdir -p src/db
mkdir -p src/models
mkdir -p src/route
mkdir -p src/service
mkdir -p src/test
mkdir -p src/utils

# Create index.ts
cat > src/index.ts << 'EOF'
//Don't forgot to download the dependencies
import http from 'http';
import dotenv from 'dotenv';

dotenv.config();

const server = http.createServer((req, res) => {
  if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', timestamp: new Date().toISOString() }));
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
});

const port = process.env.PORT || 8080;

server.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
EOF

# Create .env
cat > .env << 'EOF'
PORT=8080
NODE_ENV=development
EOF

# Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "dist",
    "rootDir": "src"
  },
  "include": ["src"],
  "exclude": ["node_modules"]
}
EOF

# Create package.json scripts
cat > package.json << 'EOF'
{
  "name": "{{.ProjectName}}",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "ts-node src/index.ts",
    "build": "tsc",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "@types/node": "^16.0.0",
    "ts-node": "^10.0.0",
    "typescript": "^4.0.0"
  }
}
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
node_modules
dist
.env
EOF

# Dockerfile
if [ "$USE_DOCKER" = "true" ]; then
    cat > Dockerfile <<EOF
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
CMD ["npm", "start"]
EOF
fi

# Test Script
if [ "$USE_TEST_SCRIPT" = "true" ]; then
    cat > test.sh <<EOF
#!/bin/bash
echo "Testing TypeScript HTTP Monolith..."
curl -s http://localhost:8080/health | grep "ok" && echo "Service is UP" || echo "Service is DOWN"
EOF
    chmod +x test.sh
fi

echo "TypeScript microservice created successfully!"

# Run build

# Run dev
