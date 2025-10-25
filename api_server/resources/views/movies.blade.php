@extends('layout')

@section('content')
<div class="glass-effect p-8 rounded-2xl mb-8">
    <div class="flex items-center justify-between mb-6">
        <h2 class="text-3xl font-bold text-white flex items-center">
            <i class="fas fa-play mr-3 text-green-400"></i>
            Film Listesi
        </h2>
        <a href="/" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
            <i class="fas fa-arrow-left mr-2"></i>Geri
        </a>
    </div>
    
    <div class="flex flex-col md:flex-row gap-4 mb-8">
        <div class="flex-1">
            <input type="text" id="movieSearch" placeholder="Film adı ile ara..." 
                   class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-green-400 transition-all">
        </div>
        <button onclick="searchMovies()" class="bg-gradient-to-r from-green-500 to-emerald-500 hover:from-green-600 hover:to-emerald-600 text-white px-8 py-3 rounded-xl font-semibold transition-all">
            <i class="fas fa-search mr-2"></i>Ara
        </button>
    </div>
</div>

<div id="movieGrid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
    <!-- Movies will be loaded here -->
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    loadMovies();
});

async function loadMovies(search = '') {
    try {
        let url = '/api/movies';
        if (search) {
            url += `?search=${encodeURIComponent(search)}`;
        } else {
            url += '?per_page=100';
        }
        
        console.log('API URL:', url);
        const response = await axios.get(url);
        console.log('API Response:', response.data);
        
        const movies = response.data.data.data || response.data.data;
        console.log('Movies count:', movies.length);
        
        renderMovies(movies);
    } catch (error) {
        console.error('Filmler yüklenemedi:', error);
        console.error('Error details:', error.response?.data);
        // Mock data fallback
        const mockMovies = [
            { id: 1, title: "Avatar: The Way of Water", genre: "Sci-Fi", duration: 192, imdb_raiting: 7.6, description: "Jake Sully lives with his newfound family formed on the planet of Pandora." },
            { id: 2, title: "Top Gun: Maverick", genre: "Action", duration: 131, imdb_raiting: 8.3, description: "After thirty years, Maverick is still pushing the envelope as a top naval aviator." },
            { id: 3, title: "Black Panther: Wakanda Forever", genre: "Action", duration: 161, imdb_raiting: 6.7, description: "The people of Wakanda fight to protect their home from intervening world powers." },
            { id: 4, title: "Spider-Man: Across the Spider-Verse", genre: "Animation", duration: 140, imdb_raiting: 8.7, description: "Miles Morales catapults across the Multiverse." },
            { id: 5, title: "John Wick: Chapter 4", genre: "Action", duration: 169, imdb_raiting: 7.8, description: "John Wick uncovers a path to defeating The High Table." },
            { id: 6, title: "Guardians of the Galaxy Vol. 3", genre: "Sci-Fi", duration: 150, imdb_raiting: 7.9, description: "Still reeling from the loss of Gamora, Peter Quill rallies his team." }
        ];
        renderMovies(mockMovies);
    }
}

function renderMovies(movies) {
    const movieGrid = document.getElementById('movieGrid');
    let html = '';
    
    movies.forEach(movie => {
        // Poster URL kontrolü
        const posterUrl = movie.poster_url && movie.poster_url.trim() !== '' ? movie.poster_url : null;
        
        html += `
            <div class="glass-effect rounded-2xl overflow-hidden card-hover">
                <div class="h-64 bg-gradient-to-br from-green-600 to-emerald-600 flex items-center justify-center relative overflow-hidden">
                    ${posterUrl ? `
                        <img src="${posterUrl}" alt="${movie.title}" 
                             class="w-full h-full object-cover"
                             onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                        <div class="hidden w-full h-full bg-gradient-to-br from-purple-600 to-blue-600 flex items-center justify-center">
                            <i class="fas fa-film text-white text-6xl opacity-50"></i>
                        </div>
                    ` : `
                        <i class="fas fa-film text-white text-6xl opacity-50"></i>
                    `}
                    <div class="absolute inset-0 bg-black bg-opacity-20"></div>
                </div>
                <div class="p-6">
                    <h3 class="text-xl font-bold text-white mb-2">${movie.title}</h3>
                    <p class="text-purple-300 text-sm mb-2">${movie.genre} • ${movie.duration} dk</p>
                    <p class="text-yellow-400 mb-4">
                        <i class="fas fa-star mr-1"></i>${movie.imdb_raiting || movie.imdb_rating || 'N/A'}
                    </p>
                    <button onclick="showMovieDetails(${movie.id})" class="w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white py-2 rounded-xl font-semibold transition-all">
                        <i class="fas fa-info-circle mr-2"></i>Detaylar
                    </button>
                </div>
            </div>
        `;
    });
    
    movieGrid.innerHTML = html || '<p class="text-white text-center col-span-full">Film bulunamadı.</p>';
}

function searchMovies() {
    const searchTerm = document.getElementById('movieSearch').value;
    loadMovies(searchTerm);
}

async function showMovieDetails(movieId) {
    try {
        const response = await axios.get(`/api/movies/${movieId}`);
        const movie = response.data.data;
        
        // Modal oluştur
        createMovieDetailModal(movie);
    } catch (error) {
        console.error('Film detayı yüklenemedi:', error);
        alert('Film detayı yüklenemedi!');
    }
}

function createMovieDetailModal(movie) {
    // Mevcut modal varsa kaldır
    const existingModal = document.getElementById('movieDetailModal');
    if (existingModal) {
        existingModal.remove();
    }
    
    // Poster URL kontrolü
    const posterUrl = movie.poster_url && movie.poster_url.trim() !== '' ? movie.poster_url : null;
    
    // Modal HTML oluştur
    const modalHTML = `
        <div id="movieDetailModal" class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-50 p-4">
            <div class="bg-gray-900 rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
                <!-- Header -->
                <div class="flex justify-between items-center p-6 border-b border-gray-700">
                    <h2 class="text-2xl font-bold text-white">🎬 Film Detayları</h2>
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
                                        <span class="text-gray-300">Süre</span>
                                    </div>
                                    <span class="text-white font-semibold">${movie.duration || 'N/A'} dakika</span>
                                </div>
                                
                                <div class="bg-gray-800/50 p-4 rounded-lg">
                                    <div class="flex items-center mb-2">
                                        <i class="fas fa-tag text-green-400 mr-2"></i>
                                        <span class="text-gray-300">Tür</span>
                                    </div>
                                    <span class="text-white font-semibold">${movie.genre || 'N/A'}</span>
                                </div>
                                
                                <div class="bg-gray-800/50 p-4 rounded-lg">
                                    <div class="flex items-center mb-2">
                                        <i class="fas fa-calendar text-purple-400 mr-2"></i>
                                        <span class="text-gray-300">Çıkış Tarihi</span>
                                    </div>
                                    <span class="text-white font-semibold">${movie.release_date || 'N/A'}</span>
                                </div>
                                
                                <div class="bg-gray-800/50 p-4 rounded-lg">
                                    <div class="flex items-center mb-2">
                                        <i class="fas fa-globe text-orange-400 mr-2"></i>
                                        <span class="text-gray-300">Dil</span>
                                    </div>
                                    <span class="text-white font-semibold">${movie.language || 'N/A'}</span>
                                </div>
                            </div>
                            
                            <!-- Description -->
                            <div class="mb-6">
                                <h3 class="text-lg font-semibold text-white mb-3">
                                    <i class="fas fa-info-circle text-blue-400 mr-2"></i>Özet
                                </h3>
                                <p class="text-gray-300 leading-relaxed">${movie.description || 'Açıklama mevcut değil.'}</p>
                            </div>
                            
                            <!-- Actions -->
                            <div class="flex gap-4">
                                <button onclick="window.location.href='/ticket?movie=${movie.id}'" 
                                        class="bg-yellow-500 hover:bg-yellow-600 text-white px-6 py-3 rounded-lg font-semibold transition-all flex items-center">
                                    <i class="fas fa-ticket-alt mr-2"></i>Bilet Al
                                </button>
                                <button onclick="closeMovieDetailModal()" 
                                        class="bg-gray-600 hover:bg-gray-700 text-white px-6 py-3 rounded-lg font-semibold transition-all">
                                    <i class="fas fa-times mr-2"></i>Kapat
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

// Enter tuşu ile arama
document.getElementById('movieSearch')?.addEventListener('keypress', function(e) {
    if (e.key === 'Enter') {
        searchMovies();
    }
});

// Sayfa yüklendiğinde filmleri yükle
document.addEventListener('DOMContentLoaded', function() {
    loadMovies();
});
</script>
@endsection