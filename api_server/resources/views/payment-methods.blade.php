@extends('layout')

@section('content')
<!-- Main Content -->
<div class="container mx-auto px-4 py-8">
    <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">💳 Payment Methods</h1>
        <button onclick="showAddCardModal()" class="bg-teal-500 hover:bg-teal-600 px-6 py-2 rounded-lg transition">
            <i class="fas fa-plus mr-2"></i>Add Card
        </button>
    </div>

    <!-- Cards Grid -->
    <div id="cardsContainer" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Cards will be loaded here -->
    </div>

    <!-- Empty State -->
    <div id="emptyState" class="text-center py-20 hidden">
        <i class="fas fa-credit-card text-6xl text-gray-600 mb-4"></i>
        <p class="text-xl text-gray-400 mb-4">No payment methods added</p>
        <button onclick="showAddCardModal()" class="bg-teal-500 hover:bg-teal-600 px-6 py-3 rounded-lg transition">
            <i class="fas fa-plus mr-2"></i>Add Your First Card
        </button>
    </div>
</div>

<!-- Add Card Modal -->
<div id="addCardModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-gray-800 rounded-lg p-8 max-w-md w-full mx-4">
        <div class="flex justify-between items-center mb-6">
            <h2 class="text-2xl font-bold">Add Payment Method</h2>
            <button onclick="closeAddCardModal()" class="text-gray-400 hover:text-white">
                <i class="fas fa-times text-xl"></i>
            </button>
        </div>

        <form id="addCardForm" class="space-y-4">
            <div>
                <label for="cardHolderName" class="block text-sm font-medium mb-2">Card Holder Name</label>
                <input type="text" id="cardHolderName" name="card_holder_name" autocomplete="cc-name" required 
                       class="w-full bg-gray-700 border border-gray-600 rounded-lg px-4 py-2 focus:outline-none focus:border-teal-500">
            </div>

            <div>
                <label for="cardNumber" class="block text-sm font-medium mb-2">Card Number</label>
                <input type="text" id="cardNumber" name="card_number" autocomplete="cc-number" required maxlength="19" placeholder="1234 5678 9012 3456"
                       oninput="formatCardNumber(this)"
                       class="w-full bg-gray-700 border border-gray-600 rounded-lg px-4 py-2 focus:outline-none focus:border-teal-500 font-mono text-lg tracking-wider">
            </div>

            <div>
                <label for="cardType" class="block text-sm font-medium mb-2">Card Type</label>
                <select id="cardType" name="card_type" autocomplete="cc-type" class="w-full bg-gray-700 border border-gray-600 rounded-lg px-4 py-2 focus:outline-none focus:border-teal-500">
                    <option value="visa">Visa</option>
                    <option value="mastercard">Mastercard</option>
                    <option value="amex">American Express</option>
                </select>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label for="expiryMonth" class="block text-sm font-medium mb-2">Expiry Month</label>
                    <input type="text" id="expiryMonth" name="expiry_month" autocomplete="cc-exp-month" required maxlength="2" placeholder="MM"
                           class="w-full bg-gray-700 border border-gray-600 rounded-lg px-4 py-2 focus:outline-none focus:border-teal-500">
                </div>
                <div>
                    <label for="expiryYear" class="block text-sm font-medium mb-2">Expiry Year</label>
                    <input type="text" id="expiryYear" name="expiry_year" autocomplete="cc-exp-year" required maxlength="4" placeholder="YYYY"
                           class="w-full bg-gray-700 border border-gray-600 rounded-lg px-4 py-2 focus:outline-none focus:border-teal-500">
                </div>
            </div>

            <div class="flex items-center">
                <input type="checkbox" id="isDefault" name="is_default" class="mr-2">
                <label for="isDefault" class="text-sm">Set as default payment method</label>
            </div>

            <div class="flex gap-4 mt-6">
                <button type="button" onclick="closeAddCardModal()" 
                        class="flex-1 bg-gray-700 hover:bg-gray-600 px-6 py-2 rounded-lg transition">
                    Cancel
                </button>
                <button type="submit" 
                        class="flex-1 bg-teal-500 hover:bg-teal-600 px-6 py-2 rounded-lg transition">
                    Add Card
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    const API_URL = 'http://127.0.0.1:8000/api';
    let token = null;

    // Get token from localStorage
    function getToken() {
        const token = localStorage.getItem('token');
        if (!token) {
            window.location.href = '/login';
            return null;
        }
        return token;
    }

    // Load payment methods
    async function loadPaymentMethods() {
        token = getToken();
        if (!token) {
            window.location.href = '/login';
            return;
        }

        try {
            const response = await fetch(`${API_URL}/payment-methods`, {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json'
                }
            });

            const data = await response.json();
            
            if (data.success) {
                displayPaymentMethods(data.data);
            }
        } catch (error) {
            console.error('Error loading payment methods:', error);
        }
    }

    // Display payment methods
    function displayPaymentMethods(cards) {
        const container = document.getElementById('cardsContainer');
        const emptyState = document.getElementById('emptyState');

        if (cards.length === 0) {
            container.classList.add('hidden');
            emptyState.classList.remove('hidden');
            return;
        }

        container.classList.remove('hidden');
        emptyState.classList.add('hidden');

        container.innerHTML = cards.map(card => `
            <div class="bg-gradient-to-br ${getCardGradient(card.card_type)} rounded-xl p-6 border ${card.is_default ? 'border-teal-400 shadow-lg shadow-teal-500/50' : 'border-gray-600'} relative overflow-hidden transform hover:scale-105 transition-all duration-300">
                <!-- Card Pattern Background -->
                <div class="absolute top-0 right-0 opacity-10">
                    <i class="fas fa-credit-card text-8xl"></i>
                </div>
                
                <!-- Card Header -->
                <div class="flex justify-between items-start mb-6 relative z-10">
                    <div class="flex items-center gap-2">
                        <i class="fas fa-credit-card text-2xl ${getCardIconColor(card.card_type)}"></i>
                        <span class="text-xs font-semibold uppercase tracking-wider ${getCardIconColor(card.card_type)}">${card.card_type}</span>
                    </div>
                    ${card.is_default ? '<span class="bg-teal-500 text-white text-xs px-3 py-1 rounded-full font-bold shadow-lg"><i class="fas fa-check mr-1"></i>DEFAULT</span>' : ''}
                </div>
                
                <!-- Card Number -->
                <p class="text-white font-mono text-xl mb-4 tracking-widest relative z-10">
                    •••• •••• •••• ${card.card_last_four}
                </p>
                
                <!-- Card Details -->
                <div class="flex justify-between items-end relative z-10">
                    <div>
                        <p class="text-gray-300 text-xs mb-1 uppercase tracking-wider">Card Holder</p>
                        <h3 class="text-white font-bold text-lg">${card.card_holder_name}</h3>
                    </div>
                    <div class="text-right">
                        <p class="text-gray-300 text-xs mb-1 uppercase tracking-wider">Expires</p>
                        <p class="text-white font-mono font-bold">${card.expiry_month}/${card.expiry_year}</p>
                    </div>
                </div>
                
                <!-- Card Actions -->
                <div class="flex gap-2 mt-6 relative z-10">
                    ${!card.is_default ? `
                        <button onclick="setDefault(${card.id})" class="flex-1 bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 backdrop-blur px-4 py-2 rounded-lg text-sm font-bold transition transform hover:scale-105 shadow-lg">
                            <i class="fas fa-star mr-1"></i> Set Default
                        </button>
                    ` : ''}
                    <button onclick="deleteCard(${card.id})" class="${!card.is_default ? 'flex-1' : 'w-full'} bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 backdrop-blur px-4 py-2 rounded-lg text-sm font-bold transition transform hover:scale-105 shadow-lg">
                        <i class="fas fa-trash mr-1"></i> Delete
                    </button>
                </div>
            </div>
        `).join('');
    }

    // Get card gradient based on type
    function getCardGradient(type) {
        const gradients = {
            'visa': 'from-blue-600 to-blue-800',
            'mastercard': 'from-orange-600 to-red-700',
            'amex': 'from-green-600 to-teal-700'
        };
        return gradients[type] || 'from-gray-700 to-gray-800';
    }

    // Get card icon color based on type
    function getCardIconColor(type) {
        const colors = {
            'visa': 'text-blue-200',
            'mastercard': 'text-orange-200',
            'amex': 'text-green-200'
        };
        return colors[type] || 'text-gray-200';
    }

    // Show add card modal
    function showAddCardModal() {
        document.getElementById('addCardModal').classList.remove('hidden');
    }

    // Close add card modal
    function closeAddCardModal() {
        document.getElementById('addCardModal').classList.add('hidden');
        document.getElementById('addCardForm').reset();
    }

    // Add card
    document.getElementById('addCardForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const cardData = {
            card_holder_name: document.getElementById('cardHolderName').value,
            card_number: document.getElementById('cardNumber').value.replace(/\s/g, ''),
            card_type: document.getElementById('cardType').value,
            expiry_month: document.getElementById('expiryMonth').value,
            expiry_year: document.getElementById('expiryYear').value,
            is_default: document.getElementById('isDefault').checked
        };

        try {
            const response = await fetch(`${API_URL}/payment-methods`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json',
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(cardData)
            });

            const data = await response.json();

            if (data.success) {
                closeAddCardModal();
                loadPaymentMethods();
                alert('✅ Card added successfully!');
            } else {
                alert('❌ Error: ' + (data.message || 'Failed to add card'));
            }
        } catch (error) {
            alert('❌ Error adding card');
            console.error(error);
        }
    });

    // Set default card
    async function setDefault(cardId) {
        if (!confirm('Set this card as default?')) return;

        try {
            const response = await fetch(`${API_URL}/payment-methods/${cardId}/set-default`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json'
                }
            });

            const data = await response.json();

            if (data.success) {
                loadPaymentMethods();
                alert('✅ Default card updated!');
            }
        } catch (error) {
            alert('❌ Error updating default card');
            console.error(error);
        }
    }

    // Delete card
    async function deleteCard(cardId) {
        if (!confirm('Are you sure you want to delete this card?')) return;

        try {
            const response = await fetch(`${API_URL}/payment-methods/${cardId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json'
                }
            });

            const data = await response.json();

            if (data.success) {
                loadPaymentMethods();
                alert('✅ Card deleted successfully!');
            }
        } catch (error) {
            alert('❌ Error deleting card');
            console.error(error);
        }
    }

    // Format card number input (4'lü gruplar)
    function formatCardNumber(input) {
        // Sadece rakamları al
        let value = input.value.replace(/\D/g, '');
        
        // 16 haneyle sınırla
        value = value.substring(0, 16);
        
        // 4'lü gruplara ayır
        let formattedValue = value.match(/.{1,4}/g)?.join(' ') || value;
        
        // Input'a geri yaz
        input.value = formattedValue;
    }

    // Expiry month formatı (01-12)
    document.getElementById('expiryMonth').addEventListener('input', (e) => {
        let value = e.target.value.replace(/\D/g, '');
        if (parseInt(value) > 12) value = '12';
        if (parseInt(value) < 1 && value.length === 2) value = '01';
        e.target.value = value;
    });

    // Load on page load
    loadPaymentMethods();
</script>
@endsection
