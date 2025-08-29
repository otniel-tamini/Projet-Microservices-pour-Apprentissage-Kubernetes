const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Données simulées
let users = [
  { id: 1, name: 'Alice Dupont', email: 'alice@example.com', role: 'user' },
  { id: 2, name: 'Bob Martin', email: 'bob@example.com', role: 'admin' },
  { id: 3, name: 'Claire Bernard', email: 'claire@example.com', role: 'user' }
];

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'user-service', timestamp: new Date() });
});

app.get('/users', (req, res) => {
  res.json(users);
});

app.get('/users/:id', (req, res) => {
  const user = users.find(u => u.id === parseInt(req.params.id));
  if (!user) {
    return res.status(404).json({ error: 'Utilisateur non trouvé' });
  }
  res.json(user);
});

app.post('/users', (req, res) => {
  const { name, email, role = 'user' } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ error: 'Nom et email requis' });
  }
  
  const newUser = {
    id: users.length + 1,
    name,
    email,
    role
  };
  
  users.push(newUser);
  res.status(201).json(newUser);
});

app.put('/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  const userIndex = users.findIndex(u => u.id === userId);
  
  if (userIndex === -1) {
    return res.status(404).json({ error: 'Utilisateur non trouvé' });
  }
  
  users[userIndex] = { ...users[userIndex], ...req.body, id: userId };
  res.json(users[userIndex]);
});

app.delete('/users/:id', (req, res) => {
  const userId = parseInt(req.params.id);
  const userIndex = users.findIndex(u => u.id === userId);
  
  if (userIndex === -1) {
    return res.status(404).json({ error: 'Utilisateur non trouvé' });
  }
  
  users.splice(userIndex, 1);
  res.status(204).send();
});

app.listen(PORT, () => {
  console.log(`🚀 User Service démarré sur le port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
});
