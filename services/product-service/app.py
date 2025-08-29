from flask import Flask, jsonify, request
from flask_cors import CORS
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)

# Données simulées
products = [
    {"id": 1, "name": "Laptop Dell XPS", "price": 1299.99, "category": "Informatique", "stock": 15},
    {"id": 2, "name": "iPhone 15 Pro", "price": 1199.99, "category": "Téléphones", "stock": 8},
    {"id": 3, "name": "Chaise de bureau", "price": 249.99, "category": "Mobilier", "stock": 22},
    {"id": 4, "name": "Écran 4K 27\"", "price": 349.99, "category": "Informatique", "stock": 12}
]

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        "status": "OK",
        "service": "product-service", 
        "timestamp": datetime.now().isoformat()
    })

@app.route('/products', methods=['GET'])
def get_products():
    category = request.args.get('category')
    if category:
        filtered_products = [p for p in products if p['category'].lower() == category.lower()]
        return jsonify(filtered_products)
    return jsonify(products)

@app.route('/products/<int:product_id>', methods=['GET'])
def get_product(product_id):
    product = next((p for p in products if p['id'] == product_id), None)
    if not product:
        return jsonify({"error": "Produit non trouvé"}), 404
    return jsonify(product)

@app.route('/products', methods=['POST'])
def create_product():
    data = request.get_json()
    
    required_fields = ['name', 'price', 'category']
    if not all(field in data for field in required_fields):
        return jsonify({"error": "Champs requis: name, price, category"}), 400
    
    new_product = {
        "id": len(products) + 1,
        "name": data['name'],
        "price": float(data['price']),
        "category": data['category'],
        "stock": data.get('stock', 0)
    }
    
    products.append(new_product)
    return jsonify(new_product), 201

@app.route('/products/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    product = next((p for p in products if p['id'] == product_id), None)
    if not product:
        return jsonify({"error": "Produit non trouvé"}), 404
    
    data = request.get_json()
    product.update({k: v for k, v in data.items() if k != 'id'})
    return jsonify(product)

@app.route('/products/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    global products
    products = [p for p in products if p['id'] != product_id]
    return '', 204

@app.route('/products/<int:product_id>/stock', methods=['PATCH'])
def update_stock(product_id):
    product = next((p for p in products if p['id'] == product_id), None)
    if not product:
        return jsonify({"error": "Produit non trouvé"}), 404
    
    data = request.get_json()
    if 'quantity' not in data:
        return jsonify({"error": "Quantité requise"}), 400
    
    product['stock'] = max(0, product['stock'] + data['quantity'])
    return jsonify(product)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 3002))
    app.run(host='0.0.0.0', port=port, debug=False)
    print(f"🚀 Product Service démarré sur le port {port}")
    print(f"📊 Health check: http://localhost:{port}/health")
