const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

// Minimal product app
const app = express();
app.use(express.json());

const productSchema = new mongoose.Schema({
  name: String,
  price: Number,
  category: String
});
const Product = mongoose.model('Product', productSchema);

app.get('/products', async (req, res) => {
  const products = await Product.find();
  res.json({ success: true, data: products });
});

describe('Product Service Unit Tests', () => {
  let mongoServer;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    await mongoose.connect(mongoServer.getUri());
  });

  afterAll(async () => {
    await mongoose.disconnect();
    await mongoServer.stop();
  });

  it('should return empty list initially', async () => {
    const res = await request(app).get('/products');
    expect(res.statusCode).toEqual(200);
    expect(res.body.data).toEqual([]);
  });

  it('should return products after seeding', async () => {
    await Product.create({ name: 'Test Product', price: 10, category: 'Test' });
    const res = await request(app).get('/products');
    expect(res.body.data.length).toBe(1);
    expect(res.body.data[0].name).toBe('Test Product');
  });
});
