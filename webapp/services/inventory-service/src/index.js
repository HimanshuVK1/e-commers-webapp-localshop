const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const morgan = require('morgan');
const amqp = require('amqplib');
const Inventory = require('./models/Inventory');
require('dotenv').config({ path: '../../.env' });

const app = express();
const PORT = process.env.INVENTORY_SERVICE_PORT || 8006;

app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

async function connectWithRetry() {
  // MongoDB
  let dbConnected = false;
  while (!dbConnected) {
    try {
      await mongoose.connect(process.env.MONGO_URI);
      console.log('Inventory Service: MongoDB connected');
      dbConnected = true;
    } catch (err) {
      console.error('Inventory Service: MongoDB connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }

  // RabbitMQ
  let mqConnected = false;
  while (!mqConnected) {
    try {
      const connection = await amqp.connect(process.env.RABBITMQ_URL);
      const channel = await connection.createChannel();
      
      const exchange = 'order_events';
      await channel.assertExchange(exchange, 'fanout', { durable: false });
      
      // Create a private, temporary queue for this service
      const q = await channel.assertQueue('', { exclusive: true });
      await channel.bindQueue(q.queue, exchange, '');
      
      channel.consume(q.queue, async (msg) => {
        if (msg !== null) {
          const order = JSON.parse(msg.content.toString());
          console.log(`Inventory Service: Order received from exchange, deducting stock for order ${order.id}`);
          
          for (const item of order.items) {
            await Inventory.findOneAndUpdate(
              { productId: item.productId },
              { $inc: { stock: -item.quantity } },
              { upsert: true }
            );
          }
          channel.ack(msg);
        }
      });

      console.log('Inventory Service: RabbitMQ connected and listening to order_events exchange');
      mqConnected = true;
    } catch (err) {
      console.error('Inventory Service: RabbitMQ connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }
}

// Routes
app.get('/:productId', async (req, res) => {
  try {
    const inv = await Inventory.findOne({ productId: req.params.productId });
    res.json({ success: true, data: inv || { productId: req.params.productId, stock: 0 } });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.post('/deduct', async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    const inv = await Inventory.findOneAndUpdate(
      { productId },
      { $inc: { stock: -quantity } },
      { new: true, upsert: true }
    );
    res.json({ success: true, data: inv });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.listen(PORT, async () => {
  console.log(`Inventory Service running on port ${PORT}`);
  await connectWithRetry();
});
