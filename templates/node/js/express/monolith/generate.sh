#!/bin/bash
# No extra colors or output needed per user request
PROJECT_NAME="{{.Project}}"

# 1. Create package.json
cat > package.json << 'EOF'
{
  "name": "{{.Project}}",
  "version": "1.0.0",
  "main": "src/index.js",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "test": "node --experimental-vm-modules node_modules/.bin/jest"
  }
}
EOF

# 2. Create folder structure
mkdir -p src/{middleware,routes,controllers,service,utils,test,config,db,models}

# 4. Main server entry
cat > src/index.js << 'EOF'
// Don't forgot to download the dependencies
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { router as userRouter } from './routes/user.routes.js';

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

// App routes (monolith-style)
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

export default app;
EOF

# 5. User routes
cat > src/routes/user.routes.js << 'EOF'
import { Router } from 'express';
import { signUpController } from '../controllers/user.controller.js';

export const router = Router();

router.route('/users').post(signUpController);
EOF

# 6. User controller
cat > src/controllers/user.controller.js << 'EOF'
import { signUpService } from '../services/user.service.js';

export async function signUpController(req, res) {
  try {
    const result = await signUpService(req.body);
    return res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    return res.status(error.statusCode || 500).json({
      success: false,
      error: error.message || 'Internal server error'
    });
  }
}
EOF

# 7. User service
cat > src/service/user.service.js << 'EOF'
import { User } from '../models/User.model.js';

export async function signUpService(payload) {
  const { name, email } = payload;

  if (!name || !email) {
    const err = new Error('Name and email required');
    err.statusCode = 400;
    throw err;
  }

  // TODO: Replace with real DB persistence
  const user = new User({
    id: Date.now(),
    name,
    email,
  });

  return user;
}
EOF

# 8. Models stub
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

# 9. DB connection stub
cat > src/db/db.js << 'EOF'
// Database connection
// TODO: MongoDB, PostgreSQL, MySQL, etc.

export const connectDB = async () => {
  console.log('🔗 DB connected (stub)');
};

export default connectDB;
EOF

# 10. Utils
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

# 11. Config
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

# 12. Tests stub
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

# 13. Supporting files
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
# {{.Project}} ✨

Node.js + Express Monolith (ES Modules)

## 🚀 Quick Start
```bash
```
EOF
