const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const amqp = require('amqplib');
const { sequelize, Order } = require('./models/Order');
require('dotenv').config({ path: '../../.env' });

const app = express();
const PORT = process.env.ORDER_SERVICE_PORT || 8004;

app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

let channel;

async function connectWithRetry() {
  // DB connection
  let dbConnected = false;
  while (!dbConnected) {
    try {
      await sequelize.authenticate();
      await sequelize.sync();
      console.log('Order Service: PostgreSQL connected');
      dbConnected = true;
    } catch (err) {
      console.error('Order Service: DB connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }

  // RabbitMQ connection
  let mqConnected = false;
  while (!mqConnected) {
    try {
      const connection = await amqp.connect(process.env.RABBITMQ_URL);
      channel = await connection.createChannel();
      
      const exchange = 'order_events';
      await channel.assertExchange(exchange, 'fanout', { durable: false });
      
      console.log('Order Service: RabbitMQ connected and exchange asserted');
      mqConnected = true;
    } catch (err) {
      console.error('Order Service: RabbitMQ connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }
}

// Routes
app.post('/', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const { items, total, address } = req.body;
    
    const order = await Order.create({ user_id: userId, items, total, address });
    
    // Publish event to fanout exchange
    if (channel) {
      const exchange = 'order_events';
      channel.publish(exchange, '', Buffer.from(JSON.stringify(order)));
      console.log('Order Service: Published order.placed event to exchange');
    }
    
    res.status(201).json({ success: true, data: order });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.get('/', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const orders = await Order.findAll({ where: { user_id: userId }, order: [['createdAt', 'DESC']] });
    res.json({ success: true, data: orders });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.get('/:id', async (req, res) => {
  try {
    const userId = req.headers['x-user-id'];
    const order = await Order.findOne({ where: { id: req.params.id, user_id: userId } });
    if (!order) return res.status(404).json({ success: false, error: 'Order not found' });
    res.json({ success: true, data: order });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

app.put('/:id/status', async (req, res) => {
    try {
      const { status } = req.body;
      await Order.update({ status }, { where: { id: req.params.id } });
      res.json({ success: true, message: 'Order status updated' });
    } catch (err) {
      res.status(500).json({ success: false, error: err.message });
    }
});

app.listen(PORT, async () => {
  console.log(`Order Service running on port ${PORT}`);
  await connectWithRetry();
});
