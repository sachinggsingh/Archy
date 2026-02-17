#!/bin/bash
# Node + JS + Express + Monolith
PROJECT_NAME="{{.Project}}"

mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME" || exit 1

echo "🏗  Creating $PROJECT_NAME monolith..."

# 1. Initialize & install deps
npm init -y
npm install express cors dotenv
npm install --save-dev nodemon jest supertest

# 2. Create folder structure (monolith-style, still modular)
mkdir -p src/{middleware,routes,controllers,services,utils,test,config,db,models}

# 3. Update package.json for ES modules
node -e "
const fs = require('fs');
const pkg = JSON.parse(fs.readFileSync('package.json', 'utf8'));
pkg.type = 'module';
pkg.scripts = {
  'start': 'node src/index.js',
  'dev': 'nodemon src/index.js --experimental-specifier-resolution=node',
  'test': 'node --experimental-vm-modules node_modules/.bin/jest'
};
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2));
console.log('✅ ES modules enabled');
"

# 4. Main server entry
cd src && touch index.js
cat > index.js << 'EOF'
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
  console.log(`🚀 Monolith server running on http://localhost:${port}`);
  console.log(`📊 Health: http://localhost:${port}/health`);
});

export default app;
EOF

# 5. User routes
cd routes
cat > user.routes.js << 'EOF'
import { Router } from 'express';
import { signUpController } from '../controllers/user.controller.js';

export const router = Router();

router.route('/users').post(signUpController);
EOF

# 6. User controller
cd ../controllers
cat > user.controller.js << 'EOF'
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
cd ../services
cat > user.service.js << 'EOF'
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
cd ../models
cat > User.model.js << 'EOF'
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
cd ../db
cat > db.js << 'EOF'
// Database connection
// TODO: MongoDB, PostgreSQL, MySQL, etc.

export const connectDB = async () => {
  console.log('🔗 DB connected (stub)');
};

export default connectDB;
EOF

# 10. Utils
cd ../utils
cat > utils.js << 'EOF'
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
cd ../config
cat > index.js << 'EOF'
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
cd ../test
cat > health.test.js << 'EOF'
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
cd ../..
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
npm run dev
```
EOF

