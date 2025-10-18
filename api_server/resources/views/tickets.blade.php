@extends('layout')

@section('content')
    <div>
        <div class="glass-effect p-8 rounded-2xl">
            <!-- Header -->
            <div class="flex items-center justify-between mb-8">
                <h2 class="text-3xl font-bold text-white flex items-center">
                    <i class="fas fa-ticket-alt mr-3 text-emerald-400"></i>
                    Bilet Al
                </h2>
                <a href="/" class="bg-gray-600 hover:bg-gray-700 text-white px-4 py-2 rounded-lg transition-colors">
                    <i class="fas fa-arrow-left mr-2"></i>Geri
                </a>
            </div>
            <div>
                <!-- Include All Components -->
                @include('components.ticket-steps')
                @include('components.movie-selection')
                @include('components.cinema-selection')
                @include('components.seat-map')
                @include('components.payment-form')
            </div>

        </div>
    </div>

    <!-- Main Ticket Booking JavaScript -->
    <script>

        // Global variables
        let selectedMovie = null;
        let selectedCinema = null;
        let selectedShowtime = null;
        let currentTicketStep = 1;

        // Initialize when DOM is ready
        document.addEventListener('DOMContentLoaded', function () {
            // Initialize with movie selection
            updateTicketSteps();

            // Load movies automatically
            if (window.movieSelection) {
                window.movieSelection.loadMovies();
            }
        });

        // Step navigation functions
        function goBackToStep(stepNumber) {
            // Hide all steps
            document.querySelectorAll('.ticket-step').forEach(step => {
                step.classList.add('hidden');
            });

            // Show target step
            document.getElementById(`ticketStep${stepNumber}`).classList.remove('hidden');
            currentTicketStep = stepNumber;
            updateTicketSteps();

            // ✅ SADECE GERİYE DOĞRU GİDİLİRKEN RESET YAP
            // Koltuk seçiminden geri dönülürken koltukları korumak için resetDataForStep'i çağırma
            if (stepNumber < 4) {
                resetDataForStep(stepNumber);
            }
                }
                function goToNextStep(stepNumber) {
                    // Hide all steps
                    document.querySelectorAll('.ticket-step').forEach(step => {
                        step.classList.add('hidden');
                    });

                    // Show target step
                    document.getElementById(`ticketStep${stepNumber}`).classList.remove('hidden');
                    currentTicketStep = stepNumber;
                    updateTicketSteps();

                    // İleri giderken reset yapma, koltukları koru
                }

        function resetDataForStep(stepNumber) {
            if (stepNumber === 1) {
                selectedMovie = null;
                selectedCinema = null;
                selectedShowtime = null;
                if (window.seatMap) {
                    window.seatMap.forceReset();
                }
                if (window.paymentForm) window.paymentForm.reset();
            } else if (stepNumber === 2) {
                selectedCinema = null;
                selectedShowtime = null;
                if (window.seatMap) {
                    window.seatMap.forceReset();
                }
                if (window.paymentForm) window.paymentForm.reset();
            } else if (stepNumber === 3) {
                selectedShowtime = null;
                if (window.seatMap) {
                    window.seatMap.forceReset();
                }
                if (window.paymentForm) window.paymentForm.reset();
            } else if (stepNumber === 5) {
                if (window.paymentForm) window.paymentForm.reset();
            }
        }

        // Update step indicators
        function updateTicketSteps() {
            // Hide all steps
            for (let i = 1; i <= 6; i++) {
                const stepElement = document.getElementById(`ticketStep${i}`);
                if (stepElement) {
                    stepElement.classList.add('hidden');
                }
            }

            // Show current step
            const currentStepElement = document.getElementById(`ticketStep${currentTicketStep}`);
            if (currentStepElement) {
                currentStepElement.classList.remove('hidden');
            }

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


                    if (stepNumber === currentTicketStep) {
                        item.classList.add('active');
                    } else {
                        item.classList.remove('active');
                    }
                } else {
                    circle.classList.remove('bg-emerald-500');
                    circle.classList.add('bg-gray-600');
                    text.classList.remove('text-white');
                    text.classList.add('text-gray-400');
                    item.classList.remove('active');
                }
            });

            setTimeout(() => {
                document.querySelector('.step-item.active')?.scrollIntoView({
                    behavior: 'smooth',
                    inline: 'center'
                });
            }, 10);
        }

        // Global selection functions (called by components)
        async function selectMovieForTicket(movieId, movieTitle) {
            selectedMovie = { id: movieId, title: movieTitle };
            currentTicketStep = 2;
            updateTicketSteps();

            if (window.cinemaSelection) {
                window.cinemaSelection.showSelectedMovie(selectedMovie);
                await window.cinemaSelection.loadCinemas();
            }
        }

        async function selectCinemaForTicket(cinemaId, cinemaName, cinemaAddress) {
            selectedCinema = { id: cinemaId, name: cinemaName, address: cinemaAddress };
            currentTicketStep = 3;
            updateTicketSteps();

            // Selected movie & cinema info
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

            // Load showtimes
            try {
                const response = await axios.get(`/api/showtimes?movie_id=${selectedMovie.id}&cinema_id=${cinemaId}`);
                const showtimes = response.data.data.data || response.data.data;
                renderShowtimes(showtimes);
            } catch (error) {
                console.error('Seanslar yüklenemedi:', error);
                renderMockShowtimes();
            }
        }
        function renderShowtimes(showtimes) {
            const showtimeGrid = document.getElementById('showtimeGrid');
            let html = '';

            showtimes.forEach(showtime => {
                const startTime = new Date(showtime.start_time);
                html += `
                                                                                    <div class="glass-effect rounded-xl p-4 card-hover cursor-pointer"
                                                                                         onclick="selectShowtimeForTicket(${showtime.id}, '${startTime.toLocaleString('tr-TR')}', '${showtime.hall.name}', ${showtime.price || 45})">
                                                                                        <h4 class="text-lg font-semibold text-white mb-2">${showtime.hall.name}</h4>
                                                                                        <p class="text-emerald-400 font-bold text-lg">${startTime.toLocaleString('tr-TR')}</p>
                                                                                        <p class="text-purple-300 text-sm mt-1">₺${showtime.price || 45}/kişi</p>
                                                                                    </div>
                                                                                `;
            });

            showtimeGrid.innerHTML = html;
        }

        function renderMockShowtimes() {
            const mockShowtimes = [
                { id: 1, hall: { name: "Salon 1" }, start_time: "2025-07-09T14:00:00", price: 45 },
                { id: 2, hall: { name: "Salon 2" }, start_time: "2025-07-09T17:00:00", price: 50 },
                { id: 3, hall: { name: "Salon 1" }, start_time: "2025-07-09T20:00:00", price: 55 }
            ];
            renderShowtimes(mockShowtimes);
        }

        async function selectShowtimeForTicket(showtimeId, startTime, hallName, price) {
            selectedShowtime = { id: showtimeId, startTime: startTime, hall: hallName, price: price };
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

            // Load seats
            if (window.seatMap) {
                window.seatMap.setShowtime(selectedShowtime);
                await window.seatMap.loadSeats(showtimeId);
            }
        }

        // Navigation functions called by components
        function goToTicketTypes() {
            // ✅ Koltukları kontrol et
            if (!window.seatMap || window.seatMap.selectedSeats.length === 0) {
                alert('Lütfen önce koltuk seçimi yapın!');
                return;
            }

            // ✅ goToNextStep kullan, resetDataForStep çağırma
            goToNextStep(5);

            if (window.paymentForm) {
                window.paymentForm.loadTicketTypes(selectedShowtime.id);
            }
        }

        function goToPayment() {
            // ✅ goToNextStep kullan
            goToNextStep(6);

            if (window.paymentForm) {
                window.paymentForm.generateOrderSummary();
            }
        }

        function completeSale() {
            if (window.paymentForm) {
                window.paymentForm.processPayment();
            }
        }

        // Smart back navigation
        function smartGoBack() {
            if (currentTicketStep > 1) {
                goBackToStep(currentTicketStep - 1);
            } else {
                window.location.href = '/';
            }
        }

        // Keyboard navigation
        document.addEventListener('keydown', function (event) {
            if (event.key === 'Escape') {
                smartGoBack();
            }
        });

        // Progress indicator click handlers
        document.addEventListener('DOMContentLoaded', function () {
            const stepItems = document.querySelectorAll('.step-item');
            stepItems.forEach((item, index) => {
                item.addEventListener('click', function () {
                    const targetStep = index + 1;

                    // Only allow going back or staying on current step
                    if (targetStep <= currentTicketStep) {
                        goBackToStep(targetStep);
                    }
                });
            });
        });
    </script>
@endsection