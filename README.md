# 🚀 Microservices Project for Kubernetes Learning

This project contains 4 microservices ready for Kubernetes deployment. It's designed to learn basic Kubernetes concepts through a practical example.

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
   - User management
   - Full CRUD operations
   - Port: 3001

2. **Product Service** (Python/Flask)
   - Product catalog
   - Stock management
   - Port: 3002

3. **Order Service** (Node.js/Express)
   - Order management
   - Communicates with User and Product Services
   - Port: 3003

4. **Notification Service** (Python/FastAPI)
   - Notification system
   - Automatic API documentation
   - Port: 3004

## 🛠️ Prerequisites

- **Docker Desktop** installed and running
- **Kubernetes** enabled in Docker Desktop
- **kubectl** configured
- **VS Code** with Kubernetes extension
- **Node.js** and **Python** (for local development)

## 🚀 Manual Deployment on Kubernetes

### Step 1: Building Docker Images

Build each service individually to better understand the process:

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

Verify all images are created:
```powershell
docker images | Select-String "user-service|product-service|order-service|notification-service"
```

### Step 2: Create Namespace (Optional)

```powershell
# Create a dedicated namespace to isolate resources
kubectl apply -f k8s\namespace.yaml

# Verify creation
kubectl get namespaces
```

### Step 3: Deploy Services One by One

Deploy each service separately to observe the process:

```powershell
# 1. User Service
kubectl apply -f k8s\user-service.yaml
kubectl get pods -l app=user-service -w
# Wait for pods to be "Running" before continuing

# 2. Product Service  
kubectl apply -f k8s\product-service.yaml
kubectl get pods -l app=product-service -w

# 3. Order Service (depends on previous services)
kubectl apply -f k8s\order-service.yaml
kubectl get pods -l app=order-service -w

# 4. Notification Service
kubectl apply -f k8s\notification-service.yaml
kubectl get pods -l app=notification-service -w
```

### Step 4: Expose Services with LoadBalancer

```powershell
# Expose all services for external access
kubectl apply -f k8s\loadbalancer-services.yaml

# Verify external IP assignment
kubectl get services | Select-String "loadbalancer"
```

### Step 5: Deployment Verification

```powershell
# View global state
kubectl get pods,services

# Check logs for each service
kubectl logs -l app=user-service --tail=10
kubectl logs -l app=product-service --tail=10  
kubectl logs -l app=order-service --tail=10
kubectl logs -l app=notification-service --tail=10

# Test connectivity
Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3003/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3004/health" -UseBasicParsing
```

## 🌐 Service Exposure Options

### Option 1: LoadBalancer (Recommended with Docker Desktop)

Services are permanently exposed via localhost:

- **User Service**: <http://localhost:3001>
- **Product Service**: <http://localhost:3002>
- **Order Service**: <http://localhost:3003>
- **Notification Service**: <http://localhost:3004>
- **API Documentation**: <http://localhost:3004/docs>

### Option 2: NodePort (Specific Ports)

To use NodePort services with different ports:

```powershell
kubectl apply -f k8s\nodeport-services.yaml
```

Access via:
- User Service: <http://localhost:30001>
- Product Service: <http://localhost:30002>
- Order Service: <http://localhost:30003>
- Notification Service: <http://localhost:30004>

### Option 3: Port-Forward (Development)

For temporary access during development:

```powershell
# In separate terminals
kubectl port-forward service/user-service 3001:3001
kubectl port-forward service/product-service 3002:3002
kubectl port-forward service/order-service 3003:3003
kubectl port-forward service/notification-service 3004:3004
```

**Automated scripts available:**
- `.\start-port-forwards.ps1` - Start all port-forwards
- `.\stop-port-forwards.ps1` - Stop all port-forwards

## 📋 Useful Management Commands

### Real-time Monitoring

```powershell
# Monitor pods
kubectl get pods -w

# Monitor services  
kubectl get services -w

# Real-time logs
kubectl logs -f -l app=user-service
```

### Scaling

```powershell
# Increase number of replicas
kubectl scale deployment user-service --replicas=3

# Verify scaling
kubectl get pods -l app=user-service
```

### Restart

```powershell
# Restart a deployment
kubectl rollout restart deployment/user-service

# View deployment history
kubectl rollout history deployment/user-service
```

### Endpoints Principaux

#### User Service
- `GET /health` - Health check
- `GET /users` - List users
- `POST /users` - Create user
- `GET /users/:id` - User details

#### Product Service
- `GET /health` - Health check
- `GET /products` - List products
- `POST /products` - Create product
- `GET /products/:id` - Product details

#### Order Service
- `GET /health` - Health check
- `GET /orders` - List orders
- `POST /orders` - Create order
- `PUT /orders/:id/status` - Update status

#### Notification Service
- `GET /health` - Health check
- `GET /notifications` - List notifications
- `POST /notifications` - Create notification
- `GET /docs` - API documentation

## 🧪 Local Testing with Docker Compose

To test locally without Kubernetes:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📚 Kubernetes Concepts Learned

This project will help you learn:

### 1. **Pods and Deployments**
- Creating pods containing your applications
- Managing replicas with Deployments
- Resource configuration (CPU/Memory)

### 2. **Services**
- Inter-microservice communication
- Service exposure (ClusterIP, NodePort)
- Automatic load balancing

### 3. **Health Checks**
- Liveness probes to restart failed pods
- Readiness probes to control traffic

### 4. **Environment Variables**
- Application configuration via ConfigMaps
- Inter-service communication

### 5. **Namespaces**
- Resource isolation
- Deployment organization

## 🔧 Useful Kubernetes Commands

```powershell
# View all pods
kubectl get pods

# View services
kubectl get services

# View pod details
kubectl describe pod <pod-name>

# View pod logs
kubectl logs <pod-name>

# Connect to a pod
kubectl exec -it <pod-name> -- /bin/sh

# Delete a deployment
kubectl delete -f k8s\user-service.yaml

# Apply all YAML files
kubectl apply -f k8s\

# View resource usage
kubectl top pods
```

## 🐛 Troubleshooting

### Common Issues

1. **Pods in "ImagePullBackOff" status**
   ```powershell
   # Verify images are built
   docker images | Select-String "user-service|product-service|order-service|notification-service"
   ```

2. **Services inaccessible**
   ```powershell
   # Verify services are exposed
   kubectl get services
   
   # Check endpoints
   kubectl get endpoints
   ```

3. **Pods restarting**
   ```powershell
   # View logs to identify the problem
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

# View cluster events
kubectl get events --sort-by=.metadata.creationTimestamp
```

## 📖 Learning Exercises

### Beginner Level
1. Change the number of replicas for a service
2. Modify health checks
3. Add an environment variable

### Intermediate Level
1. Create a ConfigMap for configuration
2. Add resource limits
3. Create an Ingress for external access

### Advanced Level
1. Implement a HorizontalPodAutoscaler
2. Add PersistentVolumes
3. Configure NetworkPolicies

## 🤝 Contributing

Feel free to:
- Propose improvements
- Add new features
- Fix bugs
- Improve documentation

## 📄 License

This project is for educational purposes. Use it freely to learn Kubernetes!

---

🎉 **Happy Kubernetes Learning!**
