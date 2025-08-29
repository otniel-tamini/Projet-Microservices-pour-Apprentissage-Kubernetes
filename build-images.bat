@echo off
echo 🚀 Construction des images Docker pour tous les microservices...

echo 📦 Construction de user-service...
cd services\user-service
docker build -t user-service:latest .
cd ..\..

echo 📦 Construction de product-service...
cd services\product-service
docker build -t product-service:latest .
cd ..\..

echo 📦 Construction de order-service...
cd services\order-service
docker build -t order-service:latest .
cd ..\..

echo 📦 Construction de notification-service...
cd services\notification-service
docker build -t notification-service:latest .
cd ..\..

echo ✅ Toutes les images Docker ont été construites avec succès!
echo 📋 Images disponibles:
docker images | findstr "user-service product-service order-service notification-service"
