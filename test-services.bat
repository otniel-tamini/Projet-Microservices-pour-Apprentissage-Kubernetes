@echo off
echo 🧪 Test des microservices...

set BASE_URL=http://localhost
set USER_PORT=30001
set PRODUCT_PORT=30002
set ORDER_PORT=30003
set NOTIFICATION_PORT=30004

echo === Test des Health Checks ===

echo Testing User Service Health...
curl -s %BASE_URL%:%USER_PORT%/health
echo.

echo Testing Product Service Health...
curl -s %BASE_URL%:%PRODUCT_PORT%/health
echo.

echo Testing Order Service Health...
curl -s %BASE_URL%:%ORDER_PORT%/health
echo.

echo Testing Notification Service Health...
curl -s %BASE_URL%:%NOTIFICATION_PORT%/health
echo.

echo.
echo === Test des Endpoints GET ===

echo Testing User Service - Get Users...
curl -s %BASE_URL%:%USER_PORT%/users
echo.

echo Testing Product Service - Get Products...
curl -s %BASE_URL%:%PRODUCT_PORT%/products
echo.

echo Testing Order Service - Get Orders...
curl -s %BASE_URL%:%ORDER_PORT%/orders
echo.

echo Testing Notification Service - Get Notifications...
curl -s %BASE_URL%:%NOTIFICATION_PORT%/notifications
echo.

echo.
echo === Test des Endpoints POST ===

echo Testing User Service - Create User...
curl -s -X POST -H "Content-Type: application/json" -d "{\"name\":\"Test User\",\"email\":\"test@example.com\",\"role\":\"user\"}" %BASE_URL%:%USER_PORT%/users
echo.

echo Testing Product Service - Create Product...
curl -s -X POST -H "Content-Type: application/json" -d "{\"name\":\"Test Product\",\"price\":99.99,\"category\":\"Test\",\"stock\":10}" %BASE_URL%:%PRODUCT_PORT%/products
echo.

echo Testing Notification Service - Create Notification...
curl -s -X POST -H "Content-Type: application/json" -d "{\"userId\":1,\"message\":\"Test notification\",\"type\":\"test\"}" %BASE_URL%:%NOTIFICATION_PORT%/notifications
echo.

echo.
echo === Test Communication Inter-Services ===

echo Testing Order Service - Create Order...
curl -s -X POST -H "Content-Type: application/json" -d "{\"userId\":1,\"productId\":1,\"quantity\":1}" %BASE_URL%:%ORDER_PORT%/orders
echo.

echo.
echo === Résumé ===
echo ✅ Si vous voyez des réponses JSON, vos microservices fonctionnent!
echo.
echo 📝 Vous pouvez maintenant explorer les APIs:
echo    - User Service: %BASE_URL%:%USER_PORT%/users
echo    - Product Service: %BASE_URL%:%PRODUCT_PORT%/products  
echo    - Order Service: %BASE_URL%:%ORDER_PORT%/orders
echo    - Notification Service: %BASE_URL%:%NOTIFICATION_PORT%/docs
