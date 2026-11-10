require('dotenv').config();
const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json({ limit: '10mb' }));

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

db.connect((err) => {
  if (err) console.error('DB connection failed:', err.message);
  else console.log('Connected to the database successfully!');
});

// Get all occupants
app.get('/api/occupants', (req, res) => {
  db.query('SELECT * FROM occupants', (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// Add an occupant
app.post('/api/occupants', (req, res) => {
  const { id, name, roomId, status, joinedAt } = req.body;
  db.query(
    'INSERT INTO occupants (id, name, roomId, status, joinedAt) VALUES (?, ?, ?, ?, ?)',
    [id, name, roomId, status, joinedAt],
    (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true });
    }
  );
});

// Delete an occupant
app.delete('/api/occupants/:id', (req, res) => {
  db.query('DELETE FROM occupants WHERE id = ?', [req.params.id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

