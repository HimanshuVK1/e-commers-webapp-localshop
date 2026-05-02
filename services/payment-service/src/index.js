const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const amqp = require('amqplib');
require('dotenv').config({ path: '../../.env' });

const app = express();
const PORT = process.env.PAYMENT_SERVICE_PORT || 8005;

app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

let channel;

async function connectWithRetry() {
  let mqConnected = false;
  while (!mqConnected) {
    try {
      const connection = await amqp.connect(process.env.RABBITMQ_URL);
      channel = await connection.createChannel();
      await channel.assertQueue('payment.success');
      console.log('Payment Service: RabbitMQ connected');
      mqConnected = true;
    } catch (err) {
      console.error('Payment Service: RabbitMQ connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }
}

// Routes
app.post('/initiate', (req, res) => {
  const { orderId, amount } = req.body;
  res.json({ success: true, data: { paymentId: `pay_${Date.now()}`, status: 'pending', orderId, amount } });
});

app.post('/confirm', async (req, res) => {
  const { paymentId, orderId } = req.body;
  
  // Mock 1s delay
  setTimeout(() => {
    if (channel) {
      const event = { paymentId, orderId, status: 'success' };
      channel.sendToQueue('payment.success', Buffer.from(JSON.stringify(event)));
    }
  }, 1000);

  res.json({ success: true, data: { status: 'success', message: 'Payment confirmed and processing' } });
});

app.listen(PORT, async () => {
  console.log(`Payment Service running on port ${PORT}`);
  await connectWithRetry();
});
