<!-- Step 4: Bilet Tipi Seçimi -->
<div id="ticketStep4" class="ticket-step hidden">
    <div class="flex items-center justify-between mb-6">
        <h3 class="text-2xl font-bold text-white text-center flex-1">
            <i class="fas fa-users mr-2 text-orange-400"></i>Bilet Tiplerini Seçiniz
        </h3>
        <button onclick="goBackToStep(3)"
            class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
            <i class="fas fa-arrow-left mr-2"></i>Seans Değiştir
        </button>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Bilet Tipleri -->
        <div class="bg-white/10 p-6 rounded-xl">
            <h4 class="text-xl font-semibold text-white mb-4">
                <i class="fas fa-ticket-alt mr-2"></i>Bilet Tipleri
            </h4>

            <!-- Loading State -->
            <div id="ticketTypesLoading" class="text-center py-8">
                <div class="loading w-8 h-8 border-4 border-orange-400 border-t-transparent rounded-full mx-auto mb-4">
                </div>
                <p class="text-white text-sm">Fiyatlar hesaplanıyor...</p>
            </div>

            <!-- Ticket Types Container -->
            <div id="ticketTypesContainer" class="space-y-4 hidden">
                <!-- Bilet tipleri buraya yüklenecek -->
            </div>

            <!-- Summary -->
            <div class="mt-6 pt-4 border-t border-white/20">
                <div class="flex justify-between items-center text-lg font-bold text-white">
                    <span>Seçilen Biletler:</span>
                    <span id="selectedTicketCount" class="text-emerald-400">0</span>
                </div>
                <div id="ticketTypeSummary" class="mt-2 text-sm text-gray-300">Hiç bilet seçilmedi</div>
            </div>

            <!-- Continue Button -->
            <button id="continueToSeatSelection" onclick="goToSeatSelection()"
                class="w-full mt-6 bg-emerald-500 hover:bg-emerald-600 text-white py-3 rounded-xl font-bold disabled:bg-gray-600 disabled:cursor-not-allowed transition-all"
                disabled>
                <i class="fas fa-arrow-right mr-2"></i>Koltuk Seçimine Geç
            </button>
        </div>

        <!-- Fiyat Bilgileri -->
        <div class="bg-white/10 p-6 rounded-xl">
            <h4 class="text-xl font-semibold text-white mb-4">
                <i class="fas fa-calculator mr-2"></i>Hizmet Bedeli
            </h4>
            <!-- Base Prices -->
            <div id="priceInfo" class="space-y-3 text-white mb-4">
                <!-- Fiyat bilgileri buraya yüklenecek -->
            </div>
            <!-- Tax Calculation -->
            <div id="taxCalculationSection" class="border-t border-white/20 pt-4 hidden">
                <h5 class="text-white font-medium mb-3">
                    <i class="fas fa-receipt mr-1"></i>Hizmet Bedeli Detayı
                </h5>

                <div class="space-y-2 text-sm">
                    <div class="flex justify-between text-white">
                        <span>Ara Toplam:</span>
                        <span id="subtotalAmount">₺0</span>
                    </div>

                    <div id="taxBreakdown" class="space-y-1">
                        <!-- Hizmet bedeli detayları buraya gelecek -->
                    </div>

                    <div class="border-t border-white/20 pt-2 mt-2">
                        <div class="flex justify-between text-white font-bold">
                            <span>Toplam Hizmet Bedeli:</span>
                            <span id="totalTaxAmount" class="text-red-400">₺0</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Grand Total -->
            <div class="mt-6 pt-4 border-t border-white/20">
                <div class="flex justify-between items-center text-xl font-bold text-white">
                    <span>Genel Toplam:</span>
                    <span id="totalPricePreview" class="text-emerald-400">₺0</span>
                </div>
                <div id="taxSummaryInfo" class="text-xs text-gray-400 mt-1">
                    Hizmet bedeli hesaplanmadı
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Step 6: Müşteri Bilgileri ve Ödeme -->
<div id="ticketStep6" class="ticket-step hidden">
    <div class="flex items-center justify-between mb-6">
        <h3 class="text-2xl font-bold text-white text-center flex-1">
            <i class="fas fa-credit-card mr-2 text-yellow-400"></i>Müşteri Bilgileri ve Ödeme
        </h3>
        <button onclick="goBackToStep(5)"
            class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
            <i class="fas fa-arrow-left mr-2"></i>Koltuk Değiştir
        </button>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Müşteri Bilgileri -->
        <div class="bg-white/10 p-6 rounded-xl">
            <h4 class="text-xl font-semibold text-white mb-4">
                <i class="fas fa-user mr-2"></i>Müşteri Bilgileri
            </h4>

            <form id="customerForm" class="space-y-4">
                <div>
                    <label class="block text-white text-sm font-medium mb-2">
                        <i class="fas fa-user mr-1"></i>Ad Soyad *
                    </label>
                    <input type="text" id="customerName" placeholder="Ad ve soyadınızı girin" required
                        class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all">
                </div>

                <div>
                    <label class="block text-white text-sm font-medium mb-2">
                        <i class="fas fa-envelope mr-1"></i>E-posta *
                    </label>
                    <input type="email" id="customerEmail" placeholder="E-posta adresinizi girin" required
                        class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all">
                </div>

                <div>
                    <label class="block text-white text-sm font-medium mb-2">
                        <i class="fas fa-phone mr-1"></i>Telefon *
                    </label>
                    <input type="tel" id="customerPhone" placeholder="Telefon numaranızı girin" required
                        class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all">
                </div>

                <div>
                    <label class="block text-white text-sm font-medium mb-2">
                        <i class="fas fa-credit-card mr-1"></i>Ödeme Yöntemi
                    </label>
                    <select id="paymentMethod"
                        class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white focus:bg-white/20 focus:border-emerald-400 transition-all">
                        <option value="cash">💰 Nakit</option>
                        <option value="card">💳 Kredi Kartı</option>
                        <option value="online">🌐 Online Ödeme</option>
                    </select>
                </div>

                <div class="flex items-center mt-4">
                    <input type="checkbox" id="termsAccepted" required
                        class="w-4 h-4 text-emerald-600 bg-transparent border-white/20 rounded focus:ring-emerald-500">
                    <label for="termsAccepted" class="ml-2 text-sm text-gray-300">
                        <a href="#" class="text-emerald-400 hover:text-emerald-300">Kullanım Koşulları</a>'nı kabul
                        ediyorum
                    </label>
                </div>
            </form>
        </div>

        <!-- Sipariş Özeti -->
        <div class="bg-white/10 p-6 rounded-xl">
            <h4 class="text-xl font-semibold text-white mb-4">
                <i class="fas fa-receipt mr-2"></i>Sipariş Özeti
            </h4>

            <!-- Genel Bilgiler -->
            <div id="orderSummary" class="space-y-3 text-white mb-6">
                <!-- Order summary will be loaded here -->
            </div>

            <!-- Fiyat Detayları -->
            <div class="bg-white/5 p-4 rounded-lg mb-4">
                <h5 class="text-white font-medium mb-3 border-b border-white/20 pb-2">
                    <i class="fas fa-calculator mr-1"></i>Fiyat Detayları
                </h5>

                <div id="finalPriceBreakdown" class="space-y-2 text-sm">
                    <!-- Detaylı fiyat hesaplaması buraya gelecek -->
                </div>
            </div>

            <!-- Son Toplam -->
            <div class="border-t border-white/20 pt-4">
                <div class="flex justify-between items-center text-xl font-bold text-white mb-2">
                    <span>Ödenecek Tutar:</span>
                    <span id="totalPrice" class="text-emerald-400">₺0</span>
                </div>
                <div id="ticketCountInfo" class="text-sm text-gray-400">
                    Hizmet bedeli hesaplanmadı
                </div>
            </div>

            <!-- Complete Sale Button -->
            <button id="completeSaleBtn" onclick="completeSale()"
                class="w-full mt-6 bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 text-white py-4 rounded-xl font-bold text-lg transition-all transform hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed">
                <i class="fas fa-check-circle mr-2"></i>Ödemeyi Tamamla
            </button>
            <!-- Güvenlik Bilgisi -->
            <div class="mt-4 text-center">
                <p class="text-xs text-gray-400">
                    <i class="fas fa-shield-alt mr-1"></i>
                    Ödeme bilgileriniz güvenle şifrelenir
                </p>
            </div>
        </div>
    </div>
</div>

<script>
    const MAX_TICKETS_PER_ORDER = 6;
    // Payment Form JavaScript (Önceki kodunuzu kullanarak güncellenmiş hali)
    class PaymentForm {
        constructor() {
            this.selectedTicketTypes = {};
            this.ticketPrices = {};
            this.customerTypes = [];
            this.taxes = [];
            this.taxCalculation = null;

            // DOM Elements
            this.loadingElement = document.getElementById('ticketTypesLoading');
            this.typesContainer = document.getElementById('ticketTypesContainer');
            this.priceInfoElement = document.getElementById('priceInfo');
            this.countElement = document.getElementById('selectedTicketCount');
            this.summaryElement = document.getElementById('ticketTypeSummary');
            this.continueButton = document.getElementById('continueToSeatSelection');
            this.completeSaleBtn = document.getElementById('completeSaleBtn');

            // Tax Elements
            this.taxSectionElement = document.getElementById('taxCalculationSection');
            this.subtotalElement = document.getElementById('subtotalAmount');
            this.taxBreakdownElement = document.getElementById('taxBreakdown');
            this.totalTaxElement = document.getElementById('totalTaxAmount');
            this.taxSummaryElement = document.getElementById('taxSummaryInfo');

            // Hizmet bedelini yükle
            this.loadTaxes();
        }

        async loadTaxes() {
            try {
                const response = await axios.get('/api/taxes');
                this.taxes = response.data.data || [];
                console.log('Hizmet bedeli yüklendi:', this.taxes);
            } catch (error) {
                console.log('Hizmet bedeli yüklenemedi, varsayılan değer kullanılacak:', error);
                this.taxes = [
                    {
                        name: 'Hizmet Bedeli',
                        type: 'fixed',
                        rate: '2.00',
                        status: 'active',
                        formatted_name: 'Hizmet Bedeli (₺2)'
                    }
                ];
            }
        }

        async calculateTotalWithTaxes() {
            const subtotal = Object.entries(this.selectedTicketTypes).reduce((sum, [type, count]) => {
                return sum + (this.ticketPrices[type] * count);
            }, 0);

            const totalTickets = Object.values(this.selectedTicketTypes).reduce((sum, count) => sum + count, 0);

            if (totalTickets === 0) {
                this.taxCalculation = null;
                this.hideTaxSection();
                return;
            }

            try {
                const response = await axios.post('/api/taxes/calculate', {
                    subtotal: subtotal,
                    ticket_count: totalTickets
                });

                this.taxCalculation = response.data.data;
                this.showTaxSection();

            } catch (error) {
                console.log('Hizmet bedeli hesaplaması yapılamadı, manuel hesaplama:', error);

                const serviceFee = this.taxes.find(tax => tax.name === 'Hizmet Bedeli');
                const feeRate = parseFloat(serviceFee?.rate ?? 2);
                const taxAmount = feeRate * totalTickets;

                this.taxCalculation = {
                    subtotal: subtotal,
                    taxes: [{
                        name: 'Hizmet Bedeli',
                        type: 'fixed',
                        rate: feeRate,
                        amount: taxAmount,
                        formatted_name: `Hizmet Bedeli (${feeRate} ₺ x ${totalTickets} bilet)`
                    }],
                    total_tax_amount: taxAmount,
                    total: subtotal + taxAmount,
                    ticket_count: totalTickets
                };

                this.showTaxSection();
            }
        }

        showTaxSection() {
            if (!this.taxCalculation) return;

            this.taxSectionElement.classList.remove('hidden');

            // Ara toplam
            this.subtotalElement.textContent = `₺${this.taxCalculation.subtotal.toFixed(2)}`;

            // Hizmet bedeli detayları
            let taxHTML = '';
            this.taxCalculation.taxes.forEach(tax => {
                taxHTML += `
                <div class="flex justify-between text-gray-300">
                    <span>${tax.formatted_name || tax.name}:</span>
                    <span>₺${tax.amount.toFixed(2)}</span>
                </div>
            `;
            });
            this.taxBreakdownElement.innerHTML = taxHTML;

            // Toplam hizmet bedeli
            this.totalTaxElement.textContent = `₺${this.taxCalculation.total_tax_amount.toFixed(2)}`;
        }

        hideTaxSection() {
            this.taxSectionElement.classList.add('hidden');
        }

        async updateTotalPrice() {
            await this.calculateTotalWithTaxes();

            if (!this.taxCalculation) {
                document.getElementById('totalPricePreview').textContent = `₺0`;
                this.taxSummaryElement.textContent = 'Hizmet bedeli hesaplanmadı';
                return;
            }

            document.getElementById('totalPricePreview').textContent = `₺${this.taxCalculation.total.toFixed(2)}`;

            // Hizmet bedeli özet bilgisi
            const taxInfo = this.taxCalculation.taxes.map(tax =>
                tax.formatted_name || `${tax.name}`
            ).join(' + ');

            this.taxSummaryElement.innerHTML = `
            <div>${taxInfo} dahil</div>
            <div class="text-xs">
                Ara Toplam: ₺${this.taxCalculation.subtotal.toFixed(2)} + 
                Hizmet Bedeli: ₺${this.taxCalculation.total_tax_amount.toFixed(2)}
            </div>
        `;

            // Ödeme sayfasındaki toplam fiyatı da güncelle
            const totalPriceElement = document.getElementById('totalPrice');
            if (totalPriceElement) {
                totalPriceElement.textContent = `₺${this.taxCalculation.total.toFixed(2)}`;
            }

            // Bilet sayısını güncelle
            const selectedSeats = window.seatMap?.getSelectedSeats() || [];
            const ticketCountElement = document.getElementById('ticketCountInfo');
            if (ticketCountElement && this.taxCalculation) {
                ticketCountElement.innerHTML = `
                <div>${taxInfo} dahil • ${selectedSeats.length} bilet</div>
                <div class="text-xs text-gray-500">
                    Ara Toplam: ₺${this.taxCalculation.subtotal.toFixed(2)} + 
                    Hizmet Bedeli: ₺${this.taxCalculation.total_tax_amount.toFixed(2)}
                </div>
            `;
            }
        }

        async generateOrderSummary() {
            const selectedSeats = window.seatMap?.getSelectedSeats() || [];
            await this.calculateTotalWithTaxes();

            // Genel bilgiler
            let html = `
            <div class="space-y-3">
                <div class="flex justify-between">
                    <span>Film:</span>
                    <span class="font-medium">${selectedMovie?.title || 'N/A'}</span>
                </div>
                <div class="flex justify-between">
                    <span>Sinema:</span>
                    <span class="font-medium">${selectedCinema?.name || 'N/A'}</span>
                </div>
                <div class="flex justify-between">
                    <span>Seans:</span>
                    <span class="font-medium">${selectedShowtime?.startTime || 'N/A'}</span>
                </div>
                <div class="flex justify-between">
                    <span>Salon:</span>
                    <span class="font-medium">${selectedShowtime?.hall || 'N/A'}</span>
                </div>
                <div class="flex justify-between">
                    <span>Koltuklar:</span>
                    <span class="font-medium">${selectedSeats.map(s => s.code).join(', ')}</span>
                </div>
            </div>
        `;

            document.getElementById('orderSummary').innerHTML = html;

            // Fiyat detayları
            if (this.taxCalculation) {
                let priceHTML = `
                <div class="space-y-2">
                    <h6 class="font-medium text-white border-b border-white/20 pb-1">Bilet Detayları:</h6>
            `;

                Object.entries(this.selectedTicketTypes)
                    .filter(([type, count]) => count > 0)
                    .forEach(([type, count]) => {
                        const typeObj = this.customerTypes.find(t => t.code === type);
                        priceHTML += `
                        <div class="flex justify-between text-sm">
                            <span>${typeObj?.name || type} × ${count}:</span>
                            <span>₺${(this.ticketPrices[type] * count).toFixed(2)}</span>
                        </div>
                    `;
                    });

                priceHTML += `
                    <div class="border-t border-white/20 pt-2 mt-2">
                        <div class="flex justify-between text-sm">
                            <span>Ara Toplam:</span>
                            <span class="font-medium">₺${this.taxCalculation.subtotal.toFixed(2)}</span>
                        </div>
            `;

                this.taxCalculation.taxes.forEach(tax => {
                    priceHTML += `
                    <div class="flex justify-between text-xs text-gray-400">
                        <span>${tax.formatted_name || tax.name}:</span>
                        <span>₺${tax.amount.toFixed(2)}</span>
                    </div>
                `;
                });

                priceHTML += `
                        <div class="flex justify-between font-bold text-emerald-400 border-t border-white/20 pt-1 mt-1">
                            <span>Genel Toplam:</span>
                            <span>₺${this.taxCalculation.total.toFixed(2)}</span>
                        </div>
                    </div>
                </div>
            `;

                document.getElementById('finalPriceBreakdown').innerHTML = priceHTML;
                document.getElementById('totalPrice').textContent = `₺${this.taxCalculation.total.toFixed(2)}`;

                // Bilet sayısını güncelle
                const taxInfo = this.taxCalculation.taxes.map(tax =>
                    tax.formatted_name || `${tax.name}`
                ).join(' + ');

                const ticketCountElement = document.getElementById('ticketCountInfo');
                if (ticketCountElement) {
                    ticketCountElement.innerHTML = `
                    <div>${taxInfo} dahil • ${selectedSeats.length} bilet</div>
                    <div class="text-xs text-gray-500">
                        Ara Toplam: ₺${this.taxCalculation.subtotal.toFixed(2)} + 
                        Hizmet Bedeli: ₺${this.taxCalculation.total_tax_amount.toFixed(2)}
                    </div>
                `;
                }
            }
        }

        async loadTicketTypes(showtimeId) {
            try {
                this.showLoading();

                const response = await axios.get(`/api/tickets/prices/${showtimeId}`);
                console.log('API Response:', response.data);

                this.customerTypes = response.data.data.types || [];
                const apiPrices = response.data.data.prices;

                // Process prices
                this.ticketPrices = {};
                this.customerTypes.forEach(type => {
                    this.ticketPrices[type.code] = Number(apiPrices[type.code]);
                });

                this.renderTicketTypes();
                this.renderPriceInfo();
                this.showTicketTypes();

            } catch (error) {
                console.error('Fiyat bilgileri alınamadı:', error);
                this.loadMockData();
            }
        }

        loadMockData() {
            const basePrice = selectedShowtime?.price || 45;

            this.customerTypes = [
                { code: 'adult', name: 'Yetişkin', icon: 'fa-user', description: 'Tam bilet' },
                { code: 'student', name: 'Öğrenci', icon: 'fa-graduation-cap', description: '%20 indirim' },
                { code: 'senior', name: 'Emekli', icon: 'fa-user-tie', description: '%15 indirim' },
                { code: 'child', name: 'Çocuk', icon: 'fa-child', description: '%25 indirim' }
            ];

            this.ticketPrices = {
                adult: basePrice,
                student: basePrice * 0.8,
                senior: basePrice * 0.85,
                child: basePrice * 0.75
            };

            this.renderTicketTypes();
            this.renderPriceInfo();
            this.showTicketTypes();
        }

        renderTicketTypes() {
            let html = '';

            this.customerTypes.forEach(type => {
                html += `
                <div class="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/10 hover:bg-white/10 transition-all">
                    <div class="flex items-center space-x-3">
                        <i class="fas ${type.icon} text-2xl text-emerald-400"></i>
                        <div>
                            <h5 class="text-white font-medium">${type.name}</h5>
                            <p class="text-gray-400 text-sm">${type.description}</p>
                            <p class="text-emerald-400 font-bold">₺${this.ticketPrices[type.code].toFixed(2)}</p>
                        </div>
                    </div>
                    <div class="flex items-center space-x-2">
                        <button onclick="window.paymentForm.changeTicketCount('${type.code}', -1)" 
                                class="w-8 h-8 bg-red-500 hover:bg-red-600 text-white rounded-full font-bold transition-all">-</button>
                        <span id="count_${type.code}" class="text-white font-bold w-8 text-center">0</span>
                        <button onclick="window.paymentForm.changeTicketCount('${type.code}', 1)" 
                                class="w-8 h-8 bg-emerald-500 hover:bg-emerald-600 text-white rounded-full font-bold transition-all">+</button>
                    </div>
                </div>
            `;
            });

            this.typesContainer.innerHTML = html;
        }

        renderPriceInfo() {
            let html = '';

            this.customerTypes.forEach(type => {
                html += `
                <div class="flex justify-between items-center py-2">
                    <span class="flex items-center">
                        <i class="fas ${type.icon} text-emerald-400 mr-2"></i>
                        ${type.name}:
                    </span>
                    <span class="font-bold text-emerald-400">₺${this.ticketPrices[type.code].toFixed(2)}</span>
                </div>
            `;
            });

            this.priceInfoElement.innerHTML = html;
        }

        updateSummary() {
            const totalCount = this.getTotalTicketCount();
            this.countElement.textContent = totalCount;

            if (totalCount === 0) {
                this.summaryElement.textContent = 'Hiç bilet seçilmedi';
                this.summaryElement.className = 'mt-2 text-sm text-gray-300';
                this.continueButton.disabled = true;
            } else {
                const summary = Object.entries(this.selectedTicketTypes)
                    .filter(([type, count]) => count > 0)
                    .map(([type, count]) => {
                        const typeObj = this.customerTypes.find(t => t.code === type);
                        return `${count} ${typeObj?.name || type}`;
                    })
                    .join(', ');

                this.summaryElement.textContent = summary;
                this.summaryElement.className = 'mt-2 text-sm text-gray-300';
                this.continueButton.disabled = false;
            }
        }

        validateForm() {
            const name = document.getElementById('customerName').value.trim();
            const email = document.getElementById('customerEmail').value.trim();
            const phone = document.getElementById('customerPhone').value.trim();
            const terms = document.getElementById('termsAccepted').checked;

            if (!name || !email || !phone) {
                alert('Lütfen tüm müşteri bilgilerini doldurun!');
                return false;
            }

            if (!terms) {
                alert('Lütfen kullanım koşullarını kabul edin!');
                return false;
            }

            const totalTickets = Object.values(this.selectedTicketTypes).reduce((sum, count) => sum + count, 0);
            const selectedSeats = window.seatMap?.getSelectedSeats() || [];

            if (totalTickets === 0) {
                alert('Lütfen en az bir bilet tipi seçin!');
                return false;
            }

            if (totalTickets !== selectedSeats.length) {
                alert('Seçilen koltuk sayısı ile bilet sayısı eşleşmiyor!');
                return false;
            }

            return true;
        }


        // PaymentForm class'ında - processPayment() metodunun TAM hali:

        async processPayment() {
            if (!this.validateForm()) return;

            // Tax calculation'ı hazırla
            await this.calculateTotalWithTaxes();

            if (!this.taxCalculation) {
                alert('Hizmet bedeli hesaplanamadı. Lütfen tekrar deneyin.');
                return;
            }

            // Auth ve Token kontrolü
            console.log('Current token:', localStorage.getItem('token'));
            console.log('Authorization header:', axios.defaults.headers.common['Authorization']);

            const token = localStorage.getItem('token');
            if (token && !axios.defaults.headers.common['Authorization']) {
                axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
                console.log('Token manually set');
            }

            // Auth test
            try {
                const authTest = await axios.get('/api/me');
                console.log('Auth test passed:', authTest.data);
            } catch (error) {
                console.log('Auth test failed:', error);
                alert('Oturum sorunu! Lütfen tekrar giriş yapın.');
                return;
            }

            this.completeSaleBtn.disabled = true;
            this.completeSaleBtn.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>İşleminiz gerçekleştiriliyor...';

            try {
                const selectedSeats = window.seatMap?.getSelectedSeats() || [];

                // Bilet tiplerini hazırla
                const ticketTypesArray = [];
                selectedSeats.forEach((seat, index) => {
                    const customerType = this.getCustomerTypeForSeat(index);
                    ticketTypesArray.push({
                        seat_id: seat.id,
                        customer_type: customerType
                    });
                });

                console.log('Sending data:');
                console.log('- Tickets:', ticketTypesArray);
                console.log('- Tax calculation:', this.taxCalculation);

                // API isteği
                const response = await axios.post('/api/tickets', {
                    showtime_id: selectedShowtime.id,
                    tickets: ticketTypesArray,
                    customer_name: document.getElementById('customerName').value,
                    customer_email: document.getElementById('customerEmail').value,
                    customer_phone: document.getElementById('customerPhone').value,
                    payment_method: document.getElementById('paymentMethod').value,
                    tax_calculation: this.taxCalculation
                });

                console.log('Payment successful:', response.data);
                this.showSuccessMessage();

            } catch (error) {
                console.log('Full error:', error);
                console.log('Response:', error.response);
                console.log('Status:', error.response?.status);
                console.log('Message:', error.response?.data);

                if (error.response?.status === 401) {
                    localStorage.removeItem('token');
                    alert('Oturumunuz sona erdi. Lütfen tekrar giriş yapın.');
                    window.location.href = '/login';
                } else {
                    const errorMessage = error.response?.data?.message || 'Satın alma işlemi başarısız!';
                    alert(errorMessage);
                }

                this.completeSaleBtn.disabled = false;
                this.completeSaleBtn.innerHTML = '<i class="fas fa-check-circle mr-2"></i>Ödemeyi Tamamla';
            }
        }

        // Koltuk indeksine göre müşteri tipini belirle
        getCustomerTypeForSeat(seatIndex) {
            const selectedTypes = Object.entries(this.selectedTicketTypes)
                .filter(([type, count]) => count > 0);

            let currentIndex = 0;
            for (let [type, count] of selectedTypes) {
                if (seatIndex < currentIndex + count) {
                    return type;
                }
                currentIndex += count;
            }

            return 'adult'; // Varsayılan
        }

        showSuccessMessage() {
            if (!this.taxCalculation) return;

            const ticketSummary = Object.entries(this.selectedTicketTypes)
                .filter(([type, count]) => count > 0)
                .map(([type, count]) => {
                    const typeObj = this.customerTypes.find(t => t.code === type);
                    return `${count} ${typeObj?.name || type}`;
                })
                .join(', ');

            const selectedSeats = window.seatMap?.getSelectedSeats() || [];

            alert(`🎉 Bilet satışı başarılı!\n\nToplam: ₺${this.taxCalculation.total.toFixed(2)}\nBiletler: ${ticketSummary}\nKoltuklar: ${selectedSeats.map(s => s.code).join(', ')}`);

            setTimeout(() => {
                window.location.href = '/my-tickets';
            }, 2000);
        }

        showLoading() {
            this.loadingElement.classList.remove('hidden');
            this.typesContainer.classList.add('hidden');
        }

        showTicketTypes() {
            this.loadingElement.classList.add('hidden');
            this.typesContainer.classList.remove('hidden');
        }

        getSelectedTicketTypes() {
            return this.selectedTicketTypes;
        }

        getTotalTicketCount() {
            return Object.values(this.selectedTicketTypes).reduce((sum, count) => sum + count, 0);
        }

        reset() {
            this.selectedTicketTypes = {};
            this.customerTypes = [];
            this.ticketPrices = {};
            this.taxCalculation = null;
            this.updateSummary();
            this.hideTaxSection();
            if (this.continueButton) {
                this.continueButton.disabled = true;
            }
        }

        async changeTicketCount(ticketType, change) {
            if (!this.selectedTicketTypes[ticketType]) {
                this.selectedTicketTypes[ticketType] = 0;
            }

            const newCount = this.selectedTicketTypes[ticketType] + change;
            const proposedTotal = this.getTotalTicketCount() + change;

            if (newCount < 0) return;

            if (proposedTotal > MAX_TICKETS_PER_ORDER) {
                alert(`Maksimum ${MAX_TICKETS_PER_ORDER} bilet seçebilirsiniz!`);
                return;
            }

            this.selectedTicketTypes[ticketType] = newCount;
            document.getElementById(`count_${ticketType}`).textContent = newCount;

            this.updateSummary();
            await this.updateTotalPrice(); // async yap
        }
    }

    // Initialize payment form
    document.addEventListener('DOMContentLoaded', function () {
        window.paymentForm = new PaymentForm();
    });

    // Global functions
    async function goToSeatSelection() {
        if (!selectedShowtime) {
            alert('Lütfen önce bir seans seçin!');
            return;
        }

        if (!window.paymentForm) {
            alert('Bilet tipleri yüklenmedi. Lütfen sayfayı yenileyin.');
            return;
        }

        const totalTickets = window.paymentForm.getTotalTicketCount();
        if (totalTickets === 0) {
            alert('Devam etmek için en az bir bilet seçmelisiniz.');
            return;
        }

        if (!window.seatMap) {
            alert('Koltuk haritası hazır değil. Lütfen daha sonra tekrar deneyin.');
            return;
        }

        await window.seatMap.setSeatLimit(totalTickets);
        window.seatMap.setShowtime(selectedShowtime);

        currentTicketStep = 5;
        updateTicketSteps();
        await window.seatMap.loadSeats(selectedShowtime.id);
    }

    function goToPayment() {
        if (!window.paymentForm || !window.seatMap) {
            alert('Lütfen önce bilet tipi ve koltuk seçimini tamamlayın.');
            return;
        }

        const totalTickets = window.paymentForm.getTotalTicketCount();
        if (totalTickets === 0) {
            alert('Ödeme adımına geçmek için bilet seçmelisiniz.');
            return;
        }

        const selectedSeats = window.seatMap.getSelectedSeats() || [];
        if (selectedSeats.length !== totalTickets) {
            alert('Seçtiğiniz koltuk sayısı ile bilet sayısı eşleşmiyor!');
            return;
        }

        currentTicketStep = 6;
        updateTicketSteps();
        window.paymentForm.generateOrderSummary();
    }

    function completeSale() {
        window.paymentForm.processPayment();
    }
</script>