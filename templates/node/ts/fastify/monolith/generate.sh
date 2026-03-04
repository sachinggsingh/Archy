#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating Fastify monolith - TypeScript: $PROJECT_NAME"

# Create project directory

echo "Fastify monolith created successfully!"

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

#//Don't forgot to download the dependencies
import fastify from 'fastify';
import dotenv from 'dotenv';

dotenv.config();

const app = fastify();
const port = process.env.PORT || 8080;

// Health check
app.get('/health', async (request, reply) => {
  return { status: 'ok', timestamp: new Date().toISOString() };
});

app.listen({ port }, (err, address) => {
  if (err) {
    console.error(err);
    process.exit(1);
  }
  console.log(`Server running on ${address}`);
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
    "dotenv": "^16.0.0",
    "fastify": "^4.0.0"
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


echo "Fastify monolith created successfully!"


# Run build

# Run dev
