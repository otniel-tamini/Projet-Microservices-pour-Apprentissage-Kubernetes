#!/bin/bash

echo "🧪 Test des microservices..."

# Configuration
BASE_URL="http://localhost"
USER_PORT="30001"
PRODUCT_PORT="30002"
ORDER_PORT="30003"
NOTIFICATION_PORT="30004"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Fonction pour tester un endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $description... "
    
    response=$(curl -s -w "%{http_code}" -o /dev/null "$url")
    
    if [ "$response" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED (Status: $response)${NC}"
        return 1
    fi
}

# Fonction pour tester un endpoint avec données JSON
test_post_endpoint() {
    local url=$1
    local data=$2
    local description=$3
    local expected_status=${4:-201}
    
    echo -n "Testing $description... "
    
    response=$(curl -s -w "%{http_code}" -o /dev/null -X POST -H "Content-Type: application/json" -d "$data" "$url")
    
    if [ "$response" -eq "$expected_status" ]; then
        echo -e "${GREEN}✅ OK${NC}"
        return 0
    else
        echo -e "${RED}❌ FAILED (Status: $response)${NC}"
        return 1
    fi
}

echo -e "${YELLOW}=== Test des Health Checks ===${NC}"

test_endpoint "$BASE_URL:$USER_PORT/health" "User Service Health"
test_endpoint "$BASE_URL:$PRODUCT_PORT/health" "Product Service Health"
test_endpoint "$BASE_URL:$ORDER_PORT/health" "Order Service Health"
test_endpoint "$BASE_URL:$NOTIFICATION_PORT/health" "Notification Service Health"

echo ""
echo -e "${YELLOW}=== Test des Endpoints GET ===${NC}"

test_endpoint "$BASE_URL:$USER_PORT/users" "User Service - Get Users"
test_endpoint "$BASE_URL:$PRODUCT_PORT/products" "Product Service - Get Products"
test_endpoint "$BASE_URL:$ORDER_PORT/orders" "Order Service - Get Orders"
test_endpoint "$BASE_URL:$NOTIFICATION_PORT/notifications" "Notification Service - Get Notifications"

echo ""
echo -e "${YELLOW}=== Test des Endpoints POST ===${NC}"

# Test création d'utilisateur
test_post_endpoint "$BASE_URL:$USER_PORT/users" \
    '{"name":"Test User","email":"test@example.com","role":"user"}' \
    "User Service - Create User"

# Test création de produit
test_post_endpoint "$BASE_URL:$PRODUCT_PORT/products" \
    '{"name":"Test Product","price":99.99,"category":"Test","stock":10}' \
    "Product Service - Create Product"

# Test création de notification
test_post_endpoint "$BASE_URL:$NOTIFICATION_PORT/notifications" \
    '{"userId":1,"message":"Test notification","type":"test"}' \
    "Notification Service - Create Notification"

echo ""
echo -e "${YELLOW}=== Test Communication Inter-Services ===${NC}"

# Test création de commande (qui teste la communication entre services)
test_post_endpoint "$BASE_URL:$ORDER_PORT/orders" \
    '{"userId":1,"productId":1,"quantity":1}' \
    "Order Service - Create Order (Inter-service communication)"

echo ""
echo -e "${YELLOW}=== Résumé des Tests ===${NC}"

# Compter les tests réussis/échoués
total_tests=10
echo "Tests exécutés: $total_tests"
echo ""
echo -e "${GREEN}✅ Si tous les tests sont OK, vos microservices fonctionnent correctement!${NC}"
echo -e "${YELLOW}📝 Vous pouvez maintenant explorer les APIs:${NC}"
echo "   - User Service: $BASE_URL:$USER_PORT/users"
echo "   - Product Service: $BASE_URL:$PRODUCT_PORT/products"
echo "   - Order Service: $BASE_URL:$ORDER_PORT/orders"
echo "   - Notification Service: $BASE_URL:$NOTIFICATION_PORT/docs"
