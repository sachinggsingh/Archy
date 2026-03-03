#!/bin/bash
# Simplified generation per user request
PROJECT_NAME="{{.ProjectName}}"


# Create 3 services
for i in {1..3}
do
    SERVICE_NAME="service-$i"
    mkdir -p "$SERVICE_NAME"/src/{middleware,route,service,utils,test,config,db,models}
    cd "$SERVICE_NAME" || exit

    # 1. Initialize
    npm init -y > /dev/null

    # 4. Main server
    cat > src/index.js << EOF
//Don't forgot to download the dependencies
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import userRouter from './route/user.route.js';

dotenv.config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: "$SERVICE_NAME",
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use('/api/v1', userRouter);

const port = $((8080 + i));
app.listen(port, () => {
  console.log(\`$SERVICE_NAME running on http://localhost:\${port}\`);
});
EOF

    # 5. User routes
    cat > src/route/user.route.js << 'EOF'
import { Router } from 'express';
import { SignUp } from '../service/user.service.js';

export const router = Router();
router.route('/users').post(SignUp);
export default router;
EOF

    # 6. User service
    cat > src/service/user.service.js << EOF
export async function SignUp(req, res) {
  return res.status(201).json({
    success: true,
    service: "$SERVICE_NAME",
    message: "User created"
  });
}
EOF

    # 9. Utils
    cat > src/utils/utils.js << 'EOF'
export const logger = {
  info: (msg) => console.log(`[INFO] ${new Date().toISOString()} ${msg}`),
  error: (msg) => console.error(`[ERROR] ${new Date().toISOString()} ${msg}`)
};
EOF

    # 10. Config
    cat > src/config/index.js << EOF
import dotenv from 'dotenv';
dotenv.config();

export const config = {
  server: {
    port: process.env.PORT || $((8080 + i)),
    host: process.env.HOST || '0.0.0.0'
  }
};
EOF

    # 12. Supporting files
    cat > .env << EOF
PORT=$((8080 + i))
NODE_ENV=development
EOF

    cat > .gitignore << 'EOF'
node_modules/
.env
EOF

    # Update package.json for ESM
    sed -i '' 's/"main": "index.js"/"main": "src\/index.js",\n  "type": "module"/g' package.json

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

# Root Test Script
if [ "$USE_TEST_SCRIPT" = "true" ]; then
    cat > test.sh <<EOF
#!/bin/bash
echo "Testing Node.js services..."
for i in {1..3}
do
    PORT=\$((8080 + i))
    echo "Checking service-\$i on port \$PORT..."
    curl -s http://localhost:\$PORT/health | grep "ok" && echo "service-\$i is UP" || echo "service-\$i is DOWN"
done
EOF
    chmod +x test.sh
fi


echo "Node Express microservices ready"

