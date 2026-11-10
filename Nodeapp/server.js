
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Connect to AWS RDS MySQL
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

db.connect((err) => {
  if (err) {
    console.error('RDS connection failed:', err.message);
  } else {
    console.log('Connected to AWS RDS MySQL successfully!');
  }
});

// Health check for AWS ALB
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    message: 'Backend is healthy'
  });
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
