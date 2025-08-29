#!/bin/bash

echo "🚀 Déploiement des microservices sur Kubernetes..."

# Créer le namespace
echo "📁 Création du namespace..."
kubectl apply -f k8s/namespace.yaml

# Déployer tous les services
echo "🔧 Déploiement des services..."
kubectl apply -f k8s/user-service.yaml
kubectl apply -f k8s/product-service.yaml
kubectl apply -f k8s/order-service.yaml  
kubectl apply -f k8s/notification-service.yaml

# Déployer les services NodePort pour l'accès externe
echo "🌐 Configuration des accès externes..."
kubectl apply -f k8s/nodeport-services.yaml

echo "⏳ Attente du démarrage des pods..."
kubectl wait --for=condition=ready pod -l app=user-service --timeout=120s
kubectl wait --for=condition=ready pod -l app=product-service --timeout=120s
kubectl wait --for=condition=ready pod -l app=order-service --timeout=120s
kubectl wait --for=condition=ready pod -l app=notification-service --timeout=120s

echo "✅ Déploiement terminé!"
echo ""
echo "📊 Status des services:"
kubectl get pods,services

echo ""
echo "🌐 Accès aux services:"
echo "User Service: http://localhost:30001/health"
echo "Product Service: http://localhost:30002/health"
echo "Order Service: http://localhost:30003/health"
echo "Notification Service: http://localhost:30004/health"
echo "Notification API Docs: http://localhost:30004/docs"
