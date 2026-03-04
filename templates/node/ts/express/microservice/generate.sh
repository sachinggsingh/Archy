#!/bin/bash

PROJECT_NAME="{{.ProjectName}}"

echo "Creating Express microservice - TypeScript: $PROJECT_NAME"

# Create project directory

echo "Express microservice created successfully!"

# Create src directory
# Create 3 services
for i in {1..3}
do
    SERVICE_NAME="service-$i"
    mkdir -p "$SERVICE_NAME"/src/{config,db,models,route,service,test,utils}
    cd "$SERVICE_NAME" || exit

    # Create index.ts
    cat > src/index.ts << EOF
import express from 'express';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const port = process.env.PORT || $((8080 + i));

app.use(express.json());

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: "$SERVICE_NAME",
    timestamp: new Date().toISOString() 
  });
});

app.listen(port, () => {
  console.log(\`$SERVICE_NAME running on http://localhost:\${port}\`);
});
EOF

    # Create .env
    cat > .env << EOF
PORT=$((8080 + i))
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

    # Create package.json
    cat > package.json << EOF
{
  "name": "$SERVICE_NAME",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "start": "node dist/index.js",
    "dev": "ts-node src/index.ts",
    "build": "tsc",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
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




echo "TypeScript Express microservices created successfully!"


# Run build

# Run dev
