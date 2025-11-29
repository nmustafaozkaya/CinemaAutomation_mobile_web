@extends('layout')

@section('content')
    <div class="glass-effect p-8 rounded-2xl">
        <!-- Header -->
        <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-bold text-white flex items-center">
                <i class="fas fa-history mr-3 text-emerald-400"></i>
                Biletlerim
            </h2>
            <a href="/" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
                <i class="fas fa-arrow-left mr-2"></i>Ana Sayfa
            </a>
        </div>

        <!-- Filter Section -->
        <div class="bg-white/10 p-4 rounded-xl mb-6">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                <div>
                    <label class="block text-white text-sm font-medium mb-2">Tarih Filtresi</label>
                    <select id="dateFilter" class="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white">
                        <option value="">Tüm Tarihler</option>
                        <option value="today">Bugün</option>
                        <option value="week">Bu Hafta</option>
                        <option value="month">Bu Ay</option>
                    </select>
                </div>
                <div>
                    <label class="block text-white text-sm font-medium mb-2">Durum Filtresi</label>
                    <select id="statusFilter" class="w-full px-3 py-2 bg-white/10 border border-white/20 rounded-lg text-white">
                        <option value="">Tüm Durumlar</option>
                        <option value="sold">Aktif</option>
                        <option value="cancelled">İptal Edildi</option>
                        <option value="refunded">İade Edildi</option>
                    </select>
                </div>
                <div class="flex items-end">
                    <button onclick="applyFilters()" class="w-full bg-emerald-500 hover:bg-emerald-600 text-white py-2 px-4 rounded-lg font-medium">
                        <i class="fas fa-filter mr-2"></i>Filtrele
                    </button>
                </div>
            </div>
        </div>

        <!-- Loading -->
        <div id="loadingState" class="text-center py-12">
            <div class="loading w-12 h-12 border-4 border-emerald-500 border-t-transparent rounded-full mx-auto mb-4"></div>
            <p class="text-white">Biletleriniz yükleniyor...</p>
        </div>

        <!-- Empty State -->
        <div id="emptyState" class="text-center py-12 hidden">
            <div class="w-24 h-24 bg-gray-600 rounded-full flex items-center justify-center mx-auto mb-4">
                <i class="fas fa-ticket-alt text-gray-400 text-3xl"></i>
            </div>
            <h3 class="text-xl font-bold text-white mb-2">Henüz Biletiniz Bulunmuyor</h3>
            <p class="text-gray-400 mb-6">Hemen bir bilet satın alarak sinemaya gitmeye başlayın!</p>
            <a href="/tickets" class="bg-emerald-500 hover:bg-emerald-600 text-white px-6 py-3 rounded-lg font-medium inline-flex items-center">
                <i class="fas fa-ticket-alt mr-2"></i>Bilet Al
            </a>
        </div>

        <!-- Tickets List -->
        <div id="ticketsList" class="space-y-4 hidden">
            <!-- Tickets will be loaded here -->
        </div>

        <!-- Pagination -->
        <div id="paginationContainer" class="mt-8 flex justify-center hidden">
            <!-- Pagination will be loaded here -->
        </div>
    </div>

    <!-- Ticket Detail Modal -->
    <div id="ticketModal" class="fixed inset-0 bg-black bg-opacity-50 hidden flex items-center justify-center z-50 p-4">
        <div class="bg-slate-800 rounded-2xl p-6 max-w-md w-full">
            <div class="flex items-center justify-between mb-4">
                <h3 class="text-xl font-bold text-white">Bilet Detayı</h3>
                <button onclick="closeTicketModal()" class="text-gray-400 hover:text-white">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            <div id="ticketModalContent">
                <!-- Ticket details will be loaded here -->
            </div>
        </div>
    </div>

    <script>
        let currentPage = 1;
        let totalPages = 1;

        document.addEventListener('DOMContentLoaded', function() {
            loadMyTickets();
        });

        async function loadMyTickets(page = 1) {
            try {
                const token = localStorage.getItem('token');
                if (!token) {
                    window.location.href = '/login';
                    return;
                }

                showLoading();

                const response = await axios.get(`/api/my-tickets?page=${page}`, {
                    headers: {
                        'Authorization': `Bearer ${token}`
                    }
                });

                hideLoading();

                if (response.data.success) {
                    const tickets = response.data.data.data;
                    currentPage = response.data.data.current_page;
                    totalPages = response.data.data.last_page;

                    if (tickets.length === 0) {
                        showEmptyState();
                    } else {
                        renderTickets(tickets);
                        renderPagination();
                    }
                }

            } catch (error) {
                hideLoading();
                console.error('Biletler yüklenemedi:', error);
                
                if (error.response?.status === 401) {
                    localStorage.removeItem('token');
                    window.location.href = '/login';
                } else {
                    showEmptyState();
                }
            }
        }

        function renderTickets(tickets) {
            const container = document.getElementById('ticketsList');
            let html = '';

            tickets.forEach(ticket => {
                const showtime = ticket.showtime;
                const movie = showtime.movie;
                const hall = showtime.hall;
                const cinema = hall.cinema;
                const seat = ticket.seat;

                const showtimeDate = new Date(showtime.start_time);
                const purchaseDate = new Date(ticket.created_at);

                const statusColors = {
                    'sold': 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30',
                    'cancelled': 'bg-red-500/20 text-red-300 border-red-500/30',
                    'refunded': 'bg-yellow-500/20 text-yellow-300 border-yellow-500/30'
                };

                const statusLabels = {
                    'sold': 'Aktif',
                    'cancelled': 'İptal Edildi',
                    'refunded': 'İade Edildi'
                };

                const customerTypeLabels = {
                    'adult': 'Adult',
                    'student': 'Student',
                    'senior': 'Retired',
                    'child': 'Child'
                };

                html += `
                    <div class="glass-effect p-6 rounded-xl card-hover cursor-pointer" onclick="showTicketDetail(${ticket.id})">
                        <div class="flex items-start justify-between mb-4">
                            <div class="flex-1">
                                <h3 class="text-xl font-bold text-white mb-1">${movie.title}</h3>
                                <p class="text-purple-300 text-sm">${movie.genre} • ${movie.duration} dk</p>
                            </div>
                            <div class="text-right">
                                <span class="px-3 py-1 rounded-full text-xs font-medium border ${statusColors[ticket.status] || statusColors.sold}">
                                    ${statusLabels[ticket.status] || 'Aktif'}
                                </span>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                            <div>
                                <p class="text-gray-400 text-sm">Sinema & Salon</p>
                                <p class="text-white font-medium">${cinema.name}</p>
                                <p class="text-emerald-400 text-sm">${hall.name}</p>
                            </div>
                            <div>
                                <p class="text-gray-400 text-sm">Seans</p>
                                <p class="text-white font-medium">${showtimeDate.toLocaleDateString('tr-TR')}</p>
                                <p class="text-emerald-400 text-sm">${showtimeDate.toLocaleTimeString('tr-TR', {hour: '2-digit', minute: '2-digit'})}</p>
                            </div>
                            <div>
                                <p class="text-gray-400 text-sm">Koltuk</p>
                                <p class="text-white font-medium">${seat.row}${seat.number}</p>
                                <p class="text-purple-400 text-sm">${customerTypeLabels[ticket.customer_type] || ticket.customer_type}</p>
                            </div>
                        </div>

                        <div class="flex items-center justify-between pt-4 border-t border-white/20">
                            <div>
                                <p class="text-gray-400 text-sm">Satın Alma Tarihi</p>
                                <p class="text-white text-sm">${purchaseDate.toLocaleDateString('tr-TR')} ${purchaseDate.toLocaleTimeString('tr-TR', {hour: '2-digit', minute: '2-digit'})}</p>
                            </div>
                            <div class="text-right">
                                <p class="text-gray-400 text-sm">Fiyat</p>
                                <p class="text-emerald-400 font-bold text-lg">₺${parseFloat(ticket.price).toFixed(2)}</p>
                            </div>
                        </div>
                    </div>
                `;
            });

            container.innerHTML = html;
            showTicketsList();
        }

        function renderPagination() {
            if (totalPages <= 1) return;

            const container = document.getElementById('paginationContainer');
            let html = '<div class="flex items-center space-x-2">';

            // Previous button
            if (currentPage > 1) {
                html += `<button onclick="loadMyTickets(${currentPage - 1})" class="px-3 py-2 bg-white/10 text-white rounded-lg hover:bg-white/20">
                    <i class="fas fa-chevron-left"></i>
                </button>`;
            }

            // Page numbers
            for (let i = 1; i <= totalPages; i++) {
                if (i === currentPage) {
                    html += `<button class="px-3 py-2 bg-emerald-500 text-white rounded-lg">${i}</button>`;
                } else {
                    html += `<button onclick="loadMyTickets(${i})" class="px-3 py-2 bg-white/10 text-white rounded-lg hover:bg-white/20">${i}</button>`;
                }
            }

            // Next button
            if (currentPage < totalPages) {
                html += `<button onclick="loadMyTickets(${currentPage + 1})" class="px-3 py-2 bg-white/10 text-white rounded-lg hover:bg-white/20">
                    <i class="fas fa-chevron-right"></i>
                </button>`;
            }

            html += '</div>';
            container.innerHTML = html;
            document.getElementById('paginationContainer').classList.remove('hidden');
        }

        function showTicketDetail(ticketId) {
            // Simple detail modal - could be expanded
            alert(`Bilet ID: ${ticketId}\n\nDetaylı bilet bilgileri burada gösterilebilir.`);
        }

        function closeTicketModal() {
            document.getElementById('ticketModal').classList.add('hidden');
        }

        function applyFilters() {
            // For now, just reload tickets
            // In a full implementation, you would pass filter parameters to the API
            loadMyTickets(1);
        }

        function showLoading() {
            document.getElementById('loadingState').classList.remove('hidden');
            document.getElementById('emptyState').classList.add('hidden');
            document.getElementById('ticketsList').classList.add('hidden');
            document.getElementById('paginationContainer').classList.add('hidden');
        }

        function hideLoading() {
            document.getElementById('loadingState').classList.add('hidden');
        }

        function showEmptyState() {
            document.getElementById('emptyState').classList.remove('hidden');
            document.getElementById('ticketsList').classList.add('hidden');
            document.getElementById('paginationContainer').classList.add('hidden');
        }

        function showTicketsList() {
            document.getElementById('loadingState').classList.add('hidden');
            document.getElementById('ticketsList').classList.remove('hidden');
            document.getElementById('emptyState').classList.add('hidden');
        }
    </script>
@endsection