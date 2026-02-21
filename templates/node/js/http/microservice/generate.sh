#!/bin/bash

$PROJECT_NAME = "{{.Project}}"

echo "Creating HTTP microservice - JavaScript - HTTP-server: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize TypeScript
npm init -y

# Install dependencies
npm install express dotenv

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
import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const port = process.env.PORT || 8080;

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.listen(port, () => {
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
  "name": "{{.Project}}",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "node src/index.js",
    "build": "tsc",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "dotenv": "^16.0.0",
    "express": "^4.17.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.13",
    "@types/node": "^16.0.0"
  }
}
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
node_modules
dist
.env
EOF

echo "HTTP microservice created successfully!"

# Run build
npm run build

# Run dev
npm run dev
