#!/bin/bash

$PROJECT_NAME = "{{.Project}}"

echo "Creating HTTP monolith - JavaScript - HTTP-server: $PROJECT_NAME"

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create src directory
mkdir -p src/{config,db,models,route,service,test,utils}

# Create index.js
cat > src/index.js << 'EOF'
// Don't forgot to download the dependencies
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

# Create package.json
cat > package.json << 'EOF'
{
  "name": "{{.Project}}",
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

echo "HTTP monolith created successfully!"