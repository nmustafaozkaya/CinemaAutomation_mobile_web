@extends('layout')

@section('content')
    <div class="min-h-screen flex items-center justify-center">
        <div class="max-w-md w-full">
            <!-- Register Card -->
            <div class="glass-effect p-8 rounded-2xl shadow-2xl">
                <div class="text-center mb-8">
                    <div
                        class="w-20 h-20 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-full flex items-center justify-center mx-auto mb-4">
                        <i class="fas fa-user-plus text-white text-2xl"></i>
                    </div>
                    <h2 class="text-3xl font-bold text-white mb-2">Kayıt Ol</h2>
                    <p class="text-gray-300">Yeni hesap oluşturun</p>
                </div>

                <form id="registerForm" class="space-y-6">
                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-user mr-2"></i>Ad Soyad
                        </label>
                        <input type="text" id="name"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all"
                            placeholder="Ad Soyad" required>
                    </div>

                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-envelope mr-2"></i>Email
                        </label>
                        <input type="email" id="email"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all"
                            placeholder="Email" required>
                    </div>

                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-phone mr-2"></i>Telefon
                        </label>
                        <input type="tel" id="phone"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all"
                            placeholder="Telefon">
                    </div>

                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-calendar mr-2"></i>Doğum Tarihi
                        </label>
                        <input type="date" id="birth_date"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all"
                            max="{{ date('Y-m-d', strtotime('-1 day')) }}">
                    </div>

                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-venus-mars mr-2"></i>Cinsiyet
                        </label>
                        <select id="gender"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all">
                            <option value="">Seçiniz</option>
                            <option value="male">Erkek</option>
                            <option value="female">Kadın</option>
                            <option value="other">Diğer</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-lock mr-2"></i>Şifre
                        </label>
                        <input type="password" id="password"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all"
                            placeholder="Şifre" required>
                    </div>

                    <div>
                        <label class="block text-white text-sm font-medium mb-2">
                            <i class="fas fa-lock mr-2"></i>Şifre Tekrar
                        </label>
                        <input type="password" id="password_confirmation"
                            class="w-full px-4 py-3 bg-white/10 border border-white/20 rounded-xl text-white placeholder-gray-300 focus:bg-white/20 focus:border-emerald-400 transition-all"
                            placeholder="Şifre Tekrar" required>
                    </div>

                    <div class="flex items-center">
                        <input type="checkbox" id="terms"
                            class="w-4 h-4 text-emerald-600 bg-transparent border-white/20 rounded focus:ring-emerald-500"
                            required>
                        <label for="terms" class="ml-2 text-sm text-gray-300">
                            <a href="#" class="text-emerald-400 hover:text-emerald-300">Kullanım Koşulları</a>'nı ve
                            <a href="#" class="text-emerald-400 hover:text-emerald-300">Gizlilik Politikası</a>'nı kabul
                            ediyorum
                        </label>
                    </div>

                    <button type="submit"
                        class="w-full bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-600 hover:to-teal-600 text-white py-3 rounded-xl font-semibold transition-all duration-300 transform hover:scale-105">
                        <i class="fas fa-user-plus mr-2"></i>Kayıt Ol
                    </button>
                </form>

                <div id="registerMessage" class="mt-6"></div>

                <div class="mt-8 text-center">
                    <p class="text-gray-400 text-sm">
                        Zaten hesabınız var mı?
                        <a href="/login" class="text-emerald-400 hover:text-emerald-300 font-medium transition-colors">
                            Giriş yapın
                        </a>
                    </p>
                </div>

                <!-- Info Box -->
                <div class="mt-6 p-4 bg-emerald-500/10 rounded-xl border border-emerald-500/20">
                    <h4 class="text-emerald-300 font-medium mb-2 text-center">
                        <i class="fas fa-info-circle mr-2"></i>Kayıt Avantajları
                    </h4>
                    <ul class="text-sm text-emerald-200 space-y-1">
                        <li><i class="fas fa-check mr-2"></i>Bilet satın alma</li>
                        <li><i class="fas fa-check mr-2"></i>Bilet geçmişini görüntüleme</li>
                        <li><i class="fas fa-check mr-2"></i>Hızlı rezervasyon</li>
                        <li><i class="fas fa-check mr-2"></i>Özel kampanyalardan haberdar olma</li>
                    </ul>
                </div>
            </div>

            <!-- Features -->
            <div class="mt-8 grid grid-cols-3 gap-4">
                <div class="glass-effect p-4 rounded-xl text-center">
                    <i class="fas fa-shield-alt text-emerald-400 text-2xl mb-2"></i>
                    <p class="text-white text-sm font-medium">Güvenli</p>
                    <p class="text-gray-400 text-xs">256-bit SSL</p>
                </div>
                <div class="glass-effect p-4 rounded-xl text-center">
                    <i class="fas fa-rocket text-emerald-400 text-2xl mb-2"></i>
                    <p class="text-white text-sm font-medium">Hızlı</p>
                    <p class="text-gray-400 text-xs">Anında kayıt</p>
                </div>
                <div class="glass-effect p-4 rounded-xl text-center">
                    <i class="fas fa-gift text-emerald-400 text-2xl mb-2"></i>
                    <p class="text-white text-sm font-medium">Avantajlı</p>
                    <p class="text-gray-400 text-xs">Özel fırsatlar</p>
                </div>
            </div>
        </div>
    </div>

    <script>
        document.getElementById('registerForm').addEventListener('submit', async function (e) {
            e.preventDefault();

            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            const phone = document.getElementById('phone').value;
            const birthDate = document.getElementById('birth_date').value;
            const gender = document.getElementById('gender').value;
            const password = document.getElementById('password').value;
            const passwordConfirmation = document.getElementById('password_confirmation').value;
            const terms = document.getElementById('terms').checked;

            // Validation
            if (!name || !email || !password || !passwordConfirmation) {
                showMessage('Lütfen zorunlu alanları doldurun!', 'error');
                return;
            }

            if (password.length < 8) {
                showMessage('Şifre en az 8 karakter olmalıdır!', 'error');
                return;
            }

            if (password !== passwordConfirmation) {
                showMessage('Şifreler eşleşmiyor!', 'error');
                return;
            }

            if (!terms) {
                showMessage('Kullanım koşullarını kabul etmelisiniz!', 'error');
                return;
            }

            showLoading();

            try {
                const registerData = {
                    name: name,
                    email: email,
                    password: password,
                    password_confirmation: passwordConfirmation
                };

                // Opsiyonel alanları ekle
                if (phone) registerData.phone = phone;
                if (birthDate) registerData.birth_date = birthDate;
                if (gender) registerData.gender = gender;

                const response = await axios.post('/api/register', registerData);

                hideLoading();

                if (response.data.success) {
                    // Token'ı kaydet
                    localStorage.setItem('token', response.data.data.token);

                    showMessage('Kayıt başarılı! Yönlendiriliyorsunuz...', 'success');

                    // Session login da yap (opsiyonel)
                    setTimeout(async () => {
                        try {
                            await fetch('/login', {
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
                        } catch (sessionError) {
                            console.log('Session login failed, but API token is saved');
                        }

                        window.location.href = '/';
                    }, 1500);
                }

            } catch (error) {
                hideLoading();

                if (error.response?.data?.message) {
                    showMessage(error.response.data.message, 'error');
                } else if (error.response?.data?.errors) {
                    // Laravel validation errors
                    const errors = error.response.data.errors;
                    const firstError = Object.values(errors)[0][0];
                    showMessage(firstError, 'error');
                } else {
                    showMessage('Kayıt sırasında bir hata oluştu!', 'error');
                }
            }
        });

        function showLoading() {
            const button = document.querySelector('button[type="submit"]');
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin mr-2"></i>Kayıt yapılıyor...';
        }

        function hideLoading() {
            const button = document.querySelector('button[type="submit"]');
            button.disabled = false;
            button.innerHTML = '<i class="fas fa-user-plus mr-2"></i>Kayıt Ol';
        }

        function showMessage(message, type) {
            const messageDiv = document.getElementById('registerMessage');
            const bgColor = type === 'success' ? 'bg-emerald-500/20 border-emerald-500/50 text-emerald-300' : 'bg-red-500/20 border-red-500/50 text-red-300';
            const icon = type === 'success' ? 'fas fa-check-circle' : 'fas fa-exclamation-circle';

            messageDiv.innerHTML = `
                    <div class="p-4 rounded-xl border ${bgColor} flex items-center">
                        <i class="${icon} mr-2"></i>
                        <span>${message}</span>
                    </div>
                `;
        }

        // Password strength indicator (opsiyonel)
        document.getElementById('password').addEventListener('input', function () {
            const password = this.value;
            const strength = getPasswordStrength(password);
            // Buraya password strength göstergesi eklenebilir
        });

        function getPasswordStrength(password) {
            let strength = 0;
            if (password.length >= 8) strength++;
            if (password.match(/[a-z]/)) strength++;
            if (password.match(/[A-Z]/)) strength++;
            if (password.match(/[0-9]/)) strength++;
            if (password.match(/[^a-zA-Z0-9]/)) strength++;
            return strength;
        }
    </script>
@endsection