const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const Product = require('./models/Product');
const seedProducts = require('./seed');
require('dotenv').config({ path: '../../.env' });

const app = express();
const PORT = process.env.PRODUCT_SERVICE_PORT || 8002;

app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

async function connectWithRetry() {
  let connected = false;
  while (!connected) {
    try {
      await mongoose.connect(process.env.MONGO_URI);
      console.log('Product Service: MongoDB connected');
      await seedProducts();
      connected = true;
    } catch (err) {
      console.error('Product Service: Connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }
}

// Routes
app.get('/', async (req, res) => {
  try {
    const { category, minPrice, maxPrice, sort, search, page = 1 } = req.query;
    const limit = Number(req.query.limit) || 50;
    
    const query = {};
    if (category) query.category = category;
    if (search) query.$text = { $search: search };
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    const sortOption = {};
    if (search && !sort) {
      sortOption.score = { $meta: 'textScore' };
    } else if (sort === 'price_asc') {
      sortOption.price = 1;
    } else if (sort === 'price_desc') {
      sortOption.price = -1;
    } else if (sort === 'rating') {
      sortOption.rating = -1;
    }

    const products = await Product.find(query)
      .sort(sortOption)
      .skip((page - 1) * limit)
      .limit(limit);

    res.json({ success: true, data: products });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) return res.status(404).json({ success: false, error: 'Product not found' });
    res.json({ success: true, data: product });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/', async (req, res) => {
  try {
    const product = new Product(req.body);
    await product.save();
    res.status(201).json({ success: true, data: product });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

app.put('/:id', async (req, res) => {
  try {
    const product = await Product.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json({ success: true, data: product });
  } catch (err) {
    res.status(400).json({ success: false, error: err.message });
  }
});

app.listen(PORT, async () => {
  console.log(`Product Service running on port ${PORT}`);
  await connectWithRetry();
});
