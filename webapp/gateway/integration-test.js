const axios = require('axios');
require('dotenv').config();

const GATEWAY_URL = 'http://localhost:8000/api';

const api = axios.create({
  baseURL: GATEWAY_URL
  // removed timeout
});

async function runIntegrationTest() {
  console.log('⏳ Waiting 5s for services to stabilize...');
  await new Promise(r => setTimeout(r, 5000));
  console.log('🚀 Starting Full Integration Test...');
  
  try {
    // 1. Register
    console.log('--- Step 1: User Registration ---');
    const regRes = await api.post('/users/register', {
      email: `test_${Date.now()}@example.com`,
      password: 'password123',
      name: 'Integration Tester'
    });
    const token = regRes.data.data.token;
    console.log('✅ Registration Successful');

    // 2. Get Products
    console.log('--- Step 2: Fetch Products ---');
    const prodRes = await api.get('/products');
    const products = prodRes.data.data;
    console.log(`✅ Found ${products.length} products`);
    if (products.length === 0) throw new Error('No products found to test with');
    const testProduct = products[0];

    // 3. Add to Cart
    console.log('--- Step 3: Add to Cart ---');
    const cartRes = await api.post('/cart/add', {
      productId: testProduct._id,
      name: testProduct.name,
      price: testProduct.price,
      quantity: 1
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log('✅ Item added to cart');

    // 4. Place Order
    console.log('--- Step 4: Place Order ---');
    const orderRes = await api.post('/orders', {
      items: [
        { productId: testProduct._id, name: testProduct.name, price: testProduct.price, quantity: 1 }
      ],
      total: testProduct.price,
      address: '123 Integration Blvd'
    }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    console.log(`✅ Order Placed! ID: ${orderRes.data.data.id}`);

    // 5. Check Order History
    console.log('--- Step 5: Check Order History ---');
    const historyRes = await api.get('/orders', {
      headers: { Authorization: `Bearer ${token}` }
    });
    if (historyRes.data.data.length > 0) {
        console.log('✅ Order history verified');
    } else {
        throw new Error('Order history is empty');
    }

    console.log('\n🏆 ALL INTEGRATION TESTS PASSED!');
    process.exit(0);
  } catch (err) {
    console.error('\n❌ INTEGRATION TEST FAILED');
    if (err.response) {
        console.error('Response Error:', err.response.data);
    } else {
        console.error('Error Message:', err.message);
    }
    process.exit(1);
  }
}

runIntegrationTest();
