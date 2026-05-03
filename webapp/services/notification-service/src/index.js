const amqp = require('amqplib');
require('dotenv').config({ path: '../../.env' });

async function start() {
  let mqConnected = false;
  while (!mqConnected) {
    try {
      const connection = await amqp.connect(process.env.RABBITMQ_URL);
      const channel = await connection.createChannel();
      
      // 1. Listen to Order Events (Fanout)
      const orderExchange = 'order_events';
      await channel.assertExchange(orderExchange, 'fanout', { durable: false });
      const orderQ = await channel.assertQueue('', { exclusive: true });
      await channel.bindQueue(orderQ.queue, orderExchange, '');
      
      channel.consume(orderQ.queue, (msg) => {
        if (msg !== null) {
          const data = JSON.parse(msg.content.toString());
          console.log(`📧 Notification: Order #${data.id} placed! Total: $${data.total}`);
          channel.ack(msg);
        }
      });

      // 2. Listen to Payment Events (Direct Queue)
      const paymentQueue = 'payment.success';
      await channel.assertQueue(paymentQueue);
      channel.consume(paymentQueue, (msg) => {
        if (msg !== null) {
          const data = JSON.parse(msg.content.toString());
          console.log(`💰 Notification: Payment success for Order #${data.orderId}!`);
          channel.ack(msg);
        }
      });

      console.log('Notification Service: RabbitMQ connected and listening (Exchange + Queue)');
      mqConnected = true;
    } catch (err) {
      console.error('Notification Service: RabbitMQ connection failed, retrying in 3s...', err.message);
      await new Promise(res => setTimeout(res, 3000));
    }
  }
}

start();
