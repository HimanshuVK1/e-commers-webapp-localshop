const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const { createProxyMiddleware } = require('http-proxy-middleware');
const jwt = require('jsonwebtoken');
require('dotenv').config({ path: '../.env' });

const app = express();
const PORT = process.env.GATEWAY_PORT || 8000;
const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey123';

app.use(cors());
app.use(morgan('dev'));

// Health Check (Moved before body parser)
app.get('/health', (req, res) => {
  res.json({ success: true, status: 'Gateway is running' });
});

// Auth Middleware
const authenticate = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, error: 'Unauthorized: No token provided' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    req.headers['x-user-id'] = decoded.userId;
    next();
  } catch (err) {
    return res.status(403).json({ success: false, error: 'Forbidden: Invalid token' });
  }
};

// Proxy Routes Configuration
const routes = [
  { path: '/api/users', target: process.env.USER_SERVICE_URL || 'http://localhost:8001' },
  { path: '/api/products', target: process.env.PRODUCT_SERVICE_URL || 'http://localhost:8002' },
  { path: '/api/cart', target: process.env.CART_SERVICE_URL || 'http://localhost:8003', auth: true },
  { path: '/api/orders', target: process.env.ORDER_SERVICE_URL || 'http://localhost:8004', auth: true },
  { path: '/api/payment', target: process.env.PAYMENT_SERVICE_URL || 'http://localhost:8005', auth: true },
  { path: '/api/inventory', target: process.env.INVENTORY_SERVICE_URL || 'http://localhost:8006', auth: true },
  { path: '/api/analytics', target: process.env.ANALYTICS_SERVICE_URL || 'http://localhost:8008', auth: true }
];

// Apply Proxies (WITHOUT express.json() globally)
routes.forEach(route => {
  const proxyOptions = {
    target: route.target,
    changeOrigin: true,
    pathRewrite: { [`^${route.path}`]: '' },
  };

  if (route.auth) {
    app.use(route.path, authenticate, createProxyMiddleware(proxyOptions));
  } else {
    // User service needs special handling for register/login vs profile
    if (route.path === '/api/users') {
      app.use(route.path, (req, res, next) => {
        const publicPaths = ['/register', '/login'];
        if (publicPaths.includes(req.path)) return next();
        return authenticate(req, res, next);
      }, createProxyMiddleware(proxyOptions));
    } else {
      app.use(route.path, createProxyMiddleware(proxyOptions));
    }
  }
});

// Now we can use body-parser for non-proxied routes (if any)
app.use(express.json());

app.listen(PORT, () => {
  console.log(`API Gateway running on port ${PORT}`);
});
