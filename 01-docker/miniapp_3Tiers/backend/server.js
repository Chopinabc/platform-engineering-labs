const express = require('express');
const { Pool } = require('pg');

const app = express();

// Configuration PostgreSQL depuis les env vars
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Route racine
app.get('/', (req, res) => {
  res.send('Hello from Docker + PostgreSQL!');
});

// Route health - Teste la connexion DB
app.get('/health', async (req, res) => {
  try {
    const result = await pool.query('SELECT NOW() as current_time');
    res.json({
      status: 'OK',
      message: 'Database connection successful',
      timestamp: result.rows[0].current_time
    });
  } catch (err) {
    res.status(500).json({
      status: 'ERROR',
      message: err.message
    });
  }
});

// Route init-db - Crée une table de test
app.get('/init-db', async (req, res) => {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS visits (
        id SERIAL PRIMARY KEY,
        timestamp TIMESTAMP DEFAULT NOW()
      )
    `);
    res.json({ status: 'OK', message: 'Table "visits" created' });
  } catch (err) {
    res.status(500).json({ status: 'ERROR', message: err.message });
  }
});

// Route visit - Insère une visite
app.get('/visit', async (req, res) => {
  try {
    await pool.query('INSERT INTO visits DEFAULT VALUES');
    const result = await pool.query('SELECT COUNT(*) as total FROM visits');
    res.json({
      status: 'OK',
      message: 'Visit recorded',
      total_visits: parseInt(result.rows[0].total)
    });
  } catch (err) {
    res.status(500).json({ status: 'ERROR', message: err.message });
  }
});

// Lancement du serveur
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
  console.log(`DB_HOST: ${process.env.DB_HOST}`);
});