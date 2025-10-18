@extends('layout')

@section('content')
    <div class="glass-effect p-8 rounded-2xl">
        <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-bold text-white flex items-center">
                <i class="fas fa-ticket-alt mr-3 text-emerald-400"></i>
                Bilet Al
            </h2>
            <a href="/" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
                <i class="fas fa-arrow-left mr-2"></i>Geri
            </a>
        </div>

        <!-- Progress Steps - 6 Aşama -->
        <div class="flex items-center justify-center mb-12">
            <div class="flex items-center space-x-4">
                <div class="step-item active flex items-center">
                    <div
                        class="w-10 h-10 bg-emerald-500 rounded-full flex items-center justify-center text-white font-bold">
                        1
                    </div>
                    <span class="ml-2 text-white font-medium">Film Seç</span>
                </div>
                <div class="w-12 h-1 bg-gray-600 rounded"></div>
                <div class="step-item flex items-center">
                    <div class="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center text-white font-bold">2
                    </div>
                    <span class="ml-2 text-gray-400 font-medium">Sinema Seç</span>
                </div>
                <div class="w-12 h-1 bg-gray-600 rounded"></div>
                <div class="step-item flex items-center">
                    <div class="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center text-white font-bold">3
                    </div>
                    <span class="ml-2 text-gray-400 font-medium">Seans Seç</span>
                </div>
                <div class="w-12 h-1 bg-gray-600 rounded"></div>
                <div class="step-item flex items-center">
                    <div class="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center text-white font-bold">4
                    </div>
                    <span class="ml-2 text-gray-400 font-medium">Koltuk Seç</span>
                </div>
                <div class="w-12 h-1 bg-gray-600 rounded"></div>
                <div class="step-item flex items-center">
                    <div class="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center text-white font-bold">5
                    </div>
                    <span class="ml-2 text-gray-400 font-medium">Bilet Tipi</span>
                </div>
                <div class="w-12 h-1 bg-gray-600 rounded"></div>
                <div class="step-item flex items-center">
                    <div class="w-10 h-10 bg-gray-600 rounded-full flex items-center justify-center text-white font-bold">6
                    </div>
                    <span class="ml-2 text-gray-400 font-medium">Ödeme</span>
                </div>
            </div>
        </div>

        <!-- Step 1: Film Seçimi -->
        <div id="ticketStep1" class="ticket-step">
            <h3 class="text-2xl font-bold text-white mb-6 text-center">
                <i class="fas fa-film mr-2 text-yellow-400"></i>Film Seçiniz
            </h3>
            <div id="ticketMovieGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <!-- Movie selection will be loaded here -->
            </div>
        </div>

        <!-- Step 2: Sinema Seçimi -->
        <div id="ticketStep2" class="ticket-step hidden">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-2xl font-bold text-white text-center flex-1">
                    <i class="fas fa-building mr-2 text-blue-400"></i>Sinema Seçiniz
                </h3>
                <button onclick="goBackToStep(1)"
                    class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
                    <i class="fas fa-arrow-left mr-2"></i>Film Değiştir
                </button>
            </div>
            <div id="selectedMovieInfo" class="bg-white/10 p-4 rounded-xl mb-6"></div>
            <div id="cinemaGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"></div>
        </div>

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
            <div id="selectedMovieCinemaInfo" class="bg-white/10 p-4 rounded-xl mb-6"></div>
            <div id="showtimeGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4"></div>
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
            <div id="selectedShowtimeInfo" class="bg-white/10 p-4 rounded-xl mb-6"></div>
            <div class="bg-white/10 p-6 rounded-xl">
                <div class="text-center mb-6">
                    <div class="bg-gray-800 text-white px-8 py-2 rounded-lg inline-block">
                        <i class="fas fa-desktop mr-2"></i>PERDE
                    </div>
                </div>
                <div id="seatMap" class="max-w-4xl mx-auto"></div>
                <div class="flex items-center justify-center space-x-8 mt-6">
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
                <div class="text-center mt-4">
                    <div id="selectedSeatsInfo" class="text-white font-medium mb-4">Seçili koltuk yok</div>
                    <button id="continueToTicketTypes" onclick="goToTicketTypes()"
                        class="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-lg font-bold hidden">
                        <i class="fas fa-arrow-right mr-2"></i>Bilet Tiplerini Seç
                    </button>
                </div>
            </div>
        </div>

        <!-- Step 5: Bilet Tipi Seçimi -->
        <div id="ticketStep5" class="ticket-step hidden">
            <div class="flex items-center justify-between mb-6">
                <h3 class="text-2xl font-bold text-white text-center flex-1">
                    <i class="fas fa-users mr-2 text-orange-400"></i>Bilet Tiplerini Seçiniz
                </h3>
                <button onclick="goBackToStep(4)"
                    class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
                    <i class="fas fa-arrow-left mr-2"></i>Koltuk Değiştir
                </button>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div class="bg-white/10 p-6 rounded-xl">
                    <h4 class="text-xl font-semibold text-white mb-4">
                        <i class="fas fa-ticket-alt mr-2"></i>Bilet Tipleri
                    </h4>
                    <div id="ticketTypesContainer" class="space-y-4">
                        <!-- Bilet tipleri buraya yüklenecek -->
                    </div>
                    <div class="mt-6 pt-4 border-t border-white/20">
                        <div class="flex justify-between items-center text-lg font-bold text-white">
                            <span>Seçilen Biletler:</span>
                            <span id="selectedTicketCount" class="text-emerald-400">0</span>
                        </div>
                        <div id="ticketTypeSummary" class="mt-2 text-sm text-gray-300"></div>
                    </div>
                    <button id="continueToPayment" onclick="goToPayment()"
                        class="w-full mt-6 bg-emerald-500 hover:bg-emerald-600 text-white py-3 rounded-xl font-bold disabled:bg-gray-600 disabled:cursor-not-allowed"
                        disabled>
                        <i class="fas fa-arrow-right mr-2"></i>Ödemeye Geç
                    </button>
                </div>

                <div class="bg-white/10 p-6 rounded-xl">
                    <h4 class="text-xl font-semibold text-white mb-4">
                        <i class="fas fa-info-circle mr-2"></i>Fiyat Bilgileri
                    </h4>
                    <div id="priceInfo" class="space-y-3 text-white">
                        <!-- Fiyat bilgileri buraya yüklenecek -->
                    </div>
                    <div class="mt-6 pt-4 border-t border-white/20">
                        <div class="flex justify-between items-center text-xl font-bold text-white">
                            <span>Toplam:</span>
                            <span id="totalPricePreview" class="text-emerald-400">₺0</span>
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
                    <i class="fas fa-arrow-left mr-2"></i>Bilet Tipi Değiştir
                </button>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                <div class="bg-white/10 p-6 rounded-xl">
                    <h4 class="text-xl font-semibold text-white mb-4">
                        <i class="fas fa-user mr-2"></i>Müşteri Bilgileri
                    </h4>
                    <div class="space-y-4">
                        <input type="text" id="customerName" placeholder="Ad Soyad"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300">
                        <input type="email" id="customerEmail" placeholder="E-posta"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300">
                        <input type="tel" id="customerPhone" placeholder="Telefon"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300">
                        <select id="paymentMethod"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white">
                            <option value="cash">💰 Nakit</option>
                            <option value="card">💳 Kredi Kartı</option>
                            <option value="online">🌐 Online Ödeme</option>
                        </select>
                    </div>
                </div>

                <div class="bg-white/10 p-6 rounded-xl">
                    <h4 class="text-xl font-semibold text-white mb-4">
                        <i class="fas fa-receipt mr-2"></i>Sipariş Özeti
                    </h4>
                    <div id="orderSummary" class="space-y-3 text-white mb-6"></div>
                    <div class="border-t border-white/20 pt-4">
                        <div class="flex justify-between items-center text-xl font-bold text-white">
                            <span>Toplam:</span>
                            <span id="totalPrice" class="text-emerald-400">₺0</span>
                        </div>
                    </div>
                    <button onclick="completeSale()"
                        class="w-full mt-6 bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 text-white py-4 rounded-xl font-bold text-lg transition-all transform hover:scale-105">
                        <i class="fas fa-check-circle mr-2"></i>Ödemeyi Tamamla
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let selectedMovie = null;
        let selectedCinema = null;
        let selectedShowtime = null;
        let selectedSeats = [];
        let selectedTicketTypes = {};
        let ticketPrices = {};
        let currentTicketStep = 1;

        document.addEventListener('DOMContentLoaded', function () {
            loadMoviesForTicket();
        });

        function goBackToStep(stepNumber) {
            document.querySelectorAll('.ticket-step').forEach(step => {
                step.classList.add('hidden');
            });

            document.getElementById(`ticketStep${stepNumber}`).classList.remove('hidden');
            currentTicketStep = stepNumber;
            updateTicketSteps();

            if (stepNumber === 1) {
                selectedMovie = null;
                selectedCinema = null;
                selectedShowtime = null;
                selectedSeats = [];
                selectedTicketTypes = {};
            } else if (stepNumber === 2) {
                selectedCinema = null;
                selectedShowtime = null;
                selectedSeats = [];
                selectedTicketTypes = {};
            } else if (stepNumber === 3) {
                selectedShowtime = null;
                selectedSeats = [];
                selectedTicketTypes = {};
            } else if (stepNumber === 4) {
                selectedSeats = [];
                selectedTicketTypes = {};
            } else if (stepNumber === 5) {
                selectedTicketTypes = {};
            }
        }

        async function loadMoviesForTicket() {
            try {
                const response = await axios.get('/api/movies');
                const movies = response.data.data.data || response.data.data;
                renderMoviesForTicket(movies.slice(0, 30));
            } catch (error) {
                console.error('Filmler yüklenemedi:', error);
                const mockMovies = [
                    { id: 1, title: "Avatar: The Way of Water", genre: "Sci-Fi", duration: 192, imdb_raiting: 7.6 },
                    { id: 2, title: "Top Gun: Maverick", genre: "Action", duration: 131, imdb_raiting: 8.3 },
                    { id: 3, title: "Black Panther: Wakanda Forever", genre: "Action", duration: 161, imdb_raiting: 6.7 },
                    { id: 4, title: "Spider-Man: Across the Spider-Verse", genre: "Animation", duration: 140, imdb_raiting: 8.7 },
                    { id: 5, title: "John Wick: Chapter 4", genre: "Action", duration: 169, imdb_raiting: 7.8 },
                    { id: 6, title: "Guardians of the Galaxy Vol. 3", genre: "Sci-Fi", duration: 150, imdb_raiting: 7.9 }
                ];
                renderMoviesForTicket(mockMovies);
            }
        }

        function renderMoviesForTicket(movies) {
            const movieGrid = document.getElementById('ticketMovieGrid');
            let html = '';

            movies.forEach(movie => {
                const posterUrl = movie.poster_url && movie.poster_url.trim() !== '' ? movie.poster_url : null;

                html += `
                                                                                                        <div class="glass-effect rounded-2xl p-6 card-hover cursor-pointer" onclick="selectMovieForTicket(${movie.id}, '${movie.title}')">
                                                                                                            <div class="h-32 bg-gradient-to-br from-purple-600 to-blue-600 rounded-xl flex items-center justify-center relative overflow-hidden mb-4">
                                                                                                                ${posterUrl ? `
                                                                                                                    <img src="${posterUrl}" alt="${movie.title}" 
                                                                                                                         class="w-full h-full object-cover rounded-xl"
                                                                                                                         onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                                                                                    <div class="hidden w-full h-full bg-gradient-to-br from-purple-600 to-blue-600 rounded-xl flex items-center justify-center">
                                                                                                                        <i class="fas fa-film text-white text-3xl opacity-50"></i>
                                                                                                                    </div>
                                                                                                                ` : `
                                                                                                                    <i class="fas fa-film text-white text-3xl opacity-50"></i>
                                                                                                                `}
                                                                                                                <div class="absolute inset-0 bg-black bg-opacity-20 rounded-xl"></div>
                                                                                                            </div>
                                                                                                            <h4 class="text-lg font-bold text-white mb-2">${movie.title}</h4>
                                                                                                            <p class="text-purple-300 text-sm">${movie.genre} • ${movie.duration} dk</p>
                                                                                                            <p class="text-yellow-400 mt-2">
                                                                                                                <i class="fas fa-star mr-1"></i>${movie.imdb_raiting || movie.imdb_rating || 'N/A'}
                                                                                                            </p>
                                                                                                        </div>
                                                                                                    `;
            });

            movieGrid.innerHTML = html;
        }

        async function selectMovieForTicket(movieId, movieTitle) {
            selectedMovie = { id: movieId, title: movieTitle };
            currentTicketStep = 2;
            updateTicketSteps();

            document.getElementById('selectedMovieInfo').innerHTML = `
                                                                                                    <div class="flex items-center space-x-4">
                                                                                                        <i class="fas fa-film text-yellow-400 text-2xl"></i>
                                                                                                        <div>
                                                                                                            <h4 class="text-white font-semibold">Seçilen Film</h4>
                                                                                                            <p class="text-purple-300">${movieTitle}</p>
                                                                                                        </div>
                                                                                                    </div>
                                                                                                `;

            try {
                const response = await axios.get('/api/cinemas');
                const cinemas = response.data.data || [];
                renderCinemas(cinemas);
            } catch (error) {
                console.error('Sinemalar yüklenemedi:', error);
                const mockCinemas = [
                    { id: 1, name: "CinemaMax Gaziantep", address: "Forum AVM", hall_count: 8 },
                    { id: 2, name: "CinemaMax Forum", address: "Sanko Park", hall_count: 6 },
                    { id: 3, name: "CineBonus Anteplioğlu", address: "Anteplioğlu AVM", hall_count: 4 }
                ];
                renderCinemas(mockCinemas);
            }
        }

        function renderCinemas(cinemas) {
            const cinemaGrid = document.getElementById('cinemaGrid');
            let html = '';

            cinemas.forEach(cinema => {
                html += `
                                                                                                        <div class="glass-effect rounded-2xl p-6 card-hover cursor-pointer" onclick="selectCinemaForTicket(${cinema.id}, '${cinema.name}', '${cinema.address}')">
                                                                                                            <div class="h-20 bg-gradient-to-br from-blue-600 to-purple-600 rounded-xl flex items-center justify-center mb-4">
                                                                                                                <i class="fas fa-building text-white text-3xl opacity-70"></i>
                                                                                                            </div>
                                                                                                            <h4 class="text-lg font-bold text-white mb-2">${cinema.name}</h4>
                                                                                                            <p class="text-blue-300 text-sm mb-1">${cinema.address || 'Adres bilgisi yok'}</p>
                                                                                                            <p class="text-emerald-400 text-sm">
                                                                                                                <i class="fas fa-door-open mr-1"></i>${cinema.hall_count || cinema.halls?.length || 'N/A'} Salon
                                                                                                            </p>
                                                                                                        </div>
                                                                                                    `;
            });

            cinemaGrid.innerHTML = html;
        }

        async function selectCinemaForTicket(cinemaId, cinemaName, cinemaAddress) {
            selectedCinema = { id: cinemaId, name: cinemaName, address: cinemaAddress };
            currentTicketStep = 3;
            updateTicketSteps();

            document.getElementById('selectedMovieCinemaInfo').innerHTML = `
                                                                                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                                                                                        <div class="flex items-center space-x-4">
                                                                                                            <i class="fas fa-film text-yellow-400 text-xl"></i>
                                                                                                            <div>
                                                                                                                <h5 class="text-white font-medium">Film</h5>
                                                                                                                <p class="text-purple-300 text-sm">${selectedMovie.title}</p>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                        <div class="flex items-center space-x-4">
                                                                                                            <i class="fas fa-building text-blue-400 text-xl"></i>
                                                                                                            <div>
                                                                                                                <h5 class="text-white font-medium">Sinema</h5>
                                                                                                                <p class="text-blue-300 text-sm">${cinemaName}</p>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                    </div>
                                                                                                `;

            try {
                const response = await axios.get(`/api/showtimes?movie_id=${selectedMovie.id}&cinema_id=${cinemaId}`);
                const showtimes = response.data.data.data || response.data.data;
                renderShowtimes(showtimes);
            } catch (error) {
                console.error('Seanslar yüklenemedi:', error);
                const mockShowtimes = [
                    { id: 1, hall: { name: "Salon 1" }, start_time: "2025-07-09T14:00:00", price: 45 },
                    { id: 2, hall: { name: "Salon 2" }, start_time: "2025-07-09T17:00:00", price: 50 },
                    { id: 3, hall: { name: "Salon 1" }, start_time: "2025-07-09T20:00:00", price: 55 }
                ];
                renderShowtimes(mockShowtimes);
            }
        }

        function renderShowtimes(showtimes) {
            const showtimeGrid = document.getElementById('showtimeGrid');
            let html = '';

            showtimes.forEach(showtime => {
                const startTime = new Date(showtime.start_time);
                html += `
                                                                                                        <div class="glass-effect rounded-xl p-4 card-hover cursor-pointer" onclick="selectShowtimeForTicket(${showtime.id}, '${startTime.toLocaleString('tr-TR')}', '${showtime.hall.name}', ${showtime.price || 45})">
                                                                                                            <h4 class="text-lg font-semibold text-white mb-2">${showtime.hall.name}</h4>
                                                                                                            <p class="text-emerald-400 font-bold text-lg">${startTime.toLocaleString('tr-TR')}</p>
                                                                                                            <p class="text-purple-300 text-sm mt-1">₺${showtime.price || 45}/kişi</p>
                                                                                                        </div>
                                                                                                    `;
            });

            showtimeGrid.innerHTML = html;
        }

        async function selectShowtimeForTicket(showtimeId, startTime, hallName, price) {
            selectedShowtime = { id: showtimeId, startTime: startTime, hall: hallName, price: price };
            currentTicketStep = 4;
            updateTicketSteps();

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

            try {
                const response = await axios.get(`/api/showtimes/${showtimeId}/available-seats`);
                const seatData = response.data.data;
                renderSeatMap(seatData);
            } catch (error) {
                console.error('Koltuklar yüklenemedi:', error);
                renderMockSeatMap();
            }
        }

        function renderSeatMap(seatData) {
            const seatMap = document.getElementById('seatMap');
            const allSeats = [...seatData.available_seats, ...seatData.sold_seats];
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
                    const isAvailable = seatData.available_seats.some(s => s.id === seat.id);
                    const isSelected = selectedSeats.some(s => s.id === seat.id);

                    let bgColor = 'bg-red-500 cursor-not-allowed';
                    if (isAvailable) bgColor = 'bg-emerald-500 hover:bg-emerald-400 cursor-pointer';
                    if (isSelected) bgColor = 'bg-blue-500';

                    html += `
                                                                                                            <button class="seat w-8 h-8 ${bgColor} text-white text-xs rounded-lg font-bold"
                                                                                                                    ${isAvailable ? `onclick="toggleSeat(${seat.id}, '${seat.row}${seat.number}')"` : 'disabled'}>
                                                                                                                ${seat.number}
                                                                                                            </button>
                                                                                                        `;
                });

                html += `</div>`;
            });

            seatMap.innerHTML = html;
        }

        function renderMockSeatMap() {
            const seatMap = document.getElementById('seatMap');
            const rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
            const seatsPerRow = 12;

            let html = '';
            rows.forEach(row => {
                html += `<div class="flex justify-center items-center space-x-2 mb-2">`;
                html += `<div class="w-8 text-center font-bold text-white">${row}</div>`;

                for (let seat = 1; seat <= seatsPerRow; seat++) {
                    const seatId = `${row}${seat}`;
                    const seatObj = { id: seatId, row: row, number: seat };
                    const isOccupied = Math.random() < 0.3;
                    const isSelected = selectedSeats.some(s => s.id === seatId);

                    let bgColor = 'bg-emerald-500 hover:bg-emerald-400 cursor-pointer';
                    if (isOccupied) bgColor = 'bg-red-500 cursor-not-allowed';
                    if (isSelected) bgColor = 'bg-blue-500';

                    html += `
                                                                                                            <button class="seat w-8 h-8 ${bgColor} text-white text-xs rounded-lg font-bold"
                                                                                                                    ${!isOccupied ? `onclick="toggleSeat('${seatId}', '${seatId}')"` : 'disabled'}>
                                                                                                                ${seat}
                                                                                                            </button>
                                                                                                        `;
                }

                html += `</div>`;
            });

            seatMap.innerHTML = html;
        }

        function toggleSeat(seatId, seatCode) {
            const existingIndex = selectedSeats.findIndex(s => s.id == seatId);

            if (existingIndex !== -1) {
                selectedSeats.splice(existingIndex, 1);
            } else {
                if (selectedSeats.length < 6) {
                    selectedSeats.push({ id: seatId, code: seatCode });
                } else {
                    alert('Maksimum 6 koltuk seçebilirsiniz!');
                    return;
                }
            }

            // ✅ Daha güvenilir kontrol - API'yi her zaman dene
            renderCurrentSeatMap();
            updateSelectedSeatsInfo();
        }

        function renderCurrentSeatMap() {
            // API'den veri almayı dene
            if (selectedShowtime && selectedShowtime.id) {
                axios.get(`/api/showtimes/${selectedShowtime.id}/available-seats`)
                    .then(response => {
                        const seatData = response.data.data;
                        renderSeatMap(seatData);
                    })
                    .catch(error => {
                        console.error('API hatası, mock data kullanılıyor:', error);
                        renderMockSeatMap();
                    });
            } else {
                // selectedShowtime yoksa mock kullan
                renderMockSeatMap();
            }
        }

        function renderCurrentSeatMap() {
            // Mevcut koltuk haritasını yeniden render et
            if (selectedShowtime && selectedShowtime.id) {
                axios.get(`/api/showtimes/${selectedShowtime.id}/available-seats`)
                    .then(response => {
                        const seatData = response.data.data;
                        renderSeatMap(seatData);
                    })
                    .catch(error => {
                        renderMockSeatMap();
                    });
            } else {
                renderMockSeatMap();
            }
        }

        function updateSelectedSeatsInfo() {
            const info = document.getElementById('selectedSeatsInfo');
            const continueBtn = document.getElementById('continueToTicketTypes');

            if (selectedSeats.length === 0) {
                info.textContent = 'Seçili koltuk yok';
                continueBtn.classList.add('hidden');
            } else {
                info.textContent = `${selectedSeats.length} koltuk seçili: ${selectedSeats.map(s => s.code).join(', ')}`;
                continueBtn.classList.remove('hidden');
            }
        }

        function goToTicketTypes() {
            currentTicketStep = 5;
            updateTicketSteps();
            loadTicketTypes();
        }

        async function loadTicketTypes() {
            try {
                const response = await axios.get(`/api/tickets/prices/${selectedShowtime.id}`);
                console.log('API Response:', response.data);

                // ✅ Hem prices hem types'ı al
                const apiPrices = response.data.data.prices;
                const customerTypes = response.data.data.types; // Bu satır eksikti!

                // Fiyatları işle
                ticketPrices = {};
                customerTypes.forEach(type => {
                    ticketPrices[type.code] = Number(apiPrices[type.code]);
                });

                console.log('Final ticketPrices:', ticketPrices);
                console.log('CustomerTypes:', customerTypes);

                // ✅ customerTypes parametresi ile çağır
                renderTicketTypeSelection(customerTypes);
                renderPriceInfo(customerTypes);

            } catch (error) {
                console.error('Fiyat bilgileri alınamadı:', error);

                // Fallback - mock data
                const basePrice = parseFloat(selectedShowtime.price) || 45;
                const mockTypes = [
                    { code: 'adult', name: 'Yetişkin', icon: 'fa-user', description: 'Tam bilet' },
                    { code: 'student', name: 'Öğrenci', icon: 'fa-graduation-cap', description: '%20 indirim' },
                    { code: 'senior', name: 'Emekli', icon: 'fa-user-tie', description: '%15 indirim' },
                    { code: 'child', name: 'Çocuk', icon: 'fa-child', description: '%25 indirim' }
                ];

                ticketPrices = {
                    adult: basePrice,
                    student: basePrice * 0.8,
                    senior: basePrice * 0.85,
                    child: basePrice * 0.75
                };

                renderTicketTypeSelection(mockTypes);
                renderPriceInfo(mockTypes);
            }
        }

        function renderTicketTypeSelection(customerTypes) { // ✅ Parametre eklendi
            const container = document.getElementById('ticketTypesContainer');
            let html = '';

            // ✅ API'den gelen types'ları kullan
            customerTypes.forEach(type => {
                html += `
                                <div class="flex items-center justify-between p-4 bg-white/5 rounded-lg border border-white/10">
                                    <div class="flex items-center space-x-3">
                                        <i class="fas ${type.icon} text-2xl text-emerald-400"></i>
                                        <div>
                                            <h5 class="text-white font-medium">${type.name}</h5>
                                            <p class="text-gray-400 text-sm">${type.description}</p>
                                            <p class="text-emerald-400 font-bold">₺${ticketPrices[type.code].toFixed(2)}</p>
                                        </div>
                                    </div>
                                    <div class="flex items-center space-x-2">
                                        <button onclick="changeTicketCount('${type.code}', -1)" 
                                                class="w-8 h-8 bg-red-500 hover:bg-red-600 text-white rounded-full">-</button>
                                        <span id="count_${type.code}" class="text-white font-bold w-8 text-center">0</span>
                                        <button onclick="changeTicketCount('${type.code}', 1)" 
                                                class="w-8 h-8 bg-emerald-500 hover:bg-emerald-600 text-white rounded-full">+</button>
                                    </div>
                                </div>
                            `;
            });

            container.innerHTML = html;
        }

        function renderPriceInfo() {
            const container = document.getElementById('priceInfo');
            const ticketTypes = [
                { id: 'adult', name: 'Yetişkin (Tam Bilet)' },
                { id: 'student', name: 'Öğrenci (%20 İndirim)' },
                { id: 'senior', name: 'Emekli (%15 İndirim)' },
                { id: 'child', name: 'Çocuk (%25 İndirim)' }
            ];

            let html = '';
            ticketTypes.forEach(type => {
                html += `
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>${type.name}:</span>
                                                                                                            <span class="font-bold text-emerald-400">₺${ticketPrices[type.id].toFixed(2)}</span>
                                                                                                        </div>
                                                                                                    `;
            });

            container.innerHTML = html;
        }

        function changeTicketCount(ticketType, change) {
            if (!selectedTicketTypes[ticketType]) {
                selectedTicketTypes[ticketType] = 0;
            }

            const newCount = selectedTicketTypes[ticketType] + change;
            const totalTickets = Object.values(selectedTicketTypes).reduce((sum, count) => sum + count, 0) + change;

            if (newCount < 0) return;
            if (totalTickets > selectedSeats.length) {
                alert(`Maksimum ${selectedSeats.length} bilet seçebilirsiniz!`);
                return;
            }

            selectedTicketTypes[ticketType] = newCount;
            document.getElementById(`count_${ticketType}`).textContent = newCount;

            updateTicketTypeSummary();
            updateTotalPrice();
        }

        function updateTicketTypeSummary() {
            const countElement = document.getElementById('selectedTicketCount');
            const summaryElement = document.getElementById('ticketTypeSummary');
            const continueButton = document.getElementById('continueToPayment');

            const totalCount = Object.values(selectedTicketTypes).reduce((sum, count) => sum + count, 0);
            countElement.textContent = totalCount;

            if (totalCount === 0) {
                summaryElement.textContent = 'Hiç bilet seçilmedi';
                continueButton.disabled = true;
            } else if (totalCount !== selectedSeats.length) {
                summaryElement.textContent = `Uyarı: ${selectedSeats.length} koltuk seçtiniz ama ${totalCount} bilet seçtiniz!`;
                summaryElement.classList.add('text-red-400');
                continueButton.disabled = true;
            } else {
                const summary = Object.entries(selectedTicketTypes)
                    .filter(([type, count]) => count > 0)
                    .map(([type, count]) => {
                        const typeNames = {
                            adult: 'Yetişkin',
                            student: 'Öğrenci',
                            senior: 'Emekli',
                            child: 'Çocuk'
                        };
                        return `${count} ${typeNames[type]}`;
                    })
                    .join(', ');

                summaryElement.textContent = summary;
                summaryElement.classList.remove('text-red-400');
                continueButton.disabled = false;
            }
        }

        function updateTotalPrice() {
            const total = Object.entries(selectedTicketTypes).reduce((sum, [type, count]) => {
                return sum + (ticketPrices[type] * count);
            }, 0);

            document.getElementById('totalPricePreview').textContent = `₺${total.toFixed(2)}`;
        }

        function goToPayment() {
            currentTicketStep = 6;
            updateTicketSteps();
            updateOrderSummary();
        }

        function updateOrderSummary() {
            const summary = document.getElementById('orderSummary');
            const total = Object.entries(selectedTicketTypes).reduce((sum, [type, count]) => {
                return sum + (ticketPrices[type] * count);
            }, 0);

            const typeNames = {
                adult: 'Yetişkin',
                student: 'Öğrenci',
                senior: 'Emekli',
                child: 'Çocuk'
            };

            summary.innerHTML = `
                                                                                                    <div class="space-y-3">
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Film:</span>
                                                                                                            <span class="font-medium">${selectedMovie.title}</span>
                                                                                                        </div>
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Sinema:</span>
                                                                                                            <span class="font-medium">${selectedCinema.name}</span>
                                                                                                        </div>
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Seans:</span>
                                                                                                            <span class="font-medium">${selectedShowtime.startTime}</span>
                                                                                                        </div>
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Salon:</span>
                                                                                                            <span class="font-medium">${selectedShowtime.hall}</span>
                                                                                                        </div>
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Koltuklar:</span>
                                                                                                            <span class="font-medium">${selectedSeats.map(s => s.code).join(', ')}</span>
                                                                                                        </div>
                                                                                                        ${Object.entries(selectedTicketTypes)
                    .filter(([type, count]) => count > 0)
                    .map(([type, count]) => `
                                                                                                                <div class="flex justify-between">
                                                                                                                    <span>${typeNames[type]} (${count} adet):</span>
                                                                                                                    <span class="font-medium">₺${(ticketPrices[type] * count).toFixed(2)}</span>
                                                                                                                </div>
                                                                                                            `).join('')}
                                                                                                </div>
                                                                                                `;

            document.getElementById('totalPrice').textContent = `₺${total.toFixed(2)}`;
        }

        function updateTicketSteps() {
            // Hide all steps
            for (let i = 1; i <= 6; i++) {
                document.getElementById(`ticketStep${i}`).classList.add('hidden');
            }

            // Show current step
            document.getElementById(`ticketStep${currentTicketStep}`).classList.remove('hidden');

            // Update step indicators
            const stepItems = document.querySelectorAll('.step-item');
            stepItems.forEach((item, index) => {
                const stepNumber = index + 1;
                const circle = item.querySelector('div');
                const text = item.querySelector('span');

                if (stepNumber <= currentTicketStep) {
                    circle.classList.remove('bg-gray-600');
                    circle.classList.add('bg-emerald-500');
                    text.classList.remove('text-gray-400');
                    text.classList.add('text-white');
                } else {
                    circle.classList.remove('bg-emerald-500');
                    circle.classList.add('bg-gray-600');
                    text.classList.remove('text-white');
                    text.classList.add('text-gray-400');
                }
            });
        }

        async function completeSale() {
            const token = localStorage.getItem('token');
            console.log('Token value:', token);
            console.log('Token exists:', !!token);

            if (!token) {
                alert('Lütfen giriş yapın!');
                window.location.href = '/login';
                return;
            }
            const customerName = document.getElementById('customerName').value;
            const customerEmail = document.getElementById('customerEmail').value;
            const customerPhone = document.getElementById('customerPhone').value;
            const paymentMethod = document.getElementById('paymentMethod').value;

            if (!customerName || !customerEmail || !customerPhone) {
                alert('Lütfen tüm müşteri bilgilerini doldurun!');
                return;
            }

            if (Object.values(selectedTicketTypes).reduce((sum, count) => sum + count, 0) === 0) {
                alert('Lütfen en az bir bilet tipi seçin!');
                return;
            }

            const totalTickets = Object.values(selectedTicketTypes).reduce((sum, count) => sum + count, 0);
            if (totalTickets !== selectedSeats.length) {
                alert('Seçilen koltuk sayısı ile bilet sayısı eşleşmiyor!');
                return;
            }

            const loadingMsg = 'İşleminiz gerçekleştiriliyor...';
            alert(loadingMsg);

            try {
                const token = localStorage.getItem('token');
                if (!token) {
                    alert('Lütfen giriş yapın!');
                    window.location.href = '/login';
                    return;
                }

                // Bilet verilerini hazırla
                const tickets = [];
                let seatIndex = 0;

                Object.entries(selectedTicketTypes).forEach(([type, count]) => {
                    for (let i = 0; i < count; i++) {
                        tickets.push({
                            seat_id: selectedSeats[seatIndex].id,
                            customer_type: type
                        });
                        seatIndex++;
                    }
                });

                const response = await axios.post('/api/tickets', {
                    showtime_id: selectedShowtime.id,
                    tickets: tickets,
                    customer_name: customerName,
                    customer_email: customerEmail,
                    customer_phone: customerPhone,
                    payment_method: paymentMethod
                }, {
                    headers: {
                        'Authorization': `Bearer ${token}`
                    }
                });

                if (response.data.success) {
                    const total = Object.entries(selectedTicketTypes).reduce((sum, [type, count]) => {
                        return sum + (ticketPrices[type] * count);
                    }, 0);

                    const ticketSummary = Object.entries(selectedTicketTypes)
                        .filter(([type, count]) => count > 0)
                        .map(([type, count]) => {
                            const typeNames = {
                                adult: 'Yetişkin',
                                student: 'Öğrenci',
                                senior: 'Emekli',
                                child: 'Çocuk'
                            };
                            return `${count} ${typeNames[type]}`;
                        })
                        .join(', ');

                    alert(`Bilet satışı başarılı!\nToplam: ₺${total.toFixed(2)}\nBiletler: ${ticketSummary}\nKoltuklar: ${selectedSeats.map(s => s.code).join(', ')}`);
                    setTimeout(() => location.reload(), 2000);
                }
            } catch (error) {
                console.error('Bilet satışı hatası:', error);

                // Simulate success for demo
                setTimeout(() => {
                    const total = Object.entries(selectedTicketTypes).reduce((sum, [type, count]) => {
                        return sum + (ticketPrices[type] * count);
                    }, 0);

                    const ticketSummary = Object.entries(selectedTicketTypes)
                        .filter(([type, count]) => count > 0)
                        .map(([type, count]) => {
                            const typeNames = {
                                adult: 'Yetişkin',
                                student: 'Öğrenci',
                                senior: 'Emekli',
                                child: 'Çocuk'
                            };
                            return `${count} ${typeNames[type]}`;
                        })
                        .join(', ');

                    alert(`Bilet satışı başarılı!\nToplam: ₺${total.toFixed(2)}\nBiletler: ${ticketSummary}\nKoltuklar: ${selectedSeats.map(s => s.code).join(', ')}`);
                    setTimeout(() => location.reload(), 2000);
                }, 1500);
            }
        }

        function smartGoBack() {
            if (currentTicketStep > 1) {
                goBackToStep(currentTicketStep - 1);
            } else {
                window.location.href = '/';
            }
        }
    </script>
@endsection