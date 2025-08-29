# 🚀 Projet Microservices pour Apprentissage Kubernetes

Ce projet contient 4 microservices prêts pour le déploiement sur Kubernetes. Il est conçu pour apprendre les concepts de base de Kubernetes à travers un exemple pratique.

## 📋 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Service  │    │ Product Service │    │  Order Service  │    │Notification Svc │
│   (Node.js)     │    │   (Flask)       │    │   (Node.js)     │    │   (FastAPI)     │
│   Port: 3001    │    │   Port: 3002    │    │   Port: 3003    │    │   Port: 3004    │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Services

1. **User Service** (Node.js/Express)
   - Gestion des utilisateurs
   - CRUD complet
   - Port: 3001

2. **Product Service** (Python/Flask)
   - Catalogue des produits
   - Gestion du stock
   - Port: 3002

3. **Order Service** (Node.js/Express)
   - Gestion des commandes
   - Communication avec User et Product Services
   - Port: 3003

4. **Notification Service** (Python/FastAPI)
   - Système de notifications
   - API documentation automatique
   - Port: 3004

## 🛠️ Prérequis

- **Docker Desktop** installé et démarré
- **Kubernetes** activé dans Docker Desktop
- **kubectl** configuré
- **VS Code** avec l'extension Kubernetes
- **Node.js** et **Python** (pour le développement local)

## 🚀 Déploiement Manuel sur Kubernetes

### Étape 1: Construction des Images Docker

Construisez chaque service individuellement pour mieux comprendre le processus :

```powershell
# User Service (Node.js)
cd services\user-service
docker build -t user-service:latest .
cd ..\..

# Product Service (Python/Flask)
cd services\product-service
docker build -t product-service:latest .
cd ..\..

# Order Service (Node.js) 
cd services\order-service
docker build -t order-service:latest .
cd ..\..

# Notification Service (Python/FastAPI)
cd services\notification-service
docker build -t notification-service:latest .
cd ..\..
```

Vérifiez que toutes les images sont créées :
```powershell
docker images | Select-String "user-service|product-service|order-service|notification-service"
```

### Étape 2: Créer le Namespace (Optionnel)

```powershell
# Créer un namespace dédié pour isoler les ressources
kubectl apply -f k8s\namespace.yaml

# Vérifier la création
kubectl get namespaces
```

### Étape 3: Déployer les Services un par un

Déployez chaque service séparément pour observer le processus :

```powershell
# 1. User Service
kubectl apply -f k8s\user-service.yaml
kubectl get pods -l app=user-service -w
# Attendez que les pods soient "Running" avant de continuer

# 2. Product Service  
kubectl apply -f k8s\product-service.yaml
kubectl get pods -l app=product-service -w

# 3. Order Service (dépend des services précédents)
kubectl apply -f k8s\order-service.yaml
kubectl get pods -l app=order-service -w

# 4. Notification Service
kubectl apply -f k8s\notification-service.yaml
kubectl get pods -l app=notification-service -w
```

### Étape 4: Exposer les Services avec LoadBalancer

```powershell
# Exposer tous les services pour accès externe
kubectl apply -f k8s\loadbalancer-services.yaml

# Vérifier l'attribution des IPs externes
kubectl get services | Select-String "loadbalancer"
```

### Étape 5: Vérification du Déploiement

```powershell
# Voir l'état global
kubectl get pods,services

# Vérifier les logs de chaque service
kubectl logs -l app=user-service --tail=10
kubectl logs -l app=product-service --tail=10  
kubectl logs -l app=order-service --tail=10
kubectl logs -l app=notification-service --tail=10

# Tester la connectivité
Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3003/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3004/health" -UseBasicParsing
```

## 🌐 Options d'Exposition des Services

### Option 1: LoadBalancer (Recommandé avec Docker Desktop)

Les services sont exposés de manière permanente via localhost :

- **User Service**: <http://localhost:3001>
- **Product Service**: <http://localhost:3002>
- **Order Service**: <http://localhost:3003>
- **Notification Service**: <http://localhost:3004>
- **API Documentation**: <http://localhost:3004/docs>

### Option 2: NodePort (Ports spécifiques)

Pour utiliser les services NodePort avec des ports différents :

```powershell
kubectl apply -f k8s\nodeport-services.yaml
```

Accès via :
- User Service: <http://localhost:30001>
- Product Service: <http://localhost:30002>
- Order Service: <http://localhost:30003>
- Notification Service: <http://localhost:30004>

### Option 3: Port-Forward (Développement)

Pour un accès temporaire pendant le développement :

```powershell
# Dans des terminaux séparés
kubectl port-forward service/user-service 3001:3001
kubectl port-forward service/product-service 3002:3002
kubectl port-forward service/order-service 3003:3003
kubectl port-forward service/notification-service 3004:3004
```

**Scripts automatisés disponibles :**
- `.\start-port-forwards.ps1` - Démarrer tous les port-forwards
- `.\stop-port-forwards.ps1` - Arrêter tous les port-forwards

## 📋 Commandes de Gestion Utiles

### Surveillance en Temps Réel

```powershell
# Surveiller les pods
kubectl get pods -w

# Surveiller les services  
kubectl get services -w

# Logs en temps réel
kubectl logs -f -l app=user-service
```

### Mise à l'Échelle

```powershell
# Augmenter le nombre de répliques
kubectl scale deployment user-service --replicas=3

# Vérifier la mise à l'échelle
kubectl get pods -l app=user-service
```

### Redémarrage

```powershell
# Redémarrer un déploiement
kubectl rollout restart deployment/user-service

# Voir l'historique des déploiements
kubectl rollout history deployment/user-service
```

### Endpoints Principaux

#### User Service
- `GET /health` - Health check
- `GET /users` - Liste des utilisateurs
- `POST /users` - Créer un utilisateur
- `GET /users/:id` - Détails d'un utilisateur

#### Product Service
- `GET /health` - Health check
- `GET /products` - Liste des produits
- `POST /products` - Créer un produit
- `GET /products/:id` - Détails d'un produit

#### Order Service
- `GET /health` - Health check
- `GET /orders` - Liste des commandes
- `POST /orders` - Créer une commande
- `PUT /orders/:id/status` - Mettre à jour le statut

#### Notification Service
- `GET /health` - Health check
- `GET /notifications` - Liste des notifications
- `POST /notifications` - Créer une notification
- `GET /docs` - Documentation de l'API

## 🧪 Test Local avec Docker Compose

Pour tester localement sans Kubernetes:

```bash
# Démarrer tous les services
docker-compose up -d

# Voir les logs
docker-compose logs -f

# Arrêter les services
docker-compose down
```

## 📚 Concepts Kubernetes Appris

Ce projet vous permettra d'apprendre:

### 1. **Pods et Deployments**
- Création de pods contenant vos applications
- Gestion des répliques avec Deployments
- Configuration des ressources (CPU/Memory)

### 2. **Services**
- Communication entre microservices
- Exposition des services (ClusterIP, NodePort)
- Load balancing automatique

### 3. **Health Checks**
- Liveness probes pour redémarrer les pods défaillants
- Readiness probes pour contrôler le trafic

### 4. **Variables d'Environnement**
- Configuration des applications via ConfigMaps
- Communication entre services

### 5. **Namespaces**
- Isolation des ressources
- Organisation des déploiements

## 🔧 Commandes Kubernetes Utiles

```bash
# Voir tous les pods
kubectl get pods

# Voir les services
kubectl get services

# Voir les détails d'un pod
kubectl describe pod <pod-name>

# Voir les logs d'un pod
kubectl logs <pod-name>

# Se connecter à un pod
kubectl exec -it <pod-name> -- /bin/sh

# Supprimer un déploiement
kubectl delete -f k8s/user-service.yaml

# Appliquer tous les fichiers YAML
kubectl apply -f k8s/

# Voir l'utilisation des ressources
kubectl top pods
```

## 🐛 Dépannage

### Problèmes Courants

1. **Pods en statut "ImagePullBackOff"**
   ```bash
   # Vérifier que les images sont construites
   docker images | grep -E "(user|product|order|notification)-service"
   ```

2. **Services inaccessibles**
   ```bash
   # Vérifier que les services sont exposés
   kubectl get services
   
   # Vérifier les endpoints
   kubectl get endpoints
   ```

3. **Pods qui redémarrent**
   ```bash
   # Voir les logs pour identifier le problème
   kubectl logs <pod-name> --previous
   ```

### Nettoyage et Redéploiement

Pour supprimer tout le déploiement et recommencer :

```powershell
# Supprimer tous les services LoadBalancer
kubectl delete -f k8s\loadbalancer-services.yaml

# Supprimer tous les services et déploiements
kubectl delete -f k8s\user-service.yaml
kubectl delete -f k8s\product-service.yaml  
kubectl delete -f k8s\order-service.yaml
kubectl delete -f k8s\notification-service.yaml

# Supprimer les services NodePort (si utilisés)
kubectl delete -f k8s\nodeport-services.yaml

# Vérifier que tout est supprimé
kubectl get pods,services

# Optionnel: supprimer le namespace
kubectl delete -f k8s\namespace.yaml
```

**Suppression rapide par label :**

```powershell
# Supprimer tous les déploiements et services des microservices
kubectl delete all -l app in (user-service,product-service,order-service,notification-service)
```

## 🔄 Workflow de Développement Recommandé

### Déploiement Initial

1. **Construction :** Construire toutes les images Docker
2. **Test local :** Utiliser `docker-compose up` pour tester localement  
3. **Déploiement K8s :** Déployer sur Kubernetes étape par étape
4. **Exposition :** Choisir LoadBalancer pour un accès permanent

### Modifications et Tests

1. **Modifier le code** dans un service
2. **Reconstruire l'image :** `docker build -t service-name:latest .`
3. **Redéployer :** `kubectl rollout restart deployment/service-name`
4. **Vérifier :** `kubectl logs -l app=service-name`

### Debug et Diagnostic

```powershell
# Voir les détails d'un pod
kubectl describe pod <pod-name>

# Se connecter à un pod
kubectl exec -it <pod-name> -- /bin/sh

# Voir les événements du cluster
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 📖 Exercices d'Apprentissage

### Niveau Débutant
1. Changer le nombre de répliques d'un service
2. Modifier les health checks
3. Ajouter une variable d'environnement

### Niveau Intermédiaire
1. Créer un ConfigMap pour la configuration
2. Ajouter des limites de ressources
3. Créer un Ingress pour l'accès externe

### Niveau Avancé
1. Implémenter un HorizontalPodAutoscaler
2. Ajouter des PersistentVolumes
3. Configurer des NetworkPolicies

## 🤝 Contributing

N'hésitez pas à:
- Proposer des améliorations
- Ajouter de nouvelles fonctionnalités
- Corriger des bugs
- Améliorer la documentation

## 📄 Licence

Ce projet est à des fins éducatives. Utilisez-le librement pour apprendre Kubernetes!

---

🎉 **Bon apprentissage de Kubernetes !**
