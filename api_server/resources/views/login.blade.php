@extends('layout')

@section('content')
    <div class="min-h-screen flex items-center justify-center">
        <div class="max-w-md w-full">
            <!-- Login Card -->
            <div class="glass-effect p-8 rounded-2xl shadow-2xl">
                <div class="text-center mb-8">
                    <div
                        class="w-20 h-20 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-sign-in-alt text-white text-2xl"></i>
                    </div>
                    <h2 class="text-3xl font-bold text-white mb-2">Hoş Geldiniz</h2>
                    <p class="text-gray-300">Hesabınıza giriş yapın</p>
                </div>

                <form id="loginForm" class="space-y-6">
                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-envelope mr-2"></i>Email
                        </label>
                        <input type="email" id="email" value="admin@cinema.com"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-purple-400 transition-all"
                            placeholder="Email adresinizi girin">
                    </div>

                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-lock mr-2"></i>Şifre
                        </label>
                        <input type="password" id="password" value="password"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-purple-400 transition-all"
                            placeholder="Şifrenizi girin">
                    </div>

                    <div class="flex items-center justify-between">
                        <label class="flex items-center">
                            <input type="checkbox" class="w-4 h-4 text-purple-600 bg-transparent border-white/20 rounded focus:ring-purple-500">
                            <span class="ml-2 text-sm text-gray-300">Beni hatırla</span>
                            </label>
                            <a href="#" class="text-sm text-purple-400 hover:text-purple-300 transition-colors">
                                Şifremi unuttum
                            </a>
                            </div>

                    <button type="submit"
                        class="w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white py-3 rounded-xl font-semibold transition-all duration-300 transform hover:scale-105">
                        <i class="fas fa-sign-in-alt mr-2"></i>Giriş Yap
                    </button>
                    </form>

                <div id="loginMessage" class="mt-6"></div>

                <div class="mt-8 text-center">
                    <p class="text-gray-400 text-sm">
                        Hesabınız yok mu?
                        <a href="{{ route('register') }}" class="text-purple-400 hover:text-purple-300 font-medium transition-colors">
                            Kayıt olun
                        </a>
                    </p>
                </div>
            </div>

            <!-- Features -->
            <div class="mt-8 grid grid-cols-3 gap-4">
                <div class="glass-effect p-4 rounded-xl text-center">
                    <i class="fas fa-shield-alt text-purple-400 text-2xl mb-2"></i>
                    <p class="text-white text-sm font-medium">Güvenli</p>
                    <p class="text-gray-400 text-xs">256-bit SSL</p>
                </div>
                <div class="glass-effect p-4 rounded-xl text-center">
                    <i class="fas fa-bolt text-purple-400 text-2xl mb-2"></i>
                    <p class="text-white text-sm font-medium">Hızlı</p>
                    <p class="text-gray-400 text-xs">Anında giriş</p>
                </div>
                <div class="glass-effect p-4 rounded-xl text-center">
                    <i class="fas fa-mobile-alt text-purple-400 text-2xl mb-2"></i>
                    <p class="text-white text-sm font-medium">Mobil</p>
                    <p class="text-gray-400 text-xs">Tüm cihazlar</p>
                </div>
            </div>
            </div>
            </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', async function (e) {
            e.preventDefault();

            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            if (!email || !password) {
                showMessage('Lütfen email ve şifre alanlarını doldurun!', 'error');
                return;
            }

            showLoading();

            try {
                //  1. API login yap ve token al
                const apiResponse = await axios.post('/api/login', {
                    email: email,
                    password: password
                });

                if (apiResponse.data.success) {
                    // 2. Token'ı kaydet
                    localStorage.setItem('token', apiResponse.data.data.token);

                    // 3. Laravel session login da yap
                    const sessionResponse = await fetch('/login', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || '',
                            'Accept': 'application/json'
                        },
                        body: JSON.stringify({
                            email: email,
                            password: password
                        })
                    });

                    hideLoading();

                    console.log('Token saved:', localStorage.getItem('token'));
                    showMessage('Giriş başarılı! Yönlendiriliyorsunuz...', 'success');

                    setTimeout(() => {
                        window.location.href = '/';
                    }, 1000);
                }
            } catch (error) {
                hideLoading();
                console.error('Login error:', error);
                showMessage('Giriş başarısız! Email veya şifre hatalı.', 'error');
            }
        });


            function showLoading() {
                const button = document.querySelector('button[type="submit"]');
                button.disabled = true;
                button.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Giriş yapılıyor...';
            }

            function hideLoading() {
                const button = document.querySelector('button[type="submit"]');
                button.disabled = false;
                button.innerHTML = '<i class="fas fa-sign-in-alt mr-2"></i>Giriş Yap';
            }

            function showMessage(message, type) {
                const messageDiv = document.getElementById('loginMessage');
            const bgColor = type === 'success' ? 'bg-emerald-500/20 border-emerald-500/50 text-emerald-300' : 'bg-red-500/20 border-red-500/50 text-red-300';
            const icon = type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle';

                    messageDiv.innerHTML = `
                                                            <div class="p-4 rounded-xl border ${bgColor} flex items-center">
                                                                <i class="${icon} mr-2"></i>
                                                                <span>${message}</span>
                                                            </div>
                                                        `;
                }
            </script>


@endsection