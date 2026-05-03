const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { sequelize, User } = require('./models/User');
require('dotenv').config({ path: '../../.env' });

const app = express();
const PORT = process.env.USER_SERVICE_PORT || 8001;
const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey123';

app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Helper for retry connection
async function connectWithRetry() {
  let connected = false;
  while (!connected) {
    try {
      await sequelize.authenticate();
      await sequelize.sync(); // Auto-sync tables
      console.log('User Service: PostgreSQL connected and synced');
      connected = true;
    } catch (err) {
      console.error('User Service: Connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }
}

// Routes
app.post('/register', async (req, res) => {
  console.log('User Service: Register request received', req.body);
  try {
    const { email, password, name, phone, address } = req.body;
    console.log('User Service: Hashing password...');
    const password_hash = await bcrypt.hash(password, 10);
    console.log('User Service: Creating user in DB...');
    const user = await User.create({ email, password_hash, name, phone, address });
    console.log('User Service: User created, signing JWT...');
    const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: '24h' });
    console.log('User Service: Register success');
    res.status(201).json({ success: true, data: { token, user: { id: user.id, email: user.email, name: user.name } } });
  } catch (err) {
    console.error('User Service: Register error', err);
    res.status(400).json({ success: false, error: err.message });
  }
});

app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user || !(await bcrypt.compare(password, user.password_hash))) {
      return res.status(401).json({ success: false, error: 'Invalid email or password' });
    }
    
    const token = jwt.sign({ userId: user.id, email: user.email }, JWT_SECRET, { expiresIn: '24h' });
    res.json({ success: true, data: { token, user: { id: user.id, email: user.email, name: user.name } } });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.get('/me', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const user = await User.findByPk(userId, { attributes: { exclude: ['password_hash'] } });
    if (!user) return res.status(404).json({ success: false, error: 'User not found' });
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.put('/profile', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const { name, phone, address } = req.body;
    await User.update({ name, phone, address }, { where: { id: userId } });
    const user = await User.findByPk(userId, { attributes: { exclude: ['password_hash'] } });
    res.json({ success: true, data: user });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.listen(PORT, async () => {
  console.log(`User Service running on port ${PORT}`);
  await connectWithRetry();
});
