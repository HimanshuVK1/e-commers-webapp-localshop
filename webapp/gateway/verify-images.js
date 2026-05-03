const axios = require('axios');

async function runImageTest() {
  console.log('🔍 Starting Dashboard Image Verification Test...');
  try {
    // Request more products to bypass the default limit of 20
    const res = await axios.get('http://localhost:8000/api/products?limit=50');
    const products = res.data.data;
    
    console.log(`✅ Total Products Found: ${products.length}`);
    products.forEach((p, i) => console.log(`  ${i+1}. ${p.name}`));
    
    if (products.length < 40) {
      console.error(`❌ Expected 40 products, but found ${products.length}`);
      process.exit(1);
    }

    let brokenImages = 0;
    for (const p of products) {
      const url = p.images[0];
      try {
        await axios.head(url, { 
          timeout: 5000,
          headers: { 'User-Agent': 'Mozilla/5.0' } 
        });
        console.log(`  - [OK] ${p.name}`);
      } catch (err) {
        console.error(`  - [FAIL] ${p.name}: ${url}`);
        brokenImages++;
      }
    }

    if (brokenImages === 0) {
      console.log('\n🏆 SUCCESS: All 40 products have valid, reachable images!');
    } else {
      console.error(`\n❌ FAILED: Found ${brokenImages} broken image(s).`);
      process.exit(1);
    }
  } catch (err) {
    console.error('❌ Error connecting to Gateway:', err.message);
    process.exit(1);
  }
}

runImageTest();
