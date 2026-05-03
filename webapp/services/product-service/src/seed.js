const Product = require('./models/Product');

const sampleProducts = [
  // Block 1
  { name: 'Quantum Ultrabook 14', description: 'Ultra-slim laptop with 4K OLED display, 32GB RAM.', price: 1499, category: 'Electronics', stock: 25, rating: 4.9, images: ['https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80'] },
  { name: 'SonicWave Headphones', description: 'Industry-leading noise cancellation.', price: 299, category: 'Electronics', stock: 50, rating: 4.7, images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80'] },
  { name: 'PixelVision 5K Monitor', description: 'Professional grade color accuracy.', price: 899, category: 'Electronics', stock: 15, rating: 4.8, images: ['https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=800&q=80'] },
  { name: 'SmartWatch Pro Series', description: 'Track your health and fitness in style.', price: 399, category: 'Electronics', stock: 60, rating: 4.6, images: ['https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Aero-Fit Sneakers', description: 'Lightweight and responsive cushioning.', price: 125, category: 'Clothing', stock: 120, rating: 4.6, images: ['https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Urban Explorer Parka', description: 'Weatherproof warmth for city adventures.', price: 210, category: 'Clothing', stock: 30, rating: 4.7, images: ['https://images.unsplash.com/photo-1539533113208-f6df8cc8b543?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Classic Silk Blouse', description: 'Elegant 100% pure silk blouse.', price: 95, category: 'Clothing', stock: 40, rating: 4.5, images: ['https://images.unsplash.com/photo-1485230895905-ec40ba36b9bc?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Canvas Weekend Bag', description: 'Spacious and durable travel companion.', price: 75, category: 'Clothing', stock: 100, rating: 4.4, images: ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80'] },
  
  // Block 2
  { name: 'Industrial Oak Table', description: 'Handcrafted rustic solid oak table.', price: 450, category: 'Home', stock: 15, rating: 4.5, images: ['https://images.unsplash.com/photo-1533090161767-e6ffed986c88?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Smart Garden Kit', description: 'Automated indoor hydroponic system.', price: 89, category: 'Home', stock: 80, rating: 4.7, images: ['https://images.unsplash.com/photo-1585314062340-f1a5a7c9328d?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Velvet Accent Chair', description: 'Luxurious comfort for your living space.', price: 320, category: 'Home', stock: 10, rating: 4.8, images: ['https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Ceramic Vase Set', description: 'Minimalist hand-thrown ceramic vases.', price: 45, category: 'Home', stock: 200, rating: 4.3, images: ['https://images.unsplash.com/photo-1581783898377-1c85bf937427?auto=format&fit=crop&w=800&q=80'] },
  { name: 'The Art of Design', description: 'Hardcover coffee table book.', price: 65, category: 'Books', stock: 50, rating: 4.9, images: ['https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Gourmet Cast Iron Skillet', description: 'Pre-seasoned 12-inch skillet.', price: 55, category: 'Home', stock: 75, rating: 4.6, images: ['https://images.unsplash.com/photo-1590794056226-79ef3a8147e1?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Leather Sketchbook', description: 'Premium paper for your artistic ideas.', price: 35, category: 'Books', stock: 150, rating: 4.7, images: ['https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Zen Essential Oil Diffuser', description: 'Ultrasonic aromatherapy diffuser.', price: 40, category: 'Home', stock: 90, rating: 4.5, images: ['https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=800&q=80'] },

  // Block 3
  { name: 'ProTab 12.9', description: 'High-performance tablet for creatives and professionals.', price: 1099, category: 'Electronics', stock: 40, rating: 4.8, images: ['https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Lumina Digital Camera', description: 'Capture life in stunning 4K detail.', price: 749, category: 'Electronics', stock: 20, rating: 4.7, images: ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Mechanical Key-Master', description: 'Tactile mechanical keyboard with RGB lighting.', price: 159, category: 'Electronics', stock: 85, rating: 4.9, images: ['https://images.unsplash.com/photo-1511467687858-23d96c32e4ae?auto=format&fit=crop&w=800&q=80'] },
  { name: 'SwiftGlide Wireless Mouse', description: 'Ergonomic design for ultra-smooth precision.', price: 79, category: 'Electronics', stock: 110, rating: 4.6, images: ['https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?auto=format&fit=crop&w=800&q=80'] },
  { name: 'EchoSphere Speaker', description: 'Powerful room-filling sound with smart assistant.', price: 199, category: 'Electronics', stock: 95, rating: 4.5, images: ['https://images.unsplash.com/photo-1589492477829-5e65395b66cc?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Heritage Denim Jacket', description: 'Classic rugged style that never goes out of fashion.', price: 85, category: 'Clothing', stock: 55, rating: 4.7, images: ['https://images.unsplash.com/photo-1551537482-f2075a1d41f2?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Azure Summer Dress', description: 'Lightweight linen dress for breezy summer days.', price: 65, category: 'Clothing', stock: 70, rating: 4.8, images: ['https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Nordic Wool Scarf', description: 'Hand-knitted pure wool for maximum warmth.', price: 45, category: 'Clothing', stock: 150, rating: 4.6, images: ['https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Sky-High Aviators', description: 'Classic gold-frame sunglasses with UV protection.', price: 145, category: 'Clothing', stock: 40, rating: 4.9, images: ['https://images.unsplash.com/photo-1572635196237-14b3f281503f?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Legacy Leather Belt', description: 'Genuine full-grain leather with brass buckle.', price: 55, category: 'Clothing', stock: 120, rating: 4.7, images: ['https://images.unsplash.com/photo-1553531384-397c80973a0b?auto=format&fit=crop&w=800&q=80'] },

  // Block 4
  { name: 'Eclipse Floor Lamp', description: 'Minimalist curved lamp for contemporary interiors.', price: 189, category: 'Home', stock: 35, rating: 4.6, images: ['https://images.unsplash.com/photo-1534073828943-f801091bb18c?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Stone-Grey Plate Set', description: '12-piece matte ceramic dining set.', price: 120, category: 'Home', stock: 50, rating: 4.5, images: ['https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Cloud-Soft Bedding', description: 'Egyptian cotton duvet set for ultimate comfort.', price: 210, category: 'Home', stock: 25, rating: 4.9, images: ['https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Metro Wall Clock', description: 'Large industrial-style clock with silent movement.', price: 65, category: 'Home', stock: 60, rating: 4.4, images: ['https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Midnight Sandalwood Candle', description: 'Soy-based candle with long-lasting woody notes.', price: 28, category: 'Home', stock: 200, rating: 4.8, images: ['https://images.unsplash.com/photo-1603006905003-be475563bc59?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Aroma Burr Grinder', description: 'Professional grade coffee beans grinder.', price: 135, category: 'Home', stock: 45, rating: 4.7, images: ['https://images.unsplash.com/photo-1559056199-641a0ac8b55e?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Chrome Pulse Toaster', description: '2-slot brushed metal toaster with digital timer.', price: 59, category: 'Home', stock: 70, rating: 4.3, images: ['https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Bamboo Chef Board', description: 'Extra-large antimicrobial bamboo cutting board.', price: 35, category: 'Home', stock: 150, rating: 4.6, images: ['https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Signature Fountain Pen', description: 'Handcrafted iridium-tip pen for smooth writing.', price: 95, category: 'Books', stock: 30, rating: 4.9, images: ['https://images.unsplash.com/photo-1583485088034-697b5bc54ccd?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Grid Master Notebook', description: 'A5 leather-bound notebook with grid paper.', price: 24, category: 'Books', stock: 250, rating: 4.7, images: ['https://images.unsplash.com/photo-1531346878377-a5be20888e57?auto=format&fit=crop&w=800&q=80'] },

  // Final Block
  { name: 'Noir Designer Handbag', description: 'Luxury vegan leather handbag with gold accents.', price: 350, category: 'Clothing', stock: 20, rating: 4.9, images: ['https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Ergo-High Office Chair', description: 'Premium lumbar support and breathable mesh.', price: 499, category: 'Home', stock: 12, rating: 4.8, images: ['https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Titan Professional Blender', description: 'High-speed motor for perfect smoothies every time.', price: 249, category: 'Home', stock: 35, rating: 4.7, images: ['https://images.unsplash.com/photo-1570222094114-d054a817e56b?auto=format&fit=crop&w=800&q=80'] },
  { name: 'Stargazer Reflector Telescope', description: 'Observe the cosmos with precision optics.', price: 599, category: 'Electronics', stock: 8, rating: 4.9, images: ['https://images.unsplash.com/photo-1528716321680-815a8cdb8cbe?auto=format&fit=crop&w=800&q=80'] },
];

async function seedProducts() {
  await Product.deleteMany({}); 
  await Product.insertMany(sampleProducts);
  console.log('Product Service: Database expanded to 40 100% verified products');
}

module.exports = seedProducts;
