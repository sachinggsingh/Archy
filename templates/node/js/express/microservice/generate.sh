#!/bin/bash
# Simplified generation per user request
PROJECT_NAME="{{.Project}}"


# 1. Initialize
npm init -y

# 2. Create folder structure
mkdir -p src/{middleware,route,service,utils,test,config,db,models}

# 4. Main server - FIXED
cat > src/index.js << 'EOF'
//Don't forgot to download the dependencies
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import userRouter from './route/user.route.js';

dotenv.config();

const app = express();

// Middleware
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// Routes
app.use('/api/v1', userRouter);

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
  console.log(`Health: http://localhost:${port}/health`);
});
EOF

# 5. User routes - FIXED (separate file + proper imports)
mkdir -p src/route/user
cat > src/route/user.route.js << 'EOF'
import { Router } from 'express';
import { SignUp } from '../service/user.service.js';

export const router = Router();

router.route('/users').post(SignUp);

export default router;
EOF

# 6. User service - FIXED (proper export)
cat > src/service/user.service.js << 'EOF'
import { generateResponse } from '../utils/utils.js';

export async function SignUp(req, res) {
  try {
    const { name, email } = req.body;
    
    if (!name || !email) {
      return res.status(400).json({
        success: false,
        error: 'Name and email required'
      });
    }

    // TODO: Save to DB
    const user = { id: Date.now(), name, email };
    
    return res.status(201).json({
      success: true,
      data: user
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message
    });
  }
}
EOF

# 7. Models stub
cat > src/models/User.model.js << 'EOF'
// User model schema
// TODO: Define your DB schema (Mongoose, Prisma, etc.)

export class User {
  constructor(data) {
    this.id = data.id;
    this.name = data.name;
    this.email = data.email;
  }
}
EOF

# 8. DB connection stub
cat > src/db/db.js << 'EOF'
// Database connection
// TODO: MongoDB, PostgreSQL, MySQL, etc.

export const connectDB = async () => {
  console.log(' DB connected');
};

export default connectDB;
EOF

# 9. Utils - FIXED
cat > src/utils/utils.js << 'EOF'
export const generateResponse = (success, data, error = null) => {
  return {
    success,
    data: success ? data : null,
    error: success ? null : error
  };
};

export const logger = {
  info: (msg) => console.log(`[INFO] ${new Date().toISOString()} ${msg}`),
  error: (msg) => console.error(`[ERROR] ${new Date().toISOString()} ${msg}`)
};
EOF

# 10. Config
cat > src/config/index.js << 'EOF'
import dotenv from 'dotenv';
dotenv.config();

export const config = {
  server: {
    port: process.env.PORT || 8080,
    host: process.env.HOST || '0.0.0.0'
  },
  app: {
    name: '{{.Project}}',
    env: process.env.NODE_ENV || 'development'
  },
  cors: {
    origin: process.env.FRONTEND_URL || 'http://localhost:3000'
  }
};
EOF

# 11. Tests stub
cat > src/test/health.test.js << 'EOF'
import request from 'supertest';
import app from '../index.js';

describe('Health Check', () => {
  it('should return 200', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
  });
});
EOF

# 12. Supporting files
cat > .env.example << 'EOF'
PORT=8080
NODE_ENV=development
FRONTEND_URL=http://localhost:3000
EOF

cat > .gitignore << 'EOF'
node_modules/
.env
*.log
.DS_Store
coverage/
dist/
EOF

cat > README.md << 'EOF'
# {{.Project}} 

Node.js + Express + ES Modules Microservice

## Quick Start
```bash
# or
docker compose up
```
EOF
