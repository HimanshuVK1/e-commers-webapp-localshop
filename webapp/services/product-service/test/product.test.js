const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');

// Minimal product app
const app = express();
app.use(express.json());

const productSchema = new mongoose.Schema({
  name: String,
  description: String,
  price: Number,
  category: String
});
productSchema.index({ name: 'text', description: 'text' });
const Product = mongoose.model('Product', productSchema);

app.get('/products', async (req, res) => {
  const { search } = req.query;
  const query = {};
  if (search) query.$text = { $search: search };
  const products = await Product.find(query);
  res.json({ success: true, data: products });
});

describe('Product Service Unit Tests', () => {
  let mongoServer;

  beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    await mongoose.connect(mongoServer.getUri());
    // Ensure indexes are created
    await Product.ensureIndexes();
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
    await Product.create({ name: 'Test Product', description: 'This is a test', price: 10, category: 'Test' });
    const res = await request(app).get('/products');
    expect(res.body.data.length).toBe(1);
    expect(res.body.data[0].name).toBe('Test Product');
  });

  it('should return filtered products when searching', async () => {
    await Product.create({ name: 'Unique Gadget', description: 'Very special item', price: 100, category: 'Electronics' });
    await Product.create({ name: 'Generic Tool', description: 'Simple gadget', price: 20, category: 'Tools' });
    
    // Search for 'Unique'
    const res1 = await request(app).get('/products?search=Unique');
    expect(res1.body.data.length).toBe(1);
    expect(res1.body.data[0].name).toBe('Unique Gadget');

    // Search for 'gadget' (case insensitive by default in text search)
    const res2 = await request(app).get('/products?search=gadget');
    expect(res2.body.data.length).toBe(2);
  });
});
