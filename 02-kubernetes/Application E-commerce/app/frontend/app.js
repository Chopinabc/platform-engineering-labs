// Générer ou récupérer l'ID de session
let sessionId = localStorage.getItem('sessionId');
if (!sessionId) {
    sessionId = 'session-' + Date.now() + '-' + Math.random().toString(36).substring(7);
    localStorage.setItem('sessionId', sessionId);
}
document.getElementById('sessionId').textContent = `Session ID: ${sessionId}`;

// Afficher un message
function showMessage(message, type = 'success') {
    const messagesContainer = document.getElementById('messages');
    const messageDiv = document.createElement('div');
    messageDiv.className = type;
    messageDiv.textContent = message;
    messagesContainer.innerHTML = '';
    messagesContainer.appendChild(messageDiv);
    setTimeout(() => messageDiv.remove(), 3000);
}

// Charger les produits
async function loadProducts() {
    try {
        const response = await fetch('/api/products');
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        const data = await response.json();
        displayProducts(data.products);
    } catch (error) {
        console.error('Erreur:', error);
        showMessage('Impossible de charger les produits', 'error');
    }
}

function displayProducts(products) {
    const container = document.getElementById('products-container');
    container.className = 'products-grid';
    container.innerHTML = '';
    products.forEach(product => {
        const card = document.createElement('div');
        card.className = 'product-card';
        card.innerHTML = `
            <h3>${product.name}</h3>
            <p class="price">${product.price} €</p>
            <p class="stock">Stock: ${product.stock}</p>
            <button onclick="addToCart(${product.id})" ${product.stock === 0 ? 'disabled' : ''}>
                ${product.stock === 0 ? 'Rupture' : 'Ajouter'}
            </button>
        `;
        container.appendChild(card);
    });
}

// Ajouter au panier
async function addToCart(productId) {
    try {
        const response = await fetch('/api/cart', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ sessionId, productId, quantity: 1 })
        });
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        showMessage('Produit ajouté au panier !', 'success');
        loadCart();
    } catch (error) {
        console.error('Erreur:', error);
        showMessage('Erreur ajout panier', 'error');
    }
}

// Charger le panier
async function loadCart() {
    try {
        const response = await fetch(`/api/cart/${sessionId}`);
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        const data = await response.json();
        displayCart(data.items || []);
    } catch (error) {
        console.error('Erreur:', error);
    }
}

function displayCart(items) {
    const container = document.getElementById('cart-container');
    if (items.length === 0) {
        container.innerHTML = '<p>Votre panier est vide.</p>';
        return;
    }
    container.innerHTML = items.map(item => `
        <div class="cart-item">
            <span>Produit #${item.productId}</span>
            <span>Quantité: ${item.quantity}</span>
        </div>
    `).join('');
}

// Vider le panier
async function clearCart() {
    try {
        const response = await fetch(`/api/cart/${sessionId}`, { method: 'DELETE' });
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        showMessage('Panier vidé', 'success');
        loadCart();
    } catch (error) {
        console.error('Erreur:', error);
        showMessage('Erreur suppression panier', 'error');
    }
}

// Initialisation au chargement de la page
window.addEventListener('DOMContentLoaded', () => {
    loadProducts();
    loadCart();
});