#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating Express monolith - TypeScript: $PROJECT_NAME"

# Create project directory

# Create src directory
mkdir -p src/route
mkdir -p src/service
mkdir -p src/test
mkdir -p src/utils
mkdir -p src/config
mkdir -p src/db
mkdir -p src/middleware
mkdir -p src/model

# Create index.ts
cat > src/index.ts << 'EOF'
//  Don't forgot to download the dependencies


import express, {Express} from 'express';
import dotenv from 'dotenv';
import {config} from './config/config.ts';

const app: Express = express();

app.use(express.json())

app.listen(config.server.port, () => {
  console.log(`Server is running on port ${config.server.port}`);
});
EOF

cat > src/config/config.ts << 'EOF'
export const config = {
server:{
  port: process.env.PORT || 8080,
  host: process.env.HOST || '0.0.0.0'
},
app:{
  name: '{{.ProjectName}}',
  env: process.env.NODE_ENV || 'development'
},
cors:{
  origin: process.env.FRONTEND_URL || 'http://localhost:3000'
}
}
EOF

cat > src/model/model.ts << 'EOF'
//This is your model file
EOF

cat > src/db/db.ts << 'EOF'
//This is your db file
EOF

cat > src/utils/utils.ts << 'EOF'
//This is your utils file
EOF

cat > src/middleware/middleware.ts << 'EOF'
//This is your middleware file
EOF

cat > src/service/service.ts << 'EOF'
//This is your middleware file
EOF

cat > src/route/routes.ts << 'EOF'
//This is your routes file
EOF


cat > src/test/test.ts << 'EOF'
//This is your test file
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
    "express": "^4.17.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.13",
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
echo "Testing TypeScript Express Monolith..."
curl -s http://localhost:8080/health | grep "ok" && echo "Service is UP" || echo "Service is DOWN"
EOF
    chmod +x test.sh
fi

echo "Express monolith created successfully!"

# Run build

# Run dev
