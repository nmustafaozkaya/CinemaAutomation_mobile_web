<!-- Step 2: Sinema Seçimi -->
<div id="ticketStep2" class="ticket-step hidden">
    <div class="flex items-center justify-between mb-6">
        <h3 class="text-2xl font-bold text-white text-center flex-1">
            <i class="fas fa-building mr-2 text-green-400"></i>Sinema Seçiniz
        </h3>
        <button onclick="goBackToStep(1)" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
            <i class="fas fa-arrow-left mr-2"></i>Film Değiştir
        </button>
    </div>

    <!-- Selected Movie Info -->
    <div id="selectedMovieInfo" class="bg-white/10 p-4 rounded-xl mb-6">
        <!-- Selected movie info will be shown here -->
    </div>

    <!-- City Filter -->
    <div class="mb-6">
        <div class="max-w-md mx-auto">
            <label class="block text-white text-sm font-medium mb-2">
                <i class="fas fa-map-marker-alt mr-1"></i>Şehir Filtresi (İsteğe Bağlı)
            </label>
            <select id="cityFilter" onchange="window.cinemaSelection.filterByCity(this.value)"
                class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white focus:bg-white/20 focus:border-green-400 transition-all"
                style="color: white; background-color: rgba(255, 255, 255, 0.1);">
                <option value="" style="background-color: #1f2937; color: white;">Tüm Şehirler</option>
                <!-- Cities will be loaded here -->
            </select>
        </div>
    </div>
    
    <!-- Cinema Count Info -->
    <div id="cinemaCountInfo" class="text-center mb-4">
        <span class="text-green-300 text-sm">
            <i class="fas fa-info-circle mr-1"></i>
            <span id="filteredCinemaCount">0</span> sinema bulundu
        </span>
    </div>

    <!-- Loading State -->
    <div id="cinemaLoadingState" class="text-center py-12 hidden">
        <div class="loading w-12 h-12 border-4 border-green-400 border-t-transparent rounded-full mx-auto mb-4"></div>
        <p class="text-white">Sinemalar yükleniyor...</p>
    </div>

    <!-- Cinemas Grid -->
    <div id="cinemaGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <!-- Cinema selection will be loaded here -->
    </div>

    <!-- Empty State -->
    <div id="cinemaEmptyState" class="text-center py-12 hidden">
        <div class="w-24 h-24 bg-gray-600 rounded-full flex items-center justify-center mx-auto mb-4">
            <i class="fas fa-building text-gray-400 text-3xl"></i>
        </div>
        <h4 class="text-xl font-bold text-white mb-2">Sinema Bulunamadı</h4>
        <p class="text-gray-400">Bu film için seçilen şehirde sinema bulunmuyor.</p>
        <button onclick="window.cinemaSelection.clearFilters()"
            class="mt-4 bg-green-500 hover:bg-green-600 text-white px-4 py-2 rounded-lg font-medium">
            <i class="fas fa-refresh mr-2"></i>Tüm Sinemalar
        </button>
    </div>
</div>

<script>
// Cinema Selection JavaScript
class CinemaSelection {
    constructor() {
        this.cinemas = [];
        this.filteredCinemas = [];
        this.availableCities = [];
        this.selectedMovie = null;
        this.currentCityFilter = '';
        
        // DOM Elements
        this.loadingElement = document.getElementById('cinemaLoadingState');
        this.gridElement = document.getElementById('cinemaGrid');
        this.emptyElement = document.getElementById('cinemaEmptyState');
        this.movieInfoElement = document.getElementById('selectedMovieInfo');
        this.cityFilterElement = document.getElementById('cityFilter');
        this.countInfoElement = document.getElementById('filteredCinemaCount');
    }

    async loadCinemas(preferredCityId = '') {
        try {
            this.showLoading();
            
            if (!this.selectedMovie || !this.selectedMovie.id) {
                throw new Error('Film seçilmedi');
            }

            // Mevcut CinemaController metodunu kullan
            const response = await axios.get(`/api/cinemas/showing/${this.selectedMovie.id}`);
            const data = response.data;
            
            this.cinemas = data.data || [];
            
            // Şehirleri sinemalardan çıkar ve temizle
            this.availableCities = [];
            const cityMap = new Map();
            
            this.cinemas.forEach(cinema => {
                if (cinema.city && cinema.city.id && cinema.city.name) {
                    // Aynı ID'ye sahip şehirleri tekrarlamadan ekle
                    if (!cityMap.has(cinema.city.id)) {
                        cityMap.set(cinema.city.id, {
                            id: cinema.city.id,
                            name: cinema.city.name
                        });
                    }
                }
            });
            
            // Map'ten array'e çevir
            this.availableCities = Array.from(cityMap.values());
            
            this.filteredCinemas = [...this.cinemas];
            
            this.renderCityFilter();
            this.updateCinemaCount();

            const effectiveCityId = preferredCityId || this.currentCityFilter || '';
            
            // Debug için console log
            console.log('Yüklenen sinemalar:', this.cinemas.length);
            console.log('Bulunan şehirler:', this.availableCities);
            
            // Loading'i kapat ve içeriği göster
            if (this.cinemas.length === 0) {
                this.showEmpty();
            } else if (effectiveCityId) {
                this.applyCityFilter(effectiveCityId, { 
                    skipLoading: true, 
                    updateDropdown: true 
                });
            } else {
                // Önce sinemaları render et
                this.filteredCinemas = [...this.cinemas];
                this.renderCinemas(this.cinemas);
                // Sonra grid'i göster (loading'i kapatır)
                this.showGrid();
            }
            
        } catch (error) {
            console.error('Sinema yükleme hatası:', error);
            console.log('Mock data yükleniyor:', error.message);
            this.renderMockCinemas();
            this.showGrid();
        }
    }

    renderCityFilter() {
        let html = '<option value="" style="background-color: #1f2937; color: white;">Tüm Şehirler</option>';
        
        if (this.availableCities && this.availableCities.length > 0) {
            this.availableCities.forEach(city => {
                if (city && city.id && city.name) {
                    html += `<option value="${city.id}" style="background-color: #1f2937; color: white;">${city.name}</option>`;
                }
            });
        }
        
        this.cityFilterElement.innerHTML = html;
        
        // Eğer şehir yoksa bilgi ver
        if (this.availableCities.length === 0) {
            console.warn('Şehir bilgisi bulunamadı. Sinemalarda city ilişkisi eksik olabilir.');
        }
    }

    filterByCity(cityId) {
        this.applyCityFilter(cityId);
    }

    applyCityFilter(cityId, options = {}) {
        const { skipLoading = false, updateDropdown = false } = options;

        try {
            if (!skipLoading) {
                this.showLoading();
            }
            
            this.currentCityFilter = cityId || '';

            if (updateDropdown && this.cityFilterElement) {
                this.cityFilterElement.value = this.currentCityFilter;
            }
            
            if (!this.currentCityFilter) {
                this.filteredCinemas = [...this.cinemas];
            } else {
                this.filteredCinemas = this.cinemas.filter(cinema => {
                    if (!cinema.city) return false;
                    return cinema.city.id == this.currentCityFilter || cinema.city_id == this.currentCityFilter;
                });
            }
            
            this.updateCinemaCount();

            const renderFiltered = () => {
                if (this.filteredCinemas.length === 0) {
                    this.showEmpty();
                } else {
                    this.renderCinemas(this.filteredCinemas);
                    this.showGrid();

                    setTimeout(() => {
                        if (this.gridElement && this.gridElement.classList.contains('hidden')) {
                            console.warn('Grid hala gizli, zorla gösteriliyor...');
                            this.showGrid();
                        }
                    }, 50);
                }
            };

            if (skipLoading) {
                renderFiltered();
            } else {
                setTimeout(renderFiltered, 50);
            }
        } catch (error) {
            console.error('Şehir filtreleme hatası:', error);
            this.filteredCinemas = [...this.cinemas];
            this.updateCinemaCount();
            this.renderCinemas(this.filteredCinemas);
            this.showGrid();
        }
    }

    clearFilters() {
        try {
            this.currentCityFilter = '';
            if (this.cityFilterElement) {
                this.cityFilterElement.value = '';
            }
            this.filteredCinemas = [...this.cinemas];
            this.updateCinemaCount();
            this.renderCinemas(this.filteredCinemas);
            this.showGrid();
        } catch (error) {
            console.error('Filtre temizleme hatası:', error);
        }
    }

    updateCinemaCount() {
        this.countInfoElement.textContent = this.filteredCinemas.length;
    }

    renderCinemas(cinemas) {
        if (!this.gridElement) {
            console.error('Grid element bulunamadı!');
            return;
        }
        
        if (!cinemas || cinemas.length === 0) {
            this.gridElement.innerHTML = '';
            return;
        }
        
        let html = '';
        
        try {
            cinemas.forEach(cinema => {
                // Seans sayısını hesapla
                const showtimeCount = cinema.halls ? 
                    cinema.halls.reduce((total, hall) => total + (hall.showtimes ? hall.showtimes.length : 0), 0) : 0;
                
                // XSS koruması için string escape
                const cinemaName = (cinema.name || 'İsimsiz Sinema').replace(/'/g, "\\'").replace(/"/g, '&quot;');
                const cinemaAddress = (cinema.address || 'Adres bilgisi yok').replace(/'/g, "\\'").replace(/"/g, '&quot;');
                const cityName = cinema.city ? (cinema.city.name || 'Şehir bilgisi yok') : 'Şehir bilgisi yok';
                
                html += `
                    <div class="glass-effect rounded-2xl p-6 card-hover cursor-pointer" 
                         onclick="selectCinemaForTicket(${cinema.id}, '${cinemaName}', '${cinemaAddress}')">
                        <div class="h-20 bg-gradient-to-br from-blue-600 to-purple-600 rounded-xl flex items-center justify-center mb-4">
                            <i class="fas fa-building text-white text-3xl opacity-70"></i>
                        </div>
                        <h4 class="text-lg font-bold text-white mb-2">${cinemaName}</h4>
                        <p class="text-blue-300 text-sm mb-1">
                            <i class="fas fa-map-marker-alt mr-1"></i>${cityName}
                        </p>
                        <p class="text-gray-400 text-xs mb-2">
                            ${cinemaAddress}
                        </p>
                        <p class="text-emerald-400 text-sm">
                            <i class="fas fa-door-open mr-1"></i>${cinema.halls ? cinema.halls.length : 'N/A'} Salon
                        </p>
                        <p class="text-yellow-400 text-sm">
                            <i class="fas fa-clock mr-1"></i>${showtimeCount} Seans
                        </p>
                        ${cinema.phone ? `
                            <p class="text-gray-400 text-xs mt-1">
                                <i class="fas fa-phone mr-1"></i>${cinema.phone}
                            </p>
                        ` : ''}
                    </div>
                `;
            });
            
            this.gridElement.innerHTML = html;
            
            // Grid'in görünür olduğundan emin ol
            this.gridElement.style.display = 'grid';
            this.gridElement.style.opacity = '1';
            this.gridElement.style.visibility = 'visible';
            
        } catch (error) {
            console.error('Sinema render hatası:', error);
            this.gridElement.innerHTML = '<div class="text-white text-center p-4">Sinemalar yüklenirken bir hata oluştu.</div>';
        }
    }

    renderMockCinemas() {
        const mockCinemas = [
            { 
                id: 1, 
                name: "Cinema Automation Gaziantep", 
                address: "Forum AVM, Şehitkamil",
                city: { id: 1, name: "Gaziantep" },
                halls: [{ showtimes: [1, 2, 3] }, { showtimes: [4, 5] }],
                phone: "0342 123 45 67"
            },
            { 
                id: 2, 
                name: "Cinema Automation Ankara", 
                address: "Ankamall AVM",
                city: { id: 2, name: "Ankara" },
                halls: [{ showtimes: [1, 2] }, { showtimes: [3, 4] }],
                phone: "0312 234 56 78"
            },
            { 
                id: 3, 
                name: "CineBonus İstanbul", 
                address: "İstinyePark AVM",
                city: { id: 3, name: "İstanbul" },
                halls: [{ showtimes: [1, 2, 3, 4] }],
                phone: "0212 345 67 89"
            },
            { 
                id: 4, 
                name: "Cinema Automation Adana", 
                address: "M1 AVM",
                city: { id: 4, name: "Adana" },
                halls: [{ showtimes: [1, 2] }],
                phone: "0322 456 78 90"
            }
        ];
        
        this.cinemas = mockCinemas;
        this.filteredCinemas = [...mockCinemas];
        this.availableCities = [
            { id: 1, name: "Gaziantep" },
            { id: 2, name: "Ankara" },
            { id: 3, name: "İstanbul" },
            { id: 4, name: "Adana" }
        ];
        
        this.renderCityFilter();
        this.updateCinemaCount();
        this.renderCinemas(mockCinemas);
    }

    showSelectedMovie(movie) {
        this.selectedMovie = movie;
        this.movieInfoElement.innerHTML = `
            <div class="flex items-center space-x-4">
                <i class="fas fa-film text-yellow-400 text-2xl"></i>
                <div>
                    <h4 class="text-white font-semibold">Seçilen Film</h4>
                    <p class="text-purple-300">${movie.title}</p>
                </div>
                <div class="ml-auto">
                    <span class="px-3 py-1 bg-yellow-500/20 text-yellow-300 rounded-full text-sm">
                        <i class="fas fa-check mr-1"></i>Seçildi
                    </span>
                </div>
            </div>
        `;
    }

    showLoading() {
        if (this.loadingElement) {
            this.loadingElement.classList.remove('hidden');
        }
        if (this.gridElement) {
            this.gridElement.classList.add('hidden');
        }
        if (this.emptyElement) {
            this.emptyElement.classList.add('hidden');
        }
    }

    showGrid() {
        if (this.loadingElement) {
            this.loadingElement.classList.add('hidden');
            this.loadingElement.style.display = 'none';
        }
        if (this.gridElement) {
            this.gridElement.classList.remove('hidden');
            // Grid'in görünür olduğundan emin ol
            this.gridElement.style.display = 'grid';
            this.gridElement.style.opacity = '1';
            this.gridElement.style.visibility = 'visible';
            this.gridElement.style.minHeight = '200px';
        }
        if (this.emptyElement) {
            this.emptyElement.classList.add('hidden');
            this.emptyElement.style.display = 'none';
        }
    }

    showEmpty() {
        if (this.loadingElement) {
            this.loadingElement.classList.add('hidden');
        }
        if (this.gridElement) {
            this.gridElement.classList.add('hidden');
        }
        if (this.emptyElement) {
            this.emptyElement.classList.remove('hidden');
        }
    }

    // Get cinema by ID
    getCinemaById(id) {
        return this.cinemas.find(cinema => cinema.id == id);
    }

    // Get filtered cinemas
    getFilteredCinemas() {
        return this.filteredCinemas;
    }

    // Reset selection
    reset() {
        this.cinemas = [];
        this.filteredCinemas = [];
        this.availableCities = [];
        this.selectedMovie = null;
        this.currentCityFilter = '';
        this.cityFilterElement.value = '';
        this.updateCinemaCount();
    }
}

// Initialize cinema selection
document.addEventListener('DOMContentLoaded', function() {
    window.cinemaSelection = new CinemaSelection();
});

// Global function for movie selection (called from movie component)
async function selectMovieForTicket(movieId, movieTitle) {
    selectedMovie = { id: movieId, title: movieTitle };
    currentTicketStep = 2;
    updateTicketSteps();

    // Show selected movie info
    window.cinemaSelection.showSelectedMovie(selectedMovie);
    
    // Load cinemas for this movie (TÜM SİNEMALAR)
    const preferredCityId = window.movieSelection?.currentCityId || '';
    await window.cinemaSelection.loadCinemas(preferredCityId);
}

// Global function for cinema selection
async function selectCinemaForTicket(cinemaId, cinemaName, cinemaAddress) {
    selectedCinema = { 
        id: cinemaId, 
        name: cinemaName, 
        address: cinemaAddress 
    };
    
    currentTicketStep = 3;
    updateTicketSteps();

    // Show selected cinema and movie info
    document.getElementById('selectedMovieCinemaInfo').innerHTML = `
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="flex items-center space-x-3">
                <i class="fas fa-film text-yellow-400 text-lg"></i>
                <div>
                    <h6 class="text-white font-medium text-sm">Seçilen Film</h6>
                    <p class="text-purple-300 text-xs">${selectedMovie.title}</p>
                </div>
            </div>
            <div class="flex items-center space-x-3">
                <i class="fas fa-building text-blue-400 text-lg"></i>
                <div>
                    <h6 class="text-white font-medium text-sm">Seçilen Sinema</h6>
                    <p class="text-blue-300 text-xs">${cinemaName}</p>
                </div>
            </div>
        </div>
    `;

    // Load showtimes for this movie and cinema
    await loadShowtimesForCinema();
}
</script>