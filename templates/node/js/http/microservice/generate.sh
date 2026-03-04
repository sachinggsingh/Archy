#!/bin/bash

$PROJECT_NAME = "{{.ProjectName}}"

echo "Creating HTTP microservice - JavaScript - HTTP-server: $PROJECT_NAME"

# Create project directory

# Create src directory
# Create 3 services
for i in {1..3}
do
    SERVICE_NAME="service-$i"
    mkdir -p "$SERVICE_NAME"/src/{config,db,models,route,service,test,utils}
    cd "$SERVICE_NAME" || exit

    # Create index.js
    cat > src/index.js << EOF
import http from 'http';
import dotenv from 'dotenv';

dotenv.config();

const server = http.createServer((req, res) => {
  if (req.url === '/health' && req.method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ 
        status: 'ok', 
        service: "$SERVICE_NAME",
        timestamp: new Date().toISOString() 
    }));
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
});

const port = process.env.PORT || $((8080 + i));

server.listen(port, () => {
  console.log(\`$SERVICE_NAME running on http://localhost:\${port}\`);
});
EOF

    # Create .env
    cat > .env << EOF
PORT=$((8080 + i))
NODE_ENV=development
EOF

    # Create package.json
    cat > package.json << EOF
{
  "name": "$SERVICE_NAME",
  "version": "1.0.0",
  "description": "",
  "main": "src/index.js",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "dotenv": "^16.0.0"
  }
}
EOF

    # Create .gitignore
    cat > .gitignore << 'EOF'
node_modules
.env
EOF

    # Dockerfile
    if [ "$USE_DOCKER" = "true" ]; then
        cat > "$SERVICE_NAME"/Dockerfile <<EOF
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["node", "index.js"]
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


echo "Node HTTP microservices created successfully!"

