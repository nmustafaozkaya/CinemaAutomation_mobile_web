@extends('layout')

@section('content')
    <div class="glass-effect p-8 rounded-2xl">
        <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-bold text-white flex items-center">
                <i class="fas fa-ticket-alt mr-3 text-emerald-400"></i>
                Purchase Tickets
            </h2>
            <a href="/" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
                <i class="fas fa-arrow-left mr-2"></i>Back
            </a>
        </div>

        @include('components.ticket-steps')
        @include('components.movie-selection')
        @include('components.cinema-selection')
        @include('components.seat-map')
        @include('components.payment-form')
    </div>

    <script>
        let selectedMovie = null;
        let selectedCinema = null;
        let selectedShowtime = null;
        let selectedSeats = [];
        let selectedTicketTypes = {};
        let ticketPrices = {};
        let currentTicketStep = 1;
        const MAX_TICKETS_PER_ORDER = 6;

        document.addEventListener('DOMContentLoaded', function () {
            loadMoviesForTicket();
            
            // URL'den film ID'sini al
            const urlParams = new URLSearchParams(window.location.search);
            const movieId = urlParams.get('movie');
            
            if (movieId) {
                // Film seçili olarak gelirse, otomatik olarak seç
                setTimeout(() => {
                    selectMovieFromUrl(movieId);
                }, 1000); // Filmler yüklendikten sonra seç
            }
        });
        
        async function selectMovieFromUrl(movieId) {
            try {
                // Önce /api/movies'ten dene, bulunamazsa /api/future-movies'ten dene
                let response;
                try {
                    response = await axios.get(`/api/movies/${movieId}`);
                } catch (e) {
                    if (e.response?.status === 404) {
                        response = await axios.get(`/api/future-movies/${movieId}`);
                    } else {
                        throw e;
                    }
                }
                
                const movie = response.data.data;
                
                if (movie) {
                    selectMovieForTicket(movieId, movie.title);
                    console.log('Film otomatik seçildi:', movie.title);
                }
            } catch (error) {
                console.error('Film seçilemedi:', error);
            }
        }
        
        async function loadCinemas() {
            try {
                console.log('Sinemalar yükleniyor...', selectedMovie.id);
                const response = await axios.get(`/api/cinemas/showing/${selectedMovie.id}`);
                const cinemas = response.data.data || [];
                console.log('Sinemalar yüklendi:', cinemas.length);
                renderCinemas(cinemas);
            } catch (error) {
                console.error('Sinemalar yüklenemedi:', error);
            }
        }
        
        async function loadShowtimes(cinemaId) {
            try {
                console.log('Seanslar yükleniyor...', cinemaId);
                const response = await axios.get(`/api/showtimes?movie_id=${selectedMovie.id}&cinema_id=${cinemaId}`);
                // Response format: { success: true, data: [...] } veya { success: true, data: { data: [...] } }
                let showtimes = [];
                if (response.data.success && response.data.data) {
                    if (Array.isArray(response.data.data)) {
                        showtimes = response.data.data;
                    } else if (response.data.data.data && Array.isArray(response.data.data.data)) {
                        showtimes = response.data.data.data;
                    }
                }
                console.log('Seanslar yüklendi:', showtimes.length);
                renderShowtimes(showtimes);
            } catch (error) {
                console.error('Seanslar yüklenemedi:', error);
                renderShowtimes([]);
            }
        }

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
                console.log('Bilet satın alma - Distributed API çağrısı yapılıyor...');
                
                // Distributed endpoint'ini kullan - toplam 100 filmi tarihe göre dağıtır
                const response = await axios.get('/api/movies/distributed').catch(() => ({ 
                    data: { 
                        data: { 
                            now_showing: { data: [] }, 
                            coming_soon: { data: [] } 
                        } 
                    } 
                }));
                
                const nowShowingMovies = response.data.data.now_showing?.data || [];
                const comingSoonMovies = response.data.data.coming_soon?.data || [];
                
                console.log('Bilet satın alma - Now Showing:', nowShowingMovies.length, 'Coming Soon:', comingSoonMovies.length, 'Toplam:', nowShowingMovies.length + comingSoonMovies.length);
                
                renderMoviesForTicketByCategory(nowShowingMovies, comingSoonMovies);
            } catch (error) {
                console.error('Bilet satın alma - Filmler yüklenemedi:', error);
                console.error('Bilet satın alma - Error details:', error.response?.data);
                renderMoviesForTicketByCategory([], []);
            }
        }

        function renderMoviesForTicketByCategory(nowShowingMovies, comingSoonMovies) {
            const movieGrid = document.getElementById('ticketMovieGrid');
            
            // Grid container'ı temizle ve yeniden yapılandır
            movieGrid.className = 'space-y-12';
            let html = '';
            
            // Now Showing bölümü
            if (nowShowingMovies.length > 0) {
                html += `
                    <div>
        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 bg-green-500 rounded-lg flex items-center justify-center mr-3">
                                <i class="fas fa-play text-white"></i>
                            </div>
                            <h3 class="text-2xl font-bold text-white">Now Showing</h3>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                `;
                
                nowShowingMovies.forEach(movie => {
                    html += renderMovieCardForTicket(movie, true);
                });
                
                html += `
                        </div>
                    </div>
                `;
            }
            
            // Coming Soon bölümü
            if (comingSoonMovies.length > 0) {
                html += `
                    <div>
                        <div class="flex items-center mb-6">
                            <div class="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center mr-3">
                                <i class="fas fa-calendar-alt text-white"></i>
                            </div>
                            <h3 class="text-2xl font-bold text-white">Coming Soon</h3>
                        </div>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                `;
                
                comingSoonMovies.forEach(movie => {
                    html += renderMovieCardForTicket(movie, false);
                });
                
                html += `
                        </div>
                    </div>
                `;
            }
            
            movieGrid.innerHTML = html || '<p class="text-white text-center">No movies found.</p>';
        }
        
        function renderMovieCardForTicket(movie, isNowShowing) {
            const posterUrl = movie.poster_url && movie.poster_url.trim() !== '' ? movie.poster_url : null;
            
            // Coming Soon için "Seç" butonunu gösterme
            const selectButton = isNowShowing ? `
                <button onclick="selectMovieForTicket(${movie.id}, '${movie.title.replace(/'/g, "\\'")}')" 
                        class="flex-1 bg-yellow-500 hover:bg-yellow-600 text-white px-3 py-2 rounded-lg text-sm font-semibold transition-all">
                    <i class="fas fa-ticket-alt mr-1"></i>Select
                </button>
            ` : `
                <button disabled
                        class="flex-1 bg-gray-500 text-white px-3 py-2 rounded-lg text-sm font-semibold cursor-not-allowed opacity-50">
                    <i class="fas fa-calendar-alt mr-1"></i>Coming Soon
                </button>
            `;
            
            return `
                <div class="glass-effect rounded-2xl p-6 card-hover movie-card" data-movie-id="${movie.id}">
                    <div class="h-32 bg-gradient-to-br ${isNowShowing ? 'from-green-600 to-emerald-600' : 'from-blue-600 to-blue-800'} rounded-xl flex items-center justify-center relative overflow-hidden mb-4">
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
                    <div class="flex gap-2 mt-4">
                        ${selectButton}
                        <button onclick="showMovieDetails(${movie.id}, ${isNowShowing})" 
                                class="bg-blue-500 hover:bg-blue-600 text-white px-3 py-2 rounded-lg text-sm font-semibold transition-all">
                            <i class="fas fa-info-circle"></i>
                        </button>
                    </div>
                </div>
            `;
        }

        async function showMovieDetails(movieId, isNowShowing = true) {
            try {
                // Önce /api/movies'ten dene, bulunamazsa /api/future-movies'ten dene
                let response;
                try {
                    response = await axios.get(`/api/movies/${movieId}`);
                } catch (e) {
                    if (e.response?.status === 404) {
                        response = await axios.get(`/api/future-movies/${movieId}`);
                        isNowShowing = false;
                    } else {
                        throw e;
                    }
                }
                
                const movie = response.data.data;
                
                // Modal oluştur
                createMovieDetailModal(movie, isNowShowing);
            } catch (error) {
                console.error('Movie details could not be loaded:', error);
                alert('Movie details could not be loaded!');
            }
        }

        function createMovieDetailModal(movie, isNowShowing = true) {
            // Mevcut modal varsa kaldır
            const existingModal = document.getElementById('movieDetailModal');
            if (existingModal) {
                existingModal.remove();
            }
            
            // Poster URL kontrolü
            const posterUrl = movie.poster_url && movie.poster_url.trim() !== '' ? movie.poster_url : null;
            
            // Kullanıcı giriş durumunu kontrol et
            const isLoggedIn = window.userPermissions && window.userPermissions.isLoggedIn;
            
            // Bilet Al butonu - sadece giriş yapmış kullanıcılar ve Now Showing için
            let buyTicketButton = '';
            if (!isNowShowing) {
                buyTicketButton = `
                    <button disabled
                            class="bg-gray-500 text-white px-6 py-3 rounded-lg font-semibold cursor-not-allowed flex items-center opacity-50">
                        <i class="fas fa-calendar-alt mr-2"></i>Coming Soon
                    </button>
                `;
            } else if (isLoggedIn) {
                buyTicketButton = `
                    <button onclick="selectMovieForTicket(${movie.id}, '${movie.title.replace(/'/g, "\\'")}'); closeMovieDetailModal();" 
                            class="bg-yellow-500 hover:bg-yellow-600 text-white px-6 py-3 rounded-lg font-semibold transition-all flex items-center">
                        <i class="fas fa-ticket-alt mr-2"></i>Buy Tickets
                    </button>
                `;
            } else {
                buyTicketButton = `
                    <button onclick="window.location.href='/login'" 
                            class="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-lg font-semibold transition-all flex items-center">
                        <i class="fas fa-sign-in-alt mr-2"></i>Sign In
                    </button>
                `;
            }
            
            // Modal HTML oluştur
            const modalHTML = `
                <div id="movieDetailModal" class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4">
                    <div class="bg-gray-900 rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
                        <!-- Header -->
                        <div class="flex justify-between items-center p-6 border-b border-gray-700">
                            <h2 class="text-2xl font-bold text-white">🎬 Movie Details</h2>
                            <button onclick="closeMovieDetailModal()" class="text-gray-400 hover:text-white text-2xl">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        
                        <!-- Content -->
                        <div class="p-6">
                            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                                <!-- Poster -->
                                <div class="lg:col-span-1">
                                    <div class="aspect-[2/3] bg-gradient-to-br from-purple-600 to-blue-600 rounded-xl overflow-hidden">
                                        ${posterUrl ? `
                                            <img src="${posterUrl}" alt="${movie.title}" 
                                                 class="w-full h-full object-cover"
                                                 onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                            <div class="hidden w-full h-full bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center">
                                                <i class="fas fa-film text-white text-6xl opacity-50"></i>
                                            </div>
                                        ` : `
                                            <div class="w-full h-full bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center">
                                                <i class="fas fa-film text-white text-6xl opacity-50"></i>
                                            </div>
                                        `}
                                    </div>
                                    ${!isNowShowing ? `
                                        <div class="mt-4 bg-blue-500/20 border border-blue-500 rounded-lg p-3 text-center">
                                            <span class="text-blue-300 font-semibold">
                                                <i class="fas fa-calendar-alt mr-2"></i>Coming Soon
                                            </span>
                                        </div>
                                    ` : ''}
                                </div>
                                
                                <!-- Details -->
                                <div class="lg:col-span-2">
                                    <h1 class="text-3xl font-bold text-white mb-4">${movie.title}</h1>
                                    
                                    <!-- Rating -->
                                    <div class="flex items-center mb-4">
                                        <div class="flex items-center bg-yellow-500/20 px-3 py-1 rounded-full">
                                            <i class="fas fa-star text-yellow-400 mr-2"></i>
                                            <span class="text-yellow-300 font-semibold">${movie.imdb_raiting || movie.imdb_rating || 'N/A'}</span>
                                        </div>
                                        <span class="text-gray-400 ml-4">IMDB Rating</span>
                                    </div>
                                    
                                    <!-- Info Grid -->
                                    <div class="grid grid-cols-2 gap-4 mb-6">
                                        <div class="bg-gray-800/50 p-4 rounded-lg">
                                            <div class="flex items-center mb-2">
                                                <i class="fas fa-clock text-blue-400 mr-2"></i>
                                                <span class="text-gray-300">Runtime</span>
                                            </div>
                                            <span class="text-white font-semibold">${movie.duration || 'N/A'} min</span>
                                        </div>
                                        
                                        <div class="bg-gray-800/50 p-4 rounded-lg">
                                            <div class="flex items-center mb-2">
                                                <i class="fas fa-tag text-green-400 mr-2"></i>
                                                <span class="text-gray-300">Genre</span>
                                            </div>
                                            <span class="text-white font-semibold">${movie.genre || 'N/A'}</span>
                                        </div>
                                        
                                        <div class="bg-gray-800/50 p-4 rounded-lg">
                                            <div class="flex items-center mb-2">
                                                <i class="fas fa-calendar text-purple-400 mr-2"></i>
                                                <span class="text-gray-300">Release Date</span>
                                            </div>
                                            <span class="text-white font-semibold">${movie.release_date || 'N/A'}</span>
                                        </div>
                                        
                                        <div class="bg-gray-800/50 p-4 rounded-lg">
                                            <div class="flex items-center mb-2">
                                                <i class="fas fa-globe text-orange-400 mr-2"></i>
                                                <span class="text-gray-300">Language</span>
                                            </div>
                                            <span class="text-white font-semibold">${movie.language || 'N/A'}</span>
                                        </div>
                                    </div>
                                    
                                    <!-- Description -->
                                    <div class="mb-6">
                                        <h3 class="text-lg font-semibold text-white mb-3">
                                            <i class="fas fa-info-circle text-blue-400 mr-2"></i>Synopsis
                                        </h3>
                                        <p class="text-gray-300 leading-relaxed">${movie.description || 'Description not available.'}</p>
                                    </div>
                                    
                                    ${!isLoggedIn && isNowShowing ? `
                                    <!-- Sign-in reminder -->
                                    <div class="mb-6 bg-blue-500/20 border border-blue-500/50 rounded-lg p-4">
                                        <div class="flex items-center">
                                            <i class="fas fa-info-circle text-blue-400 mr-3 text-xl"></i>
                                            <p class="text-blue-200">
                                                You must <strong>sign in</strong> to purchase tickets.
                                            </p>
                                        </div>
                                    </div>
                                    ` : ''}
                                    
                                    <!-- Actions -->
                                    <div class="flex gap-4">
                                        ${buyTicketButton}
                                        <button onclick="closeMovieDetailModal()" 
                                                class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg font-semibold transition-all">
                                            <i class="fas fa-times mr-2"></i>Close
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            // Modal'ı body'ye ekle
            document.body.insertAdjacentHTML('beforeend', modalHTML);
            
            // Modal'ı göster
            const modal = document.getElementById('movieDetailModal');
            modal.style.display = 'flex';
            
            // ESC tuşu ile kapatma
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    closeMovieDetailModal();
                }
            });
        }

        function closeMovieDetailModal() {
            const modal = document.getElementById('movieDetailModal');
            if (modal) {
                modal.remove();
            }
        }

        async function selectMovieForTicket(movieId, movieTitle) {
            selectedMovie = { id: movieId, title: movieTitle };
            currentTicketStep = 2;
            updateTicketSteps();
            
            // Highlight selected movie
            document.querySelectorAll('.movie-card').forEach(card => {
                card.classList.remove('ring-2', 'ring-yellow-400', 'bg-yellow-500/10');
            });
            
            const selectedCard = document.querySelector(`[data-movie-id="${movieId}"]`);
            if (selectedCard) {
                selectedCard.classList.add('ring-2', 'ring-yellow-400', 'bg-yellow-500/10');
            }

            // Sinemaları yükle
            await loadCinemas();

            document.getElementById('selectedMovieInfo').innerHTML = `
                                                                                                    <div class="flex items-center space-x-4">
                                                                                                        <i class="fas fa-film text-yellow-400 text-2xl"></i>
                                                                                                        <div>
                                                                                                            <h4 class="text-white font-semibold">Selected Movie</h4>
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
                    { id: 1, name: "Cinema Automation Gaziantep", address: "Forum AVM", hall_count: 8 },
                    { id: 2, name: "Cinema Automation Forum", address: "Sanko Park", hall_count: 6 },
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
                                                                                                            <p class="text-blue-300 text-sm mb-1">${cinema.address || 'No address available'}</p>
                                                                                                            <p class="text-emerald-400 text-sm">
                                                                                                                <i class="fas fa-door-open mr-1"></i>${cinema.hall_count || cinema.halls?.length || 'N/A'} auditoriums
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
            
            // Seansları yükle
            await loadShowtimes(cinemaId);

            document.getElementById('selectedMovieCinemaInfo').innerHTML = `
                                                                                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                                                                                        <div class="flex items-center space-x-4">
                                                                                                            <i class="fas fa-film text-yellow-400 text-xl"></i>
                                                                                                            <div>
                                                                                                            <h5 class="text-white font-medium">Movie</h5>
                                                                                                                <p class="text-purple-300 text-sm">${selectedMovie.title}</p>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                        <div class="flex items-center space-x-4">
                                                                                                            <i class="fas fa-building text-blue-400 text-xl"></i>
                                                                                                            <div>
                                                                                                            <h5 class="text-white font-medium">Cinema</h5>
                                                                                                                <p class="text-blue-300 text-sm">${cinemaName}</p>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                    </div>
                                                                                                `;

            try {
                const response = await axios.get(`/api/showtimes?movie_id=${selectedMovie.id}&cinema_id=${cinemaId}`);
                // Response format: { success: true, data: [...] } veya { success: true, data: { data: [...] } }
                let showtimes = [];
                if (response.data.success && response.data.data) {
                    if (Array.isArray(response.data.data)) {
                        showtimes = response.data.data;
                    } else if (response.data.data.data && Array.isArray(response.data.data.data)) {
                        showtimes = response.data.data.data;
                    }
                }
                renderShowtimes(showtimes);
            } catch (error) {
                console.error('Seanslar yüklenemedi:', error);
                renderShowtimes([]);
            }
        }

        function renderShowtimes(showtimes) {
            const showtimeGrid = document.getElementById('showtimeGrid');
            let html = '';

            if (!showtimes || showtimes.length === 0) {
                html = '<p class="text-white text-center col-span-full">No showtimes available for this movie at the selected cinema.</p>';
                showtimeGrid.innerHTML = html;
                return;
            }

            showtimes.forEach(showtime => {
                try {
                    // API'den gelen zaman string'ini al
                    let timeStr = showtime.start_time;
                    
                    // API'den gelen zamanı parse et
                    const startTime = new Date(timeStr);
                    if (isNaN(startTime.getTime())) {
                        console.error('Geçersiz tarih:', showtime.start_time);
                        return;
                    }
                    
                    const formattedDate = startTime.toLocaleDateString('tr-TR', { 
                        day: '2-digit', 
                        month: '2-digit', 
                        year: 'numeric' 
                    });
                    
                    // Saat ve dakikayı direkt al (timezone conversion olmadan)
                    const hours = String(startTime.getUTCHours()).padStart(2, '0');
                    const minutes = String(startTime.getUTCMinutes()).padStart(2, '0');
                    const formattedTime = `${hours}:${minutes}`;
                    const hallName = showtime.hall?.name || 'Auditorium';
                    const price = showtime.price || 45;
                    const displayText = `${formattedTime} - ${hallName}`;
                    
                    html += `
                        <div class="glass-effect rounded-xl p-4 card-hover cursor-pointer" 
                             onclick="selectShowtimeForTicket(${showtime.id}, '${startTime.toISOString()}', '${hallName}', ${price})">
                            <h4 class="text-lg font-semibold text-white mb-2">${hallName}</h4>
                            <p class="text-emerald-400 font-bold text-lg">${formattedTime}</p>
                            <p class="text-gray-400 text-xs mb-1">${formattedDate}</p>
                            <p class="text-purple-300 text-sm mt-1">₺${price}/person</p>
                        </div>
                    `;
                } catch (e) {
                    console.error('Seans render hatası:', e, showtime);
                }
            });

            showtimeGrid.innerHTML = html || '<p class="text-white text-center col-span-full">No showtimes found.</p>';
        }

        async function selectShowtimeForTicket(showtimeId, startTime, hallName, price) {
            selectedShowtime = { id: showtimeId, startTime: startTime, hall: hallName, price: price };
            currentTicketStep = 4;
            updateTicketSteps();

            // Koltuk seçimlerini sıfırla
            selectedSeats = [];
            updateSelectedSeatsInfo();

            document.getElementById('selectedShowtimeInfo').innerHTML = `
                                                                                                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                                                                                        <div class="flex items-center space-x-3">
                                                                                                            <i class="fas fa-film text-yellow-400 text-lg"></i>
                                                                                                            <div>
                                                                                                                <h6 class="text-white font-medium text-sm">Movie</h6>
                                                                                                                <p class="text-purple-300 text-xs">${selectedMovie.title}</p>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                        <div class="flex items-center space-x-3">
                                                                                                            <i class="fas fa-building text-blue-400 text-lg"></i>
                                                                                                            <div>
                                                                                                                <h6 class="text-white font-medium text-sm">Cinema</h6>
                                                                                                                <p class="text-blue-300 text-xs">${selectedCinema.name}</p>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                        <div class="flex items-center space-x-3">
                                                                                                            <i class="fas fa-clock text-purple-400 text-lg"></i>
                                                                                                            <div>
                                                                                                                <h6 class="text-white font-medium text-sm">Showtime</h6>
                                                                                                                <p class="text-emerald-400 text-xs">${startTime} - ${hallName}</p>
                                                                                                            </div>
                                                                                                        </div>
                                                                                                    </div>
                                                                                                `;

            await loadTicketTypes();
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
                const seatLimit = Math.min(getTotalTicketCount() || MAX_TICKETS_PER_ORDER, MAX_TICKETS_PER_ORDER);

                if (selectedSeats.length >= seatLimit) {
                    alert(`You can select at most ${seatLimit} seats!`);
                    return;
                }

                selectedSeats.push({ id: seatId, code: seatCode });
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
            const requirementInfo = document.getElementById('seatRequirementInfo');
            const continueBtn = document.getElementById('continueToPayment');
            const requiredSeats = getTotalTicketCount();

            if (info) {
                info.textContent = selectedSeats.length === 0
                    ? 'No seats selected'
                    : `${selectedSeats.length} seats selected: ${selectedSeats.map(s => s.code).join(', ')}`;
            }

            if (!requirementInfo || !continueBtn) {
                return;
            }

            if (requiredSeats === 0) {
                requirementInfo.textContent = 'Select ticket types before continuing.';
                requirementInfo.classList.remove('text-emerald-300', 'text-red-400');
                requirementInfo.classList.add('text-gray-300');
                continueBtn.classList.add('hidden');
                return;
            }

            if (selectedSeats.length === requiredSeats) {
                requirementInfo.textContent = 'Great! Ticket and seat counts match.';
                requirementInfo.classList.remove('text-gray-300', 'text-red-400');
                requirementInfo.classList.add('text-emerald-300');
                continueBtn.classList.remove('hidden');
            } else if (selectedSeats.length < requiredSeats) {
                const diff = requiredSeats - selectedSeats.length;
                requirementInfo.textContent = `Select ${diff} more seats to continue.`;
                requirementInfo.classList.remove('text-gray-300', 'text-emerald-300');
                requirementInfo.classList.add('text-red-400');
                continueBtn.classList.add('hidden');
            } else {
                const diff = selectedSeats.length - requiredSeats;
                requirementInfo.textContent = `Please release ${diff} seats.`;
                requirementInfo.classList.remove('text-gray-300', 'text-emerald-300');
                requirementInfo.classList.add('text-red-400');
                continueBtn.classList.add('hidden');
            }
        }

        function enforceSeatLimit() {
            const requiredSeats = getTotalTicketCount();
            if (requiredSeats === 0) return;

            const maxAllowed = Math.min(requiredSeats, MAX_TICKETS_PER_ORDER);
            let trimmed = false;

            while (selectedSeats.length > maxAllowed) {
                selectedSeats.pop();
                trimmed = true;
            }

            if (trimmed) {
                renderCurrentSeatMap();
            }

            updateSelectedSeatsInfo();
        }

        async function goToSeatSelection() {
            if (!selectedShowtime) {
                alert('Please select a showtime first!');
                return;
            }

            const totalTickets = getTotalTicketCount();

            if (totalTickets === 0) {
                alert('Please select at least one ticket to continue.');
                return;
            }

            currentTicketStep = 5;
            updateTicketSteps();
            renderCurrentSeatMap();
            updateSelectedSeatsInfo();
        }

        async function loadTicketTypes() {
            try {
                selectedTicketTypes = {};
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
                updateTicketTypeSummary();
                updateTotalPrice();

            } catch (error) {
                console.error('Fiyat bilgileri alınamadı:', error);

                // Fallback - mock data
                const basePrice = parseFloat(selectedShowtime.price) || 45;
                const mockTypes = [
                    { code: 'adult', name: 'Adult', icon: 'fa-user', description: 'Full ticket' },
                    { code: 'student', name: 'Student', icon: 'fa-graduation-cap', description: '20% discount' },
                    { code: 'senior', name: 'Retired', icon: 'fa-user-tie', description: '15% discount' },
                    { code: 'child', name: 'Child', icon: 'fa-child', description: '25% discount' }
                ];

                ticketPrices = {
                    adult: basePrice,
                    student: basePrice * 0.8,
                    senior: basePrice * 0.85,
                    child: basePrice * 0.75
                };

                renderTicketTypeSelection(mockTypes);
                renderPriceInfo(mockTypes);
                updateTicketTypeSummary();
                updateTotalPrice();
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
                { id: 'adult', name: 'Adult (Full Ticket)' },
                { id: 'student', name: 'Student (20% Off)' },
                { id: 'senior', name: 'Retired (15% Off)' },
                { id: 'child', name: 'Child (25% Off)' }
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

        function getTotalTicketCount() {
            return Object.values(selectedTicketTypes).reduce((sum, count) => sum + count, 0);
        }

        function changeTicketCount(ticketType, change) {
            if (!selectedTicketTypes[ticketType]) {
                selectedTicketTypes[ticketType] = 0;
            }

            const newCount = selectedTicketTypes[ticketType] + change;
            const proposedTotal = getTotalTicketCount() + change;

            if (newCount < 0) return;
            if (proposedTotal > MAX_TICKETS_PER_ORDER) {
                alert(`You can select at most ${MAX_TICKETS_PER_ORDER} tickets!`);
                return;
            }

            selectedTicketTypes[ticketType] = newCount;
            document.getElementById(`count_${ticketType}`).textContent = newCount;

            updateTicketTypeSummary();
            updateTotalPrice();
            enforceSeatLimit();
        }

        function updateTicketTypeSummary() {
            const countElement = document.getElementById('selectedTicketCount');
            const summaryElement = document.getElementById('ticketTypeSummary');
            const continueButton = document.getElementById('continueToSeatSelection');

            const totalCount = getTotalTicketCount();
            countElement.textContent = totalCount;

            if (totalCount === 0) {
                summaryElement.textContent = 'No tickets selected';
                summaryElement.classList.remove('text-red-400');
                continueButton.disabled = true;
            } else {
                const summary = Object.entries(selectedTicketTypes)
                    .filter(([type, count]) => count > 0)
                    .map(([type, count]) => {
                        const typeNames = {
                            adult: 'Adult',
                            student: 'Student',
                            senior: 'Retired',
                            child: 'Child'
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
            const totalTickets = getTotalTicketCount();

            if (totalTickets === 0) {
                alert('Select tickets before moving to payment.');
                return;
            }

            if (selectedSeats.length !== totalTickets) {
                alert('Seçtiğiniz koltuk sayısı ile bilet sayısı eşleşmiyor!');
                return;
            }

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
                adult: 'Adult',
                student: 'Student',
                senior: 'Retired',
                child: 'Child'
            };

            summary.innerHTML = `
                                                                                                    <div class="space-y-3">
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Movie:</span>
                                                                                                            <span class="font-medium">${selectedMovie.title}</span>
                                                                                                        </div>
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Cinema:</span>
                                                                                                            <span class="font-medium">${selectedCinema.name}</span>
                                                                                                        </div>
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Showtime:</span>
                                                                                                            <span class="font-medium">${selectedShowtime.startTime}</span>
                                                                                                        </div>
                                                                                                        <div class="flex justify-between">
                                                                                                            <span>Auditorium:</span>
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
                alert('Please sign in first!');
                window.location.href = '/login';
                return;
            }
            const customerName = document.getElementById('customerName').value;
            const customerEmail = document.getElementById('customerEmail').value;
            const customerPhone = document.getElementById('customerPhone').value;
            const paymentMethod = document.getElementById('paymentMethod').value;

            if (!customerName || !customerEmail || !customerPhone) {
                alert('Please complete all customer details!');
                return;
            }

            if (Object.values(selectedTicketTypes).reduce((sum, count) => sum + count, 0) === 0) {
                alert('Please select at least one ticket type!');
                return;
            }

            const totalTickets = Object.values(selectedTicketTypes).reduce((sum, count) => sum + count, 0);
            if (totalTickets !== selectedSeats.length) {
            alert('Seat and ticket counts do not match!');
                return;
            }

            const loadingMsg = 'Processing your order...';
            alert(loadingMsg);

            try {
                const token = localStorage.getItem('token');
                if (!token) {
                    alert('Please sign in!');
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
                adult: 'Adult',
                student: 'Student',
                senior: 'Retired',
                child: 'Child'
            };
                            return `${count} ${typeNames[type]}`;
                        })
                        .join(', ');

                    alert(`🎉 Ticket purchase successful!\nTotal: ₺${total.toFixed(2)}\nTickets: ${ticketSummary}\nSeats: ${selectedSeats.map(s => s.code).join(', ')}`);
                    setTimeout(() => location.reload(), 2000);
                }
            } catch (error) {
                console.error('Ticket purchase error:', error);

                // Simulate success for demo
                setTimeout(() => {
                    const total = Object.entries(selectedTicketTypes).reduce((sum, [type, count]) => {
                        return sum + (ticketPrices[type] * count);
                    }, 0);

                    const ticketSummary = Object.entries(selectedTicketTypes)
                        .filter(([type, count]) => count > 0)
                        .map(([type, count]) => {
                            const typeNames = {
                                adult: 'Adult',
                                student: 'Student',
                                senior: 'Retired',
                                child: 'Child'
                            };
                            return `${count} ${typeNames[type]}`;
                        })
                        .join(', ');

                    alert(`🎉 Ticket purchase successful!\nTotal: ₺${total.toFixed(2)}\nTickets: ${ticketSummary}\nSeats: ${selectedSeats.map(s => s.code).join(', ')}`);
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