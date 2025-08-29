const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const axios = require('axios');

const app = express();
const PORT = process.env.PORT || 3003;

// Configuration des services
const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://user-service:3001';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3002';
const NOTIFICATION_SERVICE_URL = process.env.NOTIFICATION_SERVICE_URL || 'http://notification-service:3004';

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Données simulées
let orders = [
  {
    id: 1,
    userId: 1,
    productId: 1,
    quantity: 1,
    totalPrice: 1299.99,
    status: 'confirmed',
    createdAt: new Date('2024-01-15'),
    updatedAt: new Date('2024-01-15')
  },
  {
    id: 2,
    userId: 2,
    productId: 2,
    quantity: 2,
    totalPrice: 2399.98,
    status: 'shipped',
    createdAt: new Date('2024-01-16'),
    updatedAt: new Date('2024-01-17')
  }
];

// Helper function pour vérifier si un utilisateur existe
async function checkUserExists(userId) {
  try {
    const response = await axios.get(`${USER_SERVICE_URL}/users/${userId}`);
    return response.status === 200;
  } catch (error) {
    return false;
  }
}

// Helper function pour vérifier si un produit existe et son prix
async function getProductInfo(productId) {
  try {
    const response = await axios.get(`${PRODUCT_SERVICE_URL}/products/${productId}`);
    return response.data;
  } catch (error) {
    return null;
  }
}

// Helper function pour envoyer une notification
async function sendNotification(userId, message, type = 'order') {
  try {
    await axios.post(`${NOTIFICATION_SERVICE_URL}/notifications`, {
      userId,
      message,
      type
    });
  } catch (error) {
    console.log('Erreur envoi notification:', error.message);
  }
}

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'order-service', timestamp: new Date() });
});

app.get('/orders', (req, res) => {
  const { userId, status } = req.query;
  let filteredOrders = orders;
  
  if (userId) {
    filteredOrders = filteredOrders.filter(o => o.userId === parseInt(userId));
  }
  
  if (status) {
    filteredOrders = filteredOrders.filter(o => o.status === status);
  }
  
  res.json(filteredOrders);
});

app.get('/orders/:id', (req, res) => {
  const order = orders.find(o => o.id === parseInt(req.params.id));
  if (!order) {
    return res.status(404).json({ error: 'Commande non trouvée' });
  }
  res.json(order);
});

app.post('/orders', async (req, res) => {
  const { userId, productId, quantity = 1 } = req.body;
  
  if (!userId || !productId) {
    return res.status(400).json({ error: 'userId et productId requis' });
  }
  
  // Vérifier que l'utilisateur existe
  const userExists = await checkUserExists(userId);
  if (!userExists) {
    return res.status(404).json({ error: 'Utilisateur non trouvé' });
  }
  
  // Vérifier que le produit existe et récupérer ses infos
  const product = await getProductInfo(productId);
  if (!product) {
    return res.status(404).json({ error: 'Produit non trouvé' });
  }
  
  if (product.stock < quantity) {
    return res.status(400).json({ error: 'Stock insuffisant' });
  }
  
  const newOrder = {
    id: orders.length + 1,
    userId,
    productId,
    quantity,
    totalPrice: product.price * quantity,
    status: 'pending',
    createdAt: new Date(),
    updatedAt: new Date()
  };
  
  orders.push(newOrder);
  
  // Envoyer une notification
  await sendNotification(
    userId, 
    `Votre commande #${newOrder.id} pour ${product.name} a été créée.`,
    'order_created'
  );
  
  res.status(201).json(newOrder);
});

app.put('/orders/:id/status', async (req, res) => {
  const orderId = parseInt(req.params.id);
  const { status } = req.body;
  
  const validStatuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({ error: 'Status invalide' });
  }
  
  const orderIndex = orders.findIndex(o => o.id === orderId);
  if (orderIndex === -1) {
    return res.status(404).json({ error: 'Commande non trouvée' });
  }
  
  orders[orderIndex].status = status;
  orders[orderIndex].updatedAt = new Date();
  
  // Envoyer une notification de changement de statut
  await sendNotification(
    orders[orderIndex].userId,
    `Le statut de votre commande #${orderId} a été mis à jour: ${status}`,
    'order_status'
  );
  
  res.json(orders[orderIndex]);
});

app.delete('/orders/:id', (req, res) => {
  const orderId = parseInt(req.params.id);
  const orderIndex = orders.findIndex(o => o.id === orderId);
  
  if (orderIndex === -1) {
    return res.status(404).json({ error: 'Commande non trouvée' });
  }
  
  orders.splice(orderIndex, 1);
  res.status(204).send();
});

// Route pour les statistiques
app.get('/orders/stats/summary', (req, res) => {
  const totalOrders = orders.length;
  const totalRevenue = orders.reduce((sum, order) => sum + order.totalPrice, 0);
  const ordersByStatus = orders.reduce((acc, order) => {
    acc[order.status] = (acc[order.status] || 0) + 1;
    return acc;
  }, {});
  
  res.json({
    totalOrders,
    totalRevenue,
    ordersByStatus
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Order Service démarré sur le port ${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
});
