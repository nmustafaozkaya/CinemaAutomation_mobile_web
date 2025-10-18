@extends('layout')

@section('content')
    @auth
        @if(auth()->user()->isCustomer())
            <!-- CUSTOMER DASHBOARD -->
            <div class="text-center mb-12">
                <div class="floating-animation inline-block mb-6">
                    <div
                        class="w-20 h-20 bg-gradient-to-r from-blue-500 to-green-500 rounded-full flex items-center justify-center mx-auto">
                        <i class="fas fa-user text-white text-3xl"></i>
                    </div>
                </div>
                <h1
                    class="text-5xl font-bold text-white mb-4 bg-gradient-to-r from-blue-400 to-green-400 bg-clip-text text-transparent">
                    Hoş Geldiniz, {{ auth()->user()->name }}!
                </h1>
                <p class="text-xl text-gray-300 max-w-2xl mx-auto">
                    Vizyondaki filmleri keşfedin ve biletinizi hemen alın
                </p>
            </div>

            <!-- Customer Quick Actions -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="glass-effect p-8 rounded-2xl text-center card-hover">
                    <div
                        class="w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-play text-white text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-4">Vizyondaki Filmler</h3>
                    <p class="text-gray-300 mb-6">En yeni filmleri keşfedin ve seansları görün</p>
                    <a href="/movies"
                        class="w-full inline-block bg-gradient-to-r from-blue-500 to-purple-600 text-white py-3 px-6 rounded-xl font-semibold hover:from-blue-600 hover:to-purple-700 transition-all duration-300">
                        Filmleri İncele
                    </a>
                </div>

                <div class="glass-effect p-8 rounded-2xl text-center card-hover">
                    <div
                        class="w-16 h-16 bg-gradient-to-r from-emerald-500 to-teal-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-ticket-alt text-white text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-4">Bilet Al</h3>
                    <p class="text-gray-300 mb-6">Hızlı ve kolay bilet alma deneyimi</p>
                    <a href="/buy-tickets"
                        class="w-full inline-block bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-3 px-6 rounded-xl font-semibold hover:from-emerald-600 hover:to-teal-700 transition-all duration-300">
                        Bilet Al
                    </a>
                </div>
            </div>

        @else
            <!-- ADMIN DASHBOARD -->
            <div class="text-center mb-12">
                <div class="floating-animation inline-block mb-6">
                    <div
                        class="w-20 h-20 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center mx-auto">
                        <i class="fas fa-cog text-white text-3xl"></i>
                    </div>
                </div>
                <h1
                    class="text-5xl font-bold text-white mb-4 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
                    Yönetim Paneli
                </h1>
                <p class="text-xl text-gray-300 max-w-2xl mx-auto">
                    Sinema operasyonlarınızı yönetin ve raporlarınızı görüntüleyin
                </p>
            </div>

            <!-- Stats Cards -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
                <div class="stat-card p-6 rounded-2xl text-center card-hover">
                    <div
                        class="w-12 h-12 bg-gradient-to-r from-blue-500 to-blue-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-film text-white text-xl"></i>
                    </div>
                    <div class="text-3xl font-bold text-gray-800 mb-2">50</div>
                    <div class="text-gray-600 font-medium">Aktif Filmler</div>
                </div>

                <div class="stat-card p-6 rounded-2xl text-center card-hover">
                    <div
                        class="w-12 h-12 bg-gradient-to-r from-emerald-500 to-emerald-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-building text-white text-xl"></i>
                    </div>
                    <div class="text-3xl font-bold text-gray-800 mb-2">10</div>
                    <div class="text-gray-600 font-medium">Sinema Salonları</div>
                </div>

                <div class="stat-card p-6 rounded-2xl text-center card-hover">
                    <div
                        class="w-12 h-12 bg-gradient-to-r from-purple-500 to-purple-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-clock text-white text-xl"></i>
                    </div>
                    <div class="text-3xl font-bold text-gray-800 mb-2">150</div>
                    <div class="text-gray-600 font-medium">Günlük Seanslar</div>
                </div>

                <div class="stat-card p-6 rounded-2xl text-center card-hover">
                    <div
                        class="w-12 h-12 bg-gradient-to-r from-pink-500 to-pink-600 rounded-lg flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-ticket-alt text-white text-xl"></i>
                    </div>
                    <div class="text-3xl font-bold text-gray-800 mb-2">247</div>
                    <div class="text-gray-600 font-medium">Satılan Biletler</div>
                </div>
            </div>

            <!-- Admin Quick Actions -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="glass-effect p-8 rounded-2xl text-center card-hover">
                    <div
                        class="w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-play text-white text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-4">Film Listesi</h3>
                    <p class="text-gray-300 mb-6">Vizyondaki tüm filmleri keşfedin</p>
                    <a href="/movies"
                        class="w-full inline-block bg-gradient-to-r from-blue-500 to-purple-600 text-white py-3 px-6 rounded-xl font-semibold hover:from-blue-600 hover:to-purple-700 transition-all duration-300">
                        Filmleri Görüntüle
                    </a>
                </div>

                <div class="glass-effect p-8 rounded-2xl text-center card-hover">
                    <div
                        class="w-16 h-16 bg-gradient-to-r from-emerald-500 to-teal-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-ticket-alt text-white text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-4">Bilet Satış</h3>
                    <p class="text-gray-300 mb-6">Hızlı ve kolay bilet satışı yapın</p>
                    <a href="/tickets"
                        class="w-full inline-block bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-3 px-6 rounded-xl font-semibold hover:from-emerald-600 hover:to-teal-700 transition-all duration-300">
                        Bilet Sat
                    </a>
                </div>

                <div class="glass-effect p-8 rounded-2xl text-center card-hover">
                    <div
                        class="w-16 h-16 bg-gradient-to-r from-pink-500 to-rose-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-cog text-white text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-4">Yönetim Paneli</h3>
                    <p class="text-gray-300 mb-6">Sistem yönetimi ve raporlar</p>
                    <a href="/admin"
                        class="w-full inline-block bg-gradient-to-r from-pink-500 to-rose-600 text-white py-3 px-6 rounded-xl font-semibold hover:from-pink-600 hover:to-rose-700 transition-all duration-300">
                        Yönetim Paneli
                    </a>
                </div>
            </div>
        @endif
    @else
            <!-- MISAFIR DASHBOARD -->
            <div class="text-center mb-12">
                <div class="floating-animation inline-block mb-6">
                    <div
                        class="w-20 h-20 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center mx-auto">
                        <i class="fas fa-film text-white text-3xl"></i>
                    </div>
                </div>
                <h1
                    class="text-5xl font-bold text-white mb-4 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
                    CinemaMax'e Hoş Geldiniz
                </h1>
                <p class="text-xl text-gray-300 max-w-2xl mx-auto">
                    En yeni filmler, konforlu koltuklar ve dijital ses sistemi ile unutulmaz bir sinema deneyimi yaşayın
                </p>
            </div>

            <!-- Guest Actions -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="glass-effect p-8 rounded-2xl text-center card-hover">
                    <div
                        class="w-16 h-16 bg-gradient-to-r from-blue-500 to-purple-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-play text-white text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-4">Vizyondaki Filmler</h3>
                    <p class="text-gray-300 mb-6">Vizyondaki tüm filmleri keşfedin</p>
                    <a href="/movies"
                        class="w-full inline-block bg-gradient-to-r from-blue-500 to-purple-600 text-white py-3 px-6 rounded-xl font-semibold hover:from-blue-600 hover:to-purple-700 transition-all duration-300">
                        Filmleri Görüntüle
                    </a>
                </div>

                <div class="glass-effect p-8 rounded-2xl text-center card-hover">
                    <div
                        class="w-16 h-16 bg-gradient-to-r from-emerald-500 to-teal-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
                        <i class="fas fa-sign-in-alt text-white text-2xl"></i>
                    </div>
                    <h3 class="text-xl font-bold text-white mb-4">Giriş Yap</h3>
                    <p class="text-gray-300 mb-6">Bilet almak için giriş yapın</p>
                    <a href="/login"
                        class="w-full inline-block bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-3 px-6 rounded-xl font-semibold hover:from-emerald-600 hover:to-teal-700 transition-all duration-300">
                        Giriş Yap
                    </a>
                </div>
            </div>
        @endauth
@endsection