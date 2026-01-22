@extends('layout')

@section('content')
<!-- Main Content -->
<div class="container mx-auto px-4 py-8">
    <h1 class="text-3xl font-bold mb-6">❤️ Favorite Movies</h1>

    <!-- Movies Grid -->
    <div id="moviesContainer" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
        <!-- Movies will be loaded here -->
    </div>

    <!-- Empty State -->
    <div id="emptyState" class="text-center py-20 hidden">
        <div class="text-6xl mb-4">❤️</div>
        <p class="text-xl text-gray-400 mb-4">No favorite movies yet</p>
        <p class="text-gray-500 mb-6">Start adding movies to your favorites by clicking the heart icon</p>
        <a href="/movies" class="inline-block bg-teal-500 hover:bg-teal-600 px-6 py-3 rounded-lg transition">
            Browse Movies
        </a>
    </div>

    <!-- Loading State -->
    <div id="loadingState" class="text-center py-20">
        <i class="fas fa-spinner fa-spin text-4xl text-teal-400 mb-4"></i>
        <p class="text-gray-400">Loading your favorites...</p>
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

    // Load favorite movies
    async function loadFavoriteMovies() {
        token = getToken();
        if (!token) {
            window.location.href = '/login';
            return;
        }

        try {
            const response = await fetch(`${API_URL}/favorite-movies`, {
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json'
                }
            });

            const data = await response.json();
            
            document.getElementById('loadingState').classList.add('hidden');
            
            if (data.success) {
                displayMovies(data.data);
            }
        } catch (error) {
            console.error('Error loading favorite movies:', error);
            document.getElementById('loadingState').classList.add('hidden');
        }
    }

    // Display movies
    function displayMovies(movies) {
        const container = document.getElementById('moviesContainer');
        const emptyState = document.getElementById('emptyState');

        if (movies.length === 0) {
            container.classList.add('hidden');
            emptyState.classList.remove('hidden');
            return;
        }

        container.classList.remove('hidden');
        emptyState.classList.add('hidden');

        container.innerHTML = movies.map(movie => `
            <div class="relative bg-gray-800 rounded-lg overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-300 group">
                <!-- Movie Poster -->
                <div class="relative aspect-[2/3]">
                    <img src="${movie.poster_url}" 
                         alt="${movie.title}" 
                         class="w-full h-full object-cover"
                         onerror="this.src='https://via.placeholder.com/300x450?text=No+Image'">
                    
                    <!-- Heart Icon (Remove from favorites) -->
                    <button onclick="removeFavorite(${movie.id}, event)" 
                            class="absolute top-2 right-2 bg-black bg-opacity-50 hover:bg-opacity-75 rounded-full p-2 transition z-10">
                        <i class="fas fa-heart text-red-500 text-xl"></i>
                    </button>

                    <!-- Overlay on hover -->
                    <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-60 transition-all duration-300 flex items-center justify-center">
                        <div class="opacity-0 group-hover:opacity-100 transition-opacity duration-300 text-center p-4">
                            <p class="text-sm line-clamp-3">${movie.description || 'No description available'}</p>
                        </div>
                    </div>
                </div>

                <!-- Movie Info -->
                <div class="p-4">
                    <h3 class="font-bold text-lg mb-2 line-clamp-2">${movie.title}</h3>
                    <div class="flex items-center justify-between text-sm text-gray-400">
                        <span class="flex items-center">
                            <i class="fas fa-star text-yellow-400 mr-1"></i>
                            ${movie.imdb_raiting || movie.imdb_rating || 'N/A'}
                        </span>
                        <span>${movie.duration || 0} min</span>
                    </div>
                    <p class="text-xs text-gray-500 mt-2">${movie.genre || ''}</p>
                </div>
            </div>
        `).join('');
    }

    // Remove from favorites
    async function removeFavorite(movieId, event) {
        event.stopPropagation();
        
        if (!confirm('Remove this movie from favorites?')) return;

        try {
            const response = await fetch(`${API_URL}/favorite-movies/${movieId}`, {
                method: 'DELETE',
                headers: {
                    'Authorization': `Bearer ${token}`,
                    'Accept': 'application/json'
                }
            });

            const data = await response.json();

            if (data.success) {
                // Reload the list
                loadFavoriteMovies();
                
                // Show success message
                showNotification('Removed from favorites', 'success');
            }
        } catch (error) {
            console.error('Error removing favorite:', error);
            showNotification('Error removing from favorites', 'error');
        }
    }

    // Show notification
    function showNotification(message, type = 'success') {
        const notification = document.createElement('div');
        notification.className = `fixed top-4 right-4 px-6 py-3 rounded-lg shadow-lg z-50 ${
            type === 'success' ? 'bg-green-600' : 'bg-red-600'
        }`;
        notification.textContent = message;
        document.body.appendChild(notification);

        setTimeout(() => {
            notification.remove();
        }, 3000);
    }

    // Load on page load
    loadFavoriteMovies();
</script>
@endsection
