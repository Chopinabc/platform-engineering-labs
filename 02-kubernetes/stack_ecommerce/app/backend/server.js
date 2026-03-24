const express = require('express');
const { Pool } = require('pg');
const redis = require('redis');

const app = express();
app.use(express.json());

// Configuration depuis variables d'environnement
const PORT = process.env.PORT || 3000;

// PostgreSQL connection pool
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.POSTGRES_USER || 'appuser',
  password: process.env.POSTGRES_PASSWORD || 'securepass',
  database: process.env.POSTGRES_DB || 'CHANGEME',
});

// Redis client
let redisClient;
(async () => {
  redisClient = redis.createClient({
    socket: {
      host: process.env.REDIS_HOST || 'localhost',
      port: parseInt(process.env.REDIS_PORT || '6379'),
    }
  });

  redisClient.on('error', (err) => console.error('Redis Client Error', err));
  redisClient.on('connect', () => console.log('Connected to Redis'));

  await redisClient.connect();
})();

// Initialiser la base de données (créer la table products si elle n'existe pas)
async function initDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS products (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        stock INTEGER DEFAULT 0,
        created_at TIMESTAMP DEFAULT NOW()
      )
    `);
    console.log('Table products créée ou déjà existante');

    // Insérer des données de test si la table est vide
    const { rows } = await pool.query('SELECT COUNT(*) FROM products');
    if (parseInt(rows[0].count) === 0) {
      await pool.query(`
        INSERT INTO products (name, price, stock) VALUES 
        ('Laptop', 999.99, 10),
        ('Mouse', 29.99, 50),
        ('Keyboard', 79.99, 30),
        ('Monitor', 299.99, 15),
        ('Headphones', 149.99, 25)
      `);
      console.log('Données de test insérées');
    }
  } catch (err) {
    console.error('Erreur init database:', err.message);
  }
}

// Health check
app.get('/health', async (req, res) => {
  try {
    // Test PostgreSQL
    await pool.query('SELECT 1');
    
    // Test Redis
    await redisClient.ping();
    
    res.status(200).json({ 
      status: 'healthy',
      postgres: 'ok',
      redis: 'ok',
      timestamp: new Date().toISOString()
    });
  } catch (err) {
    res.status(503).json({ 
      status: 'unhealthy',
      error: err.message 
    });
  }
});

// GET /api/products - Liste tous les produits
app.get('/api/products', async (req, res) => {
  try {
    const { rows } = await pool.query(
      'SELECT * FROM products ORDER BY id'
    );
    res.json({
      success: true,
      count: rows.length,
      products: rows
    });
  } catch (err) {
    console.error('Error fetching products:', err);
    res.status(500).json({ 
      success: false,
      error: err.message 
    });
  }
});

// GET /api/products/:id - Détail d'un produit
app.get('/api/products/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { rows } = await pool.query(
      'SELECT * FROM products WHERE id = $1',
      [id]
    );
    
    if (rows.length === 0) {
      return res.status(404).json({ 
        success: false,
        error: 'Product not found' 
      });
    }
    
    res.json({
      success: true,
      product: rows[0]
    });
  } catch (err) {
    console.error('Error fetching product:', err);
    res.status(500).json({ 
      success: false,
      error: err.message 
    });
  }
});

// POST /api/cart - Ajouter un produit au panier (Redis)
app.post('/api/cart', async (req, res) => {
  try {
    const { sessionId, productId, quantity } = req.body;
    
    if (!sessionId || !productId || !quantity) {
      return res.status(400).json({ 
        success: false,
        error: 'Missing required fields: sessionId, productId, quantity' 
      });
    }
    
    // Stocker dans Redis (Hash)
    const cartKey = `cart:${sessionId}`;
    const productKey = `product:${productId}`;
    
    await redisClient.hSet(cartKey, productKey, quantity.toString());
    
    // Expiration du panier après 1 heure
    await redisClient.expire(cartKey, 3600);
    
    res.json({
      success: true,
      message: 'Product added to cart',
      sessionId,
      productId,
      quantity
    });
  } catch (err) {
    console.error('Error adding to cart:', err);
    res.status(500).json({ 
      success: false,
      error: err.message 
    });
  }
});

// GET /api/cart/:sessionId - Récupérer le panier
app.get('/api/cart/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const cartKey = `cart:${sessionId}`;
    
    const cart = await redisClient.hGetAll(cartKey);
    
    if (Object.keys(cart).length === 0) {
      return res.json({
        success: true,
        message: 'Cart is empty',
        sessionId,
        items: []
      });
    }
    
    // Transformer le hash Redis en array d'items
    const items = Object.entries(cart).map(([key, quantity]) => {
      const productId = key.replace('product:', '');
      return {
        productId: parseInt(productId),
        quantity: parseInt(quantity)
      };
    });
    
    res.json({
      success: true,
      sessionId,
      itemCount: items.length,
      items
    });
  } catch (err) {
    console.error('Error fetching cart:', err);
    res.status(500).json({ 
      success: false,
      error: err.message 
    });
  }
});

// DELETE /api/cart/:sessionId - Vider le panier
app.delete('/api/cart/:sessionId', async (req, res) => {
  try {
    const { sessionId } = req.params;
    const cartKey = `cart:${sessionId}`;
    
    await redisClient.del(cartKey);
    
    res.json({
      success: true,
      message: 'Cart cleared',
      sessionId
    });
  } catch (err) {
    console.error('Error clearing cart:', err);
    res.status(500).json({ 
      success: false,
      error: err.message 
    });
  }
});

// Route racine
app.get('/', (req, res) => {
  res.json({
    message: 'E-commerce Backend API',
    version: '1.0.0',
    endpoints: {
      health: 'GET /health',
      products: 'GET /api/products',
      product: 'GET /api/products/:id',
      addToCart: 'POST /api/cart',
      getCart: 'GET /api/cart/:sessionId',
      clearCart: 'DELETE /api/cart/:sessionId'
    }
  });
});

// Démarrer le serveur
app.listen(PORT, async () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`PostgreSQL: ${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || '5432'}`);
  console.log(`Redis: ${process.env.REDIS_HOST || 'localhost'}:${process.env.REDIS_PORT || '6379'}`);
  
  // Initialiser la base de données
  await initDatabase();
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, closing connections...');
  await pool.end();
  await redisClient.quit();
  process.exit(0);
});