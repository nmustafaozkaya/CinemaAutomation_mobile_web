<!-- Step 3: Seans Seçimi -->
<div id="ticketStep3" class="ticket-step hidden">
    <div class="flex items-center justify-between mb-6">
        <h3 class="text-2xl font-bold text-white text-center flex-1">
            <i class="fas fa-clock mr-2 text-purple-400"></i>Seans Seçiniz
        </h3>
        <button onclick="goBackToStep(2)"
            class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
            <i class="fas fa-arrow-left mr-2"></i>Sinema Değiştir
        </button>
    </div>

    <!-- Selected Movie & Cinema Info -->
    <div id="selectedMovieCinemaInfo" class="bg-white/10 p-4 rounded-xl mb-6"></div>

    <!-- Date Filter -->
    <div class="mb-6">
        <div class="max-w-md mx-auto">
            <label class="block text-white text-sm font-medium mb-2">
                <i class="fas fa-calendar mr-1"></i>Tarih Seçimi
            </label>
            <input type="date" id="dateFilter" onchange="filterShowtimesByDate(this.value)"
                class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white focus:bg-white/20 focus:border-purple-400 transition-all"
                min="">
        </div>
    </div>

    <!-- Showtime Count Info -->
    <div id="showtimeCountInfo" class="text-center mb-4">
        <span class="text-purple-300 text-sm">
            <i class="fas fa-info-circle mr-1"></i>
            <span id="filteredShowtimeCount">0</span> seans bulundu
        </span>
    </div>

    <!-- Loading State -->
    <div id="showtimeLoadingState" class="text-center py-12 hidden">
        <div class="loading w-12 h-12 border-4 border-purple-400 border-t-transparent rounded-full mx-auto mb-4"></div>
        <p class="text-white">Seanslar yükleniyor...</p>
    </div>
    <!-- Showtimes Grid -->
    <div id="showtimeGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- Showtimes will be loaded here -->
    </div>

    <!-- Empty State -->
    <div id="showtimeEmptyState" class="text-center py-12 hidden">
        <div class="w-24 h-24 bg-gray-600 rounded-full flex items-center justify-center mx-auto mb-4">
            <i class="fas fa-clock text-gray-400 text-3xl"></i>
        </div>
        <h4 class="text-xl font-bold text-white mb-2">Seans Bulunamadı</h4>
        <p class="text-gray-400">Seçilen kriterlere uygun seans bulunmuyor.</p>
        <button onclick="clearShowtimeFilters()"
            class="mt-4 bg-purple-500 hover:bg-purple-600 text-white px-4 py-2 rounded-lg font-medium">
            <i class="fas fa-refresh mr-2"></i>Filtreleri Temizle
        </button>
    </div>
</div>

<!-- Step 4: Koltuk Seçimi -->
<div id="ticketStep4" class="ticket-step hidden">
    <div class="flex items-center justify-between mb-6">
        <h3 class="text-2xl font-bold text-white text-center flex-1">
            <i class="fas fa-couch mr-2 text-green-400"></i>Koltuk Seçiniz (Maksimum 6 adet)
        </h3>
        <button onclick="goBackToStep(3)"
            class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
            <i class="fas fa-arrow-left mr-2"></i>Seans Değiştir
        </button>
    </div>

    <!-- Selected Showtime Info -->
    <div id="selectedShowtimeInfo" class="bg-white/10 p-4 rounded-xl mb-6"></div>

    <!-- Seat Map Container -->
    <div class="bg-white/10 p-6 rounded-xl">
        <!-- Screen -->
        <div class="text-center mb-6">
            <div class="bg-gray-800 text-white px-8 py-2 rounded-lg inline-block">
                <i class="fas fa-desktop mr-2"></i>PERDE
            </div>
            <div class="mt-4">
                <button onclick="window.seatMap.manualRefresh()"
                    class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-lg text-sm transition-colors">
                    <i class="fas fa-sync-alt mr-2"></i>Koltukları Güncelle
                </button>
            </div>
        </div>

        <!-- Loading State -->
        <div id="seatLoadingState" class="text-center py-12">
            <div class="loading w-12 h-12 border-4 border-green-400 border-t-transparent rounded-full mx-auto mb-4">
            </div>
            <p class="text-white">Koltuklar yükleniyor...</p>
        </div>

        <!-- Seat Map -->
        <div id="seatMap" class="max-w-4xl mx-auto hidden"></div>

        <!-- Seat Legend -->
        <div id="seatLegend" class="flex items-center justify-center space-x-8 mt-6 hidden">
            <div class="flex items-center">
                <div class="w-6 h-6 bg-emerald-500 rounded-lg mr-2"></div>
                <span class="text-white">Müsait</span>
            </div>
            <div class="flex items-center">
                <div class="w-6 h-6 bg-red-500 rounded-lg mr-2"></div>
                <span class="text-white">Dolu</span>
            </div>
            <div class="flex items-center">
                <div class="w-6 h-6 bg-blue-500 rounded-lg mr-2"></div>
                <span class="text-white">Seçili</span>
            </div>
        </div>

        <!-- Selected Seats Info -->
        <div class="text-center mt-4">
            <div id="selectedSeatsInfo" class="text-white font-medium mb-4">Seçili koltuk yok</div>
            <div id="selectedSeatsPrice" class="text-emerald-400 font-bold mb-4 hidden"></div>
            <button id="continueToTicketTypes" onclick="goToTicketTypes()"
                class="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-lg font-bold hidden">
                <i class="fas fa-arrow-right mr-2"></i>Bilet Tiplerini Seç
            </button>
        </div>
    </div>
</div>

<script>
    // Global variables for showtime management
    let allShowtimes = [];
    let filteredShowtimes = [];
    let currentDateFilter = '';

    
    class SeatMap {
        constructor() {
            this.selectedSeats = [];
            this.maxSeats = 6;
            this.seatData = null;
            this.selectedShowtime = null;

            // DOM Elements
            this.loadingElement = document.getElementById('seatLoadingState');
            this.mapElement = document.getElementById('seatMap');
            this.legendElement = document.getElementById('seatLegend');
            this.infoElement = document.getElementById('selectedSeatsInfo');
            this.priceElement = document.getElementById('selectedSeatsPrice');
            this.continueBtn = document.getElementById('continueToTicketTypes');
            this.autoCleanupOnLoad();
        }
        forceReset() {
            // Tüm seçili koltukları serbest bırak
            this.selectedSeats.forEach(async (seat) => {
                try {
                    await axios.post(`/api/seats/${seat.id}/release`);
                } catch (error) {
                    console.error('Reset sırasında koltuk serbest bırakılamadı:', error);
                }
            });

            this.selectedSeats = [];
            this.seatData = null;
            this.selectedShowtime = null;
            this.updateSelectedSeatsInfo();
        }

        //  Yumuşak reset - sadece UI'ı temizle, API'yi boşuna çağırma
        softReset() {
            this.selectedSeats = [];
            this.seatData = null;
            this.selectedShowtime = null;
            this.updateSelectedSeatsInfo();
        }
        async autoCleanupOnLoad() {
            try {
                const response = await axios.post('/api/seats/auto-cleanup');
                if (response.data.cleaned_seats > 0) {
                    console.log(`🧹 ${response.data.cleaned_seats} expired seats cleaned up`);
                }
            } catch (error) {
                console.error('Auto cleanup failed:', error);
            }
        }

        // toggleSeat - Direk API'ye yazsın, iptal de edebilsin
        async toggleSeat(seatId, seatCode) {

            const existingIndex = this.selectedSeats.findIndex(s => s.id == seatId);

            if (existingIndex !== -1) {
                //  KOLTUK İPTAL ET - API'den serbest bırak
                try {
                    const response = await axios.post(`/api/seats/${seatId}/release`);

                    if (response.data.success) {
                        // Başarılı iptal
                        this.selectedSeats.splice(existingIndex, 1);
                        console.log(`Koltuk ${seatCode} serbest bırakıldı`);
                    } else {
                        alert('Koltuk iptal edilemedi!');
                        return;
                    }
                } catch (error) {
                    console.error('Koltuk iptal hatası:', error);
                    alert('Koltuk iptal edilemedi!');
                    return;
                }
            } else {
                // KOLTUK SEÇ - API'ye direk rezerve et
                if (this.selectedSeats.length >= this.maxSeats) {
                    alert(`Maksimum ${this.maxSeats} koltuk seçebilirsiniz!`);
                    return;
                }

                try {
                    const response = await axios.post(`/api/showtimes/${this.selectedShowtime.id}/reserve`, {
                        seat_id: seatId
                    });

                    if (response.data.success) {
                        // Başarılı rezervasyon
                        this.selectedSeats.push({ id: seatId, code: seatCode });
                        console.log(`Koltuk ${seatCode} rezerve edildi`);

                        // 10 dakika sonra otomatik serbest bırak
                        setTimeout(() => {
                            this.autoReleaseSeat(seatId, seatCode);
                        }, 10 * 60 * 1000); // 10 dakika
                    } else {                
                        alert('Koltuk rezerve edilemedi! Başka biri seçmiş olabilir.');

                        return;
                    }
                } catch (error) {
                    console.error('Koltuk rezerve hatası:', error);
                    if (error.response?.status === 400) {
                        alert('Bu koltuk zaten başka biri tarafından seçilmiş!');
                    } else {
                        alert('Koltuk rezerve edilemedi!');
                    }
                    return;
                }
            }

            // UI'ı güncelle
            await this.loadSeats(this.selectedShowtime.id); // Güncel durumu al
            this.updateSelectedSeatsInfo();

            setTimeout(() => {
                const clickedSeat = document.querySelector(`button[onclick*="${seatId}"]`);
                if (clickedSeat) {
                    clickedSeat.scrollIntoView({
                        behavior: 'smooth',
                        block: 'center'
                    });
                }
            }, 100);


        }


        //  Otomatik serbest bırakma (10 dakika sonra)
        async autoReleaseSeat(seatId, seatCode) {
            const seatIndex = this.selectedSeats.findIndex(s => s.id == seatId);

            // Eğer koltuk hala seçili listesindeyse (satın alınmamışsa)
            if (seatIndex !== -1) {
                try {
                    await axios.post(`/api/seats/${seatId}/release`);
                    this.selectedSeats.splice(seatIndex, 1);

                    console.log(`Koltuk ${seatCode} otomatik olarak serbest bırakıldı (10 dakika doldu)`);

                    // UI'ı güncelle
                    await this.loadSeats(this.selectedShowtime.id);
                    this.updateSelectedSeatsInfo();

                    // Kullanıcıyı uyar
                    alert(`Koltuk ${seatCode} rezervasyon süresi dolduğu için serbest bırakıldı!`);

                } catch (error) {
                    console.error('Otomatik serbest bırakma hatası:', error);
                }
            }
        }

        // loadSeats metodu
        async loadSeats(showtimeId) {
            try {
                //   Koltukları yüklemeden önce cleanup yap
                await this.autoCleanupOnLoad();

                this.showLoading();

                const response = await axios.get(`/api/showtimes/${showtimeId}/available-seats`);
                this.seatData = response.data.data;

                // Status'e göre ayır (yeni API response formatı)
                if (this.seatData.seats) {
                    this.renderSeatMapWithStatus();
                } else {
                    // Eski format için fallback
                    this.renderSeatMap();
                }

                this.showSeatMap();

            } catch (error) {
                console.error('Koltuklar yüklenemedi:', error);
                this.renderMockSeatMap();
                this.showSeatMap();
            }
        }

        //  Seçili koltukları mavi göster
        renderSeatMapWithStatus() {
            const { available = [], occupied = [], pending = [] } = this.seatData.seats;

            // Tüm koltukları birleştir
            const allSeats = [
                ...available.map(s => ({ ...s, status: 'available' })),
                ...occupied.map(s => ({ ...s, status: 'occupied' })),
                ...pending.map(s => ({ ...s, status: 'pending' }))
            ];

            const seatsByRow = {};
            allSeats.forEach(seat => {
                if (!seatsByRow[seat.row]) {
                    seatsByRow[seat.row] = [];
                }
                seatsByRow[seat.row].push(seat);
            });

            let html = '';
            Object.keys(seatsByRow).sort().forEach(row => {
                html += `<div class="flex justify-center items-center space-x-2 mb-2">`;
                html += `<div class="w-8 text-center font-bold text-white">${row}</div>`;

                seatsByRow[row].sort((a, b) => a.number - b.number).forEach(seat => {
                    // Bu koltuğun bizim seçili listemizde olup olmadığını kontrol et
                    const isMySelected = this.selectedSeats.some(s => s.id == seat.id);

                    let bgColor = 'bg-red-500 cursor-not-allowed';
                    let hoverClass = '';
                    let clickHandler = '';
                    let statusText = this.getStatusText(seat.status);

                    switch (seat.status) {
                        case 'available':
                            bgColor = 'bg-emerald-500 cursor-pointer';
                            hoverClass = 'hover:bg-emerald-400';
                            clickHandler = `onclick="window.seatMap.toggleSeat(${seat.id}, '${seat.row}${seat.number}')"`;
                            break;
                        case 'occupied':
                            bgColor = 'bg-red-500 cursor-not-allowed';
                            statusText = 'Satılmış';
                            break;
                        case 'pending':
                            // Eğer bu bizim seçtiğimiz koltuksa, mavi yap ve iptal edilebilir yap
                            if (isMySelected) {
                                bgColor = 'bg-blue-500 cursor-pointer';
                                hoverClass = 'hover:bg-blue-400';
                                clickHandler = `onclick="window.seatMap.toggleSeat(${seat.id}, '${seat.row}${seat.number}')"`;
                                statusText = 'Seçili (İptal edilebilir)';
                            } else {
                                bgColor = 'bg-yellow-500 cursor-not-allowed';
                                statusText = 'Rezerve (Başkası)';
                            }
                            break;
                    }

                    html += `
                        <button class="seat w-8 h-8 ${bgColor} ${hoverClass} text-white text-xs rounded-lg font-bold transition-all transform hover:scale-110"
                                ${clickHandler}
                                title="${seat.row}${seat.number} - ${statusText}">
                            ${seat.number}
                        </button>
                    `;
                });

                html += `</div>`;
            });

            this.mapElement.innerHTML = html;
        }

        
        renderSeatMap() {
            const allSeats = [...this.seatData.available_seats, ...this.seatData.sold_seats];
            const seatsByRow = {};

            // Group seats by row
            allSeats.forEach(seat => {
                if (!seatsByRow[seat.row]) {
                    seatsByRow[seat.row] = [];
                }
                seatsByRow[seat.row].push(seat);
            });

            let html = '';
            Object.keys(seatsByRow).sort().forEach(row => {
                html += `<div class="flex justify-center items-center space-x-2 mb-2">`;
                html += `<div class="w-8 text-center font-bold text-white">${row}</div>`;

                seatsByRow[row].sort((a, b) => a.number - b.number).forEach(seat => {
                    const isAvailable = this.seatData.available_seats.some(s => s.id === seat.id);
                    const isSelected = this.selectedSeats.some(s => s.id === seat.id);

                    let bgColor = 'bg-red-500 cursor-not-allowed';
                    let hoverClass = '';

                    if (isAvailable) {
                        bgColor = 'bg-emerald-500 cursor-pointer';
                        hoverClass = 'hover:bg-emerald-400';
                    }

                    if (isSelected) {
                        bgColor = 'bg-blue-500';
                        hoverClass = 'hover:bg-blue-400';
                    }

                    html += `
                        <button class="seat w-8 h-8 ${bgColor} ${hoverClass} text-white text-xs rounded-lg font-bold transition-all transform hover:scale-110"
                                ${isAvailable ? `onclick="window.seatMap.toggleSeat(${seat.id}, '${seat.row}${seat.number}')"` : 'disabled'}
                                title="${seat.row}${seat.number} - ${isAvailable ? 'Müsait' : 'Dolu'}">
                            ${seat.number}
                        </button>
                    `;
                });

                html += `</div>`;
            });

            this.mapElement.innerHTML = html;
        }

        // renderMockSeatMap
        renderMockSeatMap() {
            const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
            const seatsPerRow = 12;

            let html = '';
            rows.forEach(row => {
                html += `<div class="flex justify-center items-center space-x-2 mb-2">`;
                html += `<div class="w-8 text-center font-bold text-white">${row}</div>`;

                for (let seat = 1; seat <= seatsPerRow; seat++) {
                    const seatId = `${row}${seat}`;
                    const isOccupied = Math.random() < 0.3;
                    const isSelected = this.selectedSeats.some(s => s.id === seatId);

                    let bgColor = 'bg-emerald-500 cursor-pointer';
                    let hoverClass = 'hover:bg-emerald-400';

                    if (isOccupied) {
                        bgColor = 'bg-red-500 cursor-not-allowed';
                        hoverClass = '';
                    }

                    if (isSelected) {
                        bgColor = 'bg-blue-500';
                        hoverClass = 'hover:bg-blue-400';
                    }

                    html += `
                        <button class="seat w-8 h-8 ${bgColor} ${hoverClass} text-white text-xs rounded-lg font-bold transition-all transform hover:scale-110"
                                ${!isOccupied ? `onclick="window.seatMap.toggleSeat('${seatId}', '${seatId}')"` : 'disabled'}
                                title="${seatId} - ${isOccupied ? 'Dolu' : 'Müsait'}">
                            ${seat}
                        </button>
                    `;
                }

                html += `</div>`;
            });

            this.mapElement.innerHTML = html;
        }

        // Diğer metodlar
        getStatusText(status) {
            switch (status) {
                case 'available': return 'Müsait';
                case 'occupied': return 'Satılmış';
                case 'pending': return 'Rezerve';
                default: return 'Bilinmiyor';
            }
        }

        updateSelectedSeatsInfo() {
            if (this.selectedSeats.length === 0) {
                this.infoElement.textContent = 'Seçili koltuk yok';
                this.priceElement.classList.add('hidden');
                this.continueBtn.classList.add('hidden');
            } else {
                const seatCodes = this.selectedSeats.map(s => s.code).join(', ');
                this.infoElement.textContent = `${this.selectedSeats.length} koltuk seçili: ${seatCodes}`;

                // Show estimated price
                if (this.selectedShowtime && this.selectedShowtime.price) {
                    const estimatedTotal = this.selectedSeats.length * this.selectedShowtime.price;
                    this.priceElement.textContent = `Tahmini Toplam: ₺${estimatedTotal.toFixed(2)}`;
                    this.priceElement.classList.remove('hidden');
                }

                this.continueBtn.classList.remove('hidden');
            }
        }

        showLoading() {
            this.loadingElement.classList.remove('hidden');
            this.mapElement.classList.add('hidden');
            this.legendElement.classList.add('hidden');
        }

        showSeatMap() {
            this.loadingElement.classList.add('hidden');
            this.mapElement.classList.remove('hidden');

            // Güncellenmiş legend
            this.legendElement.innerHTML = `
    <div class="bg-white/10 p-4 rounded-xl">
        <div class="flex flex-wrap justify-center gap-3 sm:gap-6">
            <div class="flex items-center">
                <div class="w-4 h-4 bg-emerald-500 rounded mr-2"></div>
                <span class="text-white text-xs sm:text-sm">Müsait</span>
            </div>
            <div class="flex items-center">
                <div class="w-4 h-4 bg-red-500 rounded mr-2"></div>
                <span class="text-white text-xs sm:text-sm">Dolu</span>
            </div>
            <div class="flex items-center">
                <div class="w-4 h-4 bg-yellow-500 rounded mr-2"></div>
                <span class="text-white text-xs sm:text-sm">Rezerve</span>
            </div>
            <div class="flex items-center">
                <div class="w-4 h-4 bg-blue-500 rounded mr-2"></div>
                <span class="text-white text-xs sm:text-sm">Seçili</span>
            </div>
        </div>
    </div>
            `;
            this.legendElement.classList.remove('hidden');
        }

        reset() {
            // Tüm seçili koltukları serbest bırak
            this.selectedSeats.forEach(async (seat) => {
                try {
                    await axios.post(`/api/seats/${seat.id}/release`);
                } catch (error) {
                    console.error('Reset sırasında koltuk serbest bırakılamadı:', error);
                }
            });

            this.selectedSeats = [];
            this.seatData = null;
            this.selectedShowtime = null;
            this.updateSelectedSeatsInfo();
        }

        getSelectedSeats() {
            return this.selectedSeats;
        }

        setShowtime(showtime) {
            this.selectedShowtime = showtime;
        }
        // SeatMap class'ının içine ekleyin
        async manualRefresh() {
            if (!this.selectedShowtime) {
                alert('Önce bir seans seçin!');
                return;
            }

            // Mevcut scroll pozisyonunu kaydet
            const currentScrollPosition = window.pageYOffset;

            try {
                // Loading göster
                this.showLoading();

                // Koltukları yeniden yükle
                await this.loadSeats(this.selectedShowtime.id);

                // Başarı mesajı
                console.log('🔄 Koltuklar manuel olarak güncellendi');

                // Scroll pozisyonunu geri yükle
                setTimeout(() => {
                    window.scrollTo(0, currentScrollPosition);
                    this.showSeatMap();
                }, 100);

            } catch (error) {
                console.error('Manuel güncelleme hatası:', error);
                alert('Koltuklar güncellenirken hata oluştu!');
                this.showSeatMap();
            }
        }
    }

    // Showtime management functions 
    function initializeDateFilter() {
        const today = new Date().toISOString().split('T')[0];
        const dateFilter = document.getElementById('dateFilter');
        dateFilter.min = today;
        dateFilter.value = today;
        currentDateFilter = today;
        filterShowtimesByDate(today);
    }

    function filterShowtimesByDate(date) {
        currentDateFilter = date;

        if (!date) {
            filteredShowtimes = [...allShowtimes];
        } else {
            filteredShowtimes = allShowtimes.filter(showtime => {
                const showtimeDate = new Date(showtime.start_time).toISOString().split('T')[0];
                return showtimeDate === date;
            });
        }

        updateShowtimeCount();

        if (filteredShowtimes.length === 0) {
            showEmptyShowtimes();
        } else {
            renderShowtimes(filteredShowtimes);
            showShowtimeGrid();
        }
    }

    function clearShowtimeFilters() {
        currentDateFilter = '';
        document.getElementById('dateFilter').value = '';
        filteredShowtimes = [...allShowtimes];
        updateShowtimeCount();
        renderShowtimes(filteredShowtimes);
        showShowtimeGrid();
    }

    function updateShowtimeCount() {
        const countElement = document.getElementById('filteredShowtimeCount');
        if (countElement) {
            countElement.textContent = filteredShowtimes.length;
        }
    }

    function showShowtimeLoading() {
        document.getElementById('showtimeLoadingState').classList.remove('hidden');
        document.getElementById('showtimeGrid').classList.add('hidden');
        document.getElementById('showtimeEmptyState').classList.add('hidden');
    }

    function showShowtimeGrid() {
        document.getElementById('showtimeLoadingState').classList.add('hidden');
        document.getElementById('showtimeGrid').classList.remove('hidden');
        document.getElementById('showtimeEmptyState').classList.add('hidden');
    }

    function showEmptyShowtimes() {
        document.getElementById('showtimeLoadingState').classList.add('hidden');
        document.getElementById('showtimeGrid').classList.add('hidden');
        document.getElementById('showtimeEmptyState').classList.remove('hidden');
    }

    function renderShowtimes(showtimes) {
        const showtimeGrid = document.getElementById('showtimeGrid');
        let html = '';

        // Group showtimes by date
        const groupedByDate = {};
        showtimes.forEach(showtime => {
            const date = new Date(showtime.start_time).toISOString().split('T')[0];
            if (!groupedByDate[date]) {
                groupedByDate[date] = [];
            }
            groupedByDate[date].push(showtime);
        });

        // Sort dates
        const sortedDates = Object.keys(groupedByDate).sort();

        if (sortedDates.length === 0) {
            html = '<div class="col-span-full text-center text-gray-400">Seçilen kriterlere uygun seans bulunamadı.</div>';
        } else {
            sortedDates.forEach(date => {
                const dateShowtimes = groupedByDate[date];
                const formattedDate = new Date(date).toLocaleDateString('tr-TR', {
                    weekday: 'long',
                    year: 'numeric',
                    month: 'long',
                    day: 'numeric'
                });

                html += `
                    <div class="col-span-full mb-4">
                        <h4 class="text-lg font-bold text-white mb-3 border-b border-white/20 pb-2">
                            <i class="fas fa-calendar mr-2 text-purple-400"></i>${formattedDate}
                        </h4>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                `;

                dateShowtimes.forEach(showtime => {
                    const startTime = new Date(showtime.start_time);
                    const timeString = startTime.toLocaleTimeString('tr-TR', {
                        hour: '2-digit',
                        minute: '2-digit'
                    });

                    html += `
                        <div class="glass-effect rounded-xl p-4 card-hover cursor-pointer" 
                             onclick="selectShowtimeForTicket(${showtime.id}, '${startTime.toLocaleString('tr-TR')}', '${showtime.hall.name}', ${showtime.price || 45})">
                            <div class="text-center">
                                <h4 class="text-lg font-semibold text-white mb-2">${showtime.hall.name}</h4>
                                <p class="text-emerald-400 font-bold text-xl mb-1">${timeString}</p>
                                <p class="text-purple-300 text-sm mb-2">
                                    <i class="fas fa-clock mr-1"></i>
                                    ${startTime.toLocaleDateString('tr-TR')}
                                </p>
                                <p class="text-yellow-400 font-medium">
                                    <i class="fas fa-ticket-alt mr-1"></i>₺${showtime.price || 45}/kişi
                                </p>
                                <div class="mt-2 text-xs text-gray-400">
                                    <i class="fas fa-couch mr-1"></i>
                                    ${getAvailableSeatsText(showtime)}
                                </div>
                            </div>
                        </div>
                    `;
                });

                html += `
                        </div>
                    </div>
                `;
            });
        }

        showtimeGrid.innerHTML = html;
    }

    function getAvailableSeatsText(showtime) {
        const totalSeats = showtime.hall?.total_seats || 100;
        const soldSeats = showtime.sold_seats || Math.floor(Math.random() * 30);
        const availableSeats = totalSeats - soldSeats;

        return `${availableSeats} koltuk müsait`;
    }

    async function loadShowtimesForCinema() {
        try {
            showShowtimeLoading();

            if (!selectedMovie || !selectedCinema) {
                throw new Error('Film veya sinema seçilmedi');
            }

            const response = await axios.get(`/api/movies/${selectedMovie.id}/showtimes`, {
                params: { cinema_id: selectedCinema.id }
            });

            allShowtimes = response.data.data || [];
            filteredShowtimes = [...allShowtimes];

            initializeDateFilter();
            updateShowtimeCount();

            if (allShowtimes.length === 0) {
                showEmptyShowtimes();
            } else {
                renderShowtimes(filteredShowtimes);
                showShowtimeGrid();
            }

        } catch (error) {
            console.error('Seanslar yüklenemedi:', error);
            renderMockShowtimes();
            showShowtimeGrid();
        }
    }

    function renderMockShowtimes() {
        const now = new Date();
        const mockShowtimes = [];

        // Generate mock showtimes for next 3 days
        for (let day = 0; day < 3; day++) {
            const baseDate = new Date(now);
            baseDate.setDate(now.getDate() + day);

            // Generate 3-4 showtimes per day
            const showtimesPerDay = 3 + Math.floor(Math.random() * 2);
            for (let i = 0; i < showtimesPerDay; i++) {
                const showtime = new Date(baseDate);
                showtime.setHours(14 + (i * 3), 0, 0, 0); // 14:00, 17:00, 20:00, 23:00

                mockShowtimes.push({
                    id: day * 10 + i + 1,
                    start_time: showtime.toISOString(),
                    hall: {
                        name: `Salon ${i + 1}`,
                        total_seats: 100
                    },
                    price: 45 + (i * 5),
                    sold_seats: Math.floor(Math.random() * 30)
                });
            }
        }

        allShowtimes = mockShowtimes;
        filteredShowtimes = [...mockShowtimes];

        initializeDateFilter();
        updateShowtimeCount();
        renderShowtimes(filteredShowtimes);
    }

    async function selectShowtimeForTicket(showtimeId, startTime, hallName, price) {
        selectedShowtime = {
            id: showtimeId,
            startTime: startTime,
            hall: hallName,
            price: price
        };

        currentTicketStep = 4;
        updateTicketSteps();

        // Show selected showtime info
        document.getElementById('selectedShowtimeInfo').innerHTML = `
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div class="flex items-center space-x-3">
                    <i class="fas fa-film text-yellow-400 text-lg"></i>
                    <div>
                        <h6 class="text-white font-medium text-sm">Film</h6>
                        <p class="text-purple-300 text-xs">${selectedMovie.title}</p>
                    </div>
                </div>
                <div class="flex items-center space-x-3">
                    <i class="fas fa-building text-blue-400 text-lg"></i>
                    <div>
                        <h6 class="text-white font-medium text-sm">Sinema</h6>
                        <p class="text-blue-300 text-xs">${selectedCinema.name}</p>
                    </div>
                </div>
                <div class="flex items-center space-x-3">
                    <i class="fas fa-clock text-purple-400 text-lg"></i>
                    <div>
                        <h6 class="text-white font-medium text-sm">Seans</h6>
                        <p class="text-emerald-400 text-xs">${startTime} - ${hallName}</p>
                    </div>
                </div>
            </div>
        `;

        // Set showtime in seat map and load seats
        window.seatMap.setShowtime(selectedShowtime);
        await window.seatMap.loadSeats(showtimeId);
    }

    document.addEventListener('DOMContentLoaded', function () {
        // SeatMap'i initialize et
        window.seatMap = new SeatMap();

        // Genel cleanup
        axios.post('/api/seats/auto-cleanup')
            .then(response => {
                if (response.data.cleaned_seats > 0) {
                    console.log(`🧹 Page load cleanup: ${response.data.cleaned_seats} seats cleaned`);
                }
            })
            .catch(error => console.error('Page load cleanup failed:', error));
    });
    setInterval(async () => {
        try {
            const response = await axios.post('/api/seats/auto-cleanup');
            if (response.data.cleaned_seats > 0) {
                console.log(`🧹 Periodic cleanup: ${response.data.cleaned_seats} seats cleaned`);

                // Eğer kullanıcı koltuk seçim sayfasındaysa, haritayı yenile
                if (window.seatMap && window.seatMap.selectedShowtime) {
                    await window.seatMap.loadSeats(window.seatMap.selectedShowtime.id);
                }
            }
        } catch (error) {
            console.error('Periodic cleanup failed:', error);
        }
    }, 2 * 60 * 1000); // 2 dakika

    // Sayfa focus'a geldiğinde cleanup
    document.addEventListener('visibilitychange', async function () {
        if (!document.hidden && window.seatMap) {
            try {
                const response = await axios.post('/api/seats/auto-cleanup');
                if (response.data.cleaned_seats > 0) {
                    console.log(`🧹 Focus cleanup: ${response.data.cleaned_seats} seats cleaned`);

                    // Koltuk haritasını yenile
                    if (window.seatMap.selectedShowtime) {
                        await window.seatMap.loadSeats(window.seatMap.selectedShowtime.id);
                    }
                }
            } catch (error) {
                console.error('Focus cleanup failed:', error);
            }
        }
    });

</script>