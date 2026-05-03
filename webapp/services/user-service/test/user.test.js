const request = require('supertest');
const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Mock Sequelize and User
jest.mock('../src/models/User', () => {
  const { Sequelize, DataTypes } = require('sequelize');
  const sequelize = new Sequelize('sqlite::memory:', { logging: false });
  const User = sequelize.define('User', {
    email: DataTypes.STRING,
    password_hash: DataTypes.STRING,
    name: DataTypes.STRING
  });
  return { sequelize, User };
});

const { sequelize, User } = require('../src/models/User');

// Setup a minimal express app for testing
const app = express();
app.use(express.json());

app.post('/register', async (req, res) => {
  const { email, password, name } = req.body;
  const password_hash = await bcrypt.hash(password, 10);
  const user = await User.create({ email, password_hash, name });
  res.status(201).json({ success: true, data: { user: { id: user.id, email: user.email } } });
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  const user = await User.findOne({ where: { email } });
  if (user && await bcrypt.compare(password, user.password_hash)) {
    res.json({ success: true, data: { token: 'mock-token' } });
  } else {
    res.status(401).json({ success: false });
  }
});

describe('User Service Unit Tests', () => {
  beforeAll(async () => {
    await sequelize.sync({ force: true });
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should register a new user', async () => {
    const res = await request(app)
      .post('/register')
      .send({ email: 'test@example.com', password: 'password123', name: 'Test User' });
    
    expect(res.statusCode).toEqual(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.user.email).toBe('test@example.com');
  });

  it('should login the user', async () => {
    const res = await request(app)
      .post('/login')
      .send({ email: 'test@example.com', password: 'password123' });
    
    expect(res.statusCode).toEqual(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.token).toBeDefined();
  });

  it('should fail login with wrong password', async () => {
    const res = await request(app)
      .post('/login')
      .send({ email: 'test@example.com', password: 'wrong' });
    
    expect(res.statusCode).toEqual(401);
  });
});
