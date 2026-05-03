const express = require('express');
const redis = require('redis');
const cors = require('cors');
const morgan = require('morgan');
require('dotenv').config({ path: '../../.env' });

const app = express();
const PORT = process.env.CART_SERVICE_PORT || 8003;

app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

const client = redis.createClient({ url: process.env.REDIS_URL });

client.on('error', (err) => console.log('Cart Service: Redis Client Error', err));

async function connectWithRetry() {
  let connected = false;
  while (!connected) {
    try {
      await client.connect();
      console.log('Cart Service: Redis connected');
      connected = true;
    } catch (err) {
      console.error('Cart Service: Connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }
}

// Helper to get cart
const getCartKey = (userId) => `cart:${userId}`;

// Routes
app.get('/', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const cart = await client.hGetAll(getCartKey(userId));
    // Redis returns string values, need to parse JSON
    const items = Object.values(cart).map(item => JSON.parse(item));
    res.json({ success: true, data: items });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/add', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const { productId, name, price, quantity } = req.body;
    
    // Check if item already exists
    const existingItem = await client.hGet(getCartKey(userId), productId);
    let newItem;
    if (existingItem) {
      const parsedItem = JSON.parse(existingItem);
      parsedItem.quantity += quantity;
      newItem = parsedItem;
    } else {
      newItem = { productId, name, price, quantity };
    }
    
    await client.hSet(getCartKey(userId), productId, JSON.stringify(newItem));
    res.json({ success: true, data: newItem });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.put('/update', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const { productId, quantity } = req.body;
    
    const existingItem = await client.hGet(getCartKey(userId), productId);
    if (!existingItem) return res.status(404).json({ success: false, error: 'Item not in cart' });
    
    const parsedItem = JSON.parse(existingItem);
    parsedItem.quantity = quantity;
    
    if (quantity <= 0) {
      await client.hDel(getCartKey(userId), productId);
    } else {
      await client.hSet(getCartKey(userId), productId, JSON.stringify(parsedItem));
    }
    
    res.json({ success: true, data: parsedItem });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.delete('/remove/:productId', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    await client.hDel(getCartKey(userId), req.params.productId);
    res.json({ success: true, message: 'Item removed from cart' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.delete('/clear', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    await client.del(getCartKey(userId));
    res.json({ success: true, message: 'Cart cleared' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.listen(PORT, async () => {
  console.log(`Cart Service running on port ${PORT}`);
  await connectWithRetry();
});
