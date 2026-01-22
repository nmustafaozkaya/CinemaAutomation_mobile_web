# SİNEMA UYGULAMASI - MOBİL UYGULAMA TEKNİK DOKÜMANTASYONU

## 1. GENEL BİLGİLER

### 1.1. Proje Özeti
**Proje Adı:** Sinema Otomasyon Sistemi - Mobil Uygulama  
**Platform:** Flutter (Cross-Platform)  
**Versiyon:** 1.0.0+1  
**Geliştirme Ortamı:** Dart SDK ^3.8.1  
**Hedef Platformlar:** Android, iOS, Web, Windows, macOS, Linux

### 1.2. Mimari Yapı
- **Frontend:** Flutter/Dart
- **Backend:** Laravel (PHP) REST API
- **Veritabanı:** MySQL/SQLite
- **Kimlik Doğrulama:** Laravel Sanctum Token Authentication
- **Veri Depolama:** SharedPreferences (Local Storage)

---

## 2. TEKNİK ÖZELLİKLER

### 2.1. Kullanılan Teknolojiler ve Kütüphaneler

#### 2.1.1. Temel Bağımlılıklar
```yaml
flutter: SDK
cupertino_icons: ^1.0.8
flutter_svg: ^2.2.0          # SVG görsel desteği
font_awesome_flutter: ^10.8.0 # Font Awesome ikonları
http: ^1.4.0                  # HTTP istekleri
fluttertoast: ^8.2.12         # Toast mesajları
shared_preferences: ^2.5.3    # Yerel veri depolama
smooth_page_indicator: ^1.2.1 # Sayfa göstergesi
intl: ^0.20.2                 # Tarih/saat formatlama
equatable: ^2.0.7             # Obje karşılaştırma
```

#### 2.1.2. Geliştirme Araçları
- **Flutter SDK:** 3.8.1+
- **Dart SDK:** 3.8.1+
- **Linter:** flutter_lints: ^6.0.0

### 2.2. Proje Yapısı

```
lib/
├── api_connection/          # API bağlantı yönetimi
│   └── api_connection.dart
├── components/              # Yeniden kullanılabilir bileşenler
│   ├── auto_image_slider.dart
│   ├── cinemas.dart
│   ├── cities.dart
│   ├── favorite_button.dart
│   ├── movie_list_section.dart
│   ├── movies.dart
│   ├── mytickets.dart
│   ├── rounded_button.dart
│   ├── rounded_input_field.dart
│   ├── seat.dart
│   ├── showtimes.dart
│   ├── taxes.dart
│   ├── ticket_price.dart
│   ├── user.dart
│   └── user_preferences.dart
├── constant/                # Sabitler ve stiller
│   ├── app_color_style.dart
│   └── app_text_style.dart
├── screens/                 # Uygulama ekranları
│   ├── home.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── movies_screen.dart
│   ├── cinema_screen.dart
│   ├── profile_screen.dart
│   ├── seat_selection_screen.dart
│   ├── payment_screen.dart
│   ├── payment_methods_screen.dart
│   ├── favorite_movies_screen.dart
│   ├── my_ticket_screen.dart
│   └── ... (22 dosya)
└── main.dart                # Uygulama giriş noktası
```

---

## 3. UYGULAMA ÖZELLİKLERİ

### 3.1. Kimlik Doğrulama Sistemi

#### 3.1.1. Giriş (Login)
- **Endpoint:** `POST /api/login`
- **Özellikler:**
  - Email ve şifre ile giriş
  - "Beni Hatırla" (Remember Me) özelliği
  - Token tabanlı kimlik doğrulama
  - Otomatik giriş (token kontrolü)
  - Hata yönetimi ve kullanıcı geri bildirimi

#### 3.1.2. Kayıt (Register)
- **Endpoint:** `POST /api/register`
- **Gerekli Bilgiler:**
  - İsim, Email, Şifre
  - Telefon (opsiyonel)
  - Doğum tarihi (opsiyonel)
  - Cinsiyet (opsiyonel)

#### 3.1.3. Token Yönetimi
- **Depolama:** SharedPreferences
- **Token Saklama:** `UserPreferences.saveToken()`
- **Token Okuma:** `UserPreferences.getToken()`
- **Token Silme:** `UserPreferences.removeToken()`
- **Otomatik Yenileme:** API yanıtlarına göre

### 3.2. Ana Ekran (Home Screen)

#### 3.2.1. Özellikler
- **Otomatik Görsel Slider:** Promosyon görselleri
- **Vizyondaki Filmler:** Aktif film listesi
- **Yakında Gelecek Filmler:** Gelecek film listesi
- **Promosyonlar:** Özel kampanyalar
- **Drawer Menü:** Yan menü navigasyonu

#### 3.2.2. Navigasyon
- **Alt Menü (Bottom Navigation):**
  1. Home (Ana Sayfa)
  2. Movies (Filmler)
  3. Halls (Salonlar)
  4. Profile (Profil)

### 3.3. Film Yönetimi

#### 3.3.1. Film Listesi
- **Endpoint:** `GET /api/movies`
- **Özellikler:**
  - Vizyondaki filmler
  - Yakında gelecek filmler (`/api/future-movies`)
  - Dağıtılan filmler (`/api/movies/distributed`)
  - Film detayları
  - Favori film ekleme/çıkarma

#### 3.3.2. Film Detayları
- Film bilgileri
- Fragman/video desteği
- Seans saatleri
- Favori butonu

#### 3.3.3. Favori Filmler
- **Endpoint:** `POST /api/favorite-movies/toggle`
- **Özellikler:**
  - Film favorilere ekleme/çıkarma
  - Favori film listesi görüntüleme
  - Web ve mobil senkronizasyonu
  - Kalp ikonu ile görsel geri bildirim

### 3.4. Sinema ve Salon Yönetimi

#### 3.4.1. Şehir Seçimi
- **Endpoint:** `GET /api/cities`
- Dinamik şehir listesi
- Şehir bazlı filtreleme

#### 3.4.2. Sinema Listesi
- **Endpoint:** `GET /api/cinemas?city_id={id}`
- Şehre göre sinema listesi
- Sinema detayları

#### 3.4.3. Salon Bilgileri
- **Endpoint:** `GET /api/halls`
- Salon kapasitesi
- Koltuk düzeni

### 3.5. Seans ve Bilet Sistemi

#### 3.5.1. Seans Yönetimi
- **Endpoint:** `GET /api/showtimes`
- Film ve sinema bazlı seans listesi
- Tarih ve saat filtreleme
- Müsaitlik kontrolü

#### 3.5.2. Koltuk Seçimi
- **Endpoint:** `GET /api/showtimes/{id}/available-seats`
- **Rezervasyon:** `POST /api/showtimes/{id}/reserve`
- **Serbest Bırakma:** `POST /api/seats/{id}/release`

**Koltuk Durumları:**
- **Available (Müsait):** Yeşil renk (#10b981)
- **Occupied (Dolu):** Gri renk (#cbcbcb)
- **Pending (Rezerve):** Kırmızı renk (#ff4061)
- **Selected (Seçili):** Sarı renk (#f8e71c)

**Özellikler:**
- Gerçek zamanlı koltuk durumu güncellemesi (10 saniye)
- Otomatik rezervasyon serbest bırakma
- Çoklu koltuk seçimi
- Koltuk haritası görselleştirme

#### 3.5.3. Bilet Tipleri ve Fiyatlandırma
- **Endpoint:** `GET /api/tickets/prices/{showtimeId}`
- **Bilet Tipleri:**
  - Adult (Tam): %0 indirim
  - Student (Öğrenci): %20 indirim
  - Senior (Emekli): %15 indirim
  - Child (Çocuk): %25 indirim

**Fiyat Hesaplama:**
- Temel fiyat + Bilet tipi indirimi
- Vergi hesaplama
- Toplam tutar

#### 3.5.4. Bilet Satın Alma
- **Endpoint:** `POST /api/tickets`
- **İşlem Akışı:**
  1. Koltuk seçimi
  2. Bilet tipi seçimi
  3. Ödeme yöntemi seçimi
  4. Bilet satın alma
  5. QR kod oluşturma

**Özellikler:**
- İlk alışveriş %30 indirim (mobil platform)
- Çoklu bilet satın alma
- Bilet durumu takibi

### 3.6. Ödeme Sistemi

#### 3.6.1. Ödeme Yöntemleri
- **Endpoint:** `GET /api/payment-methods`
- **CRUD İşlemleri:**
  - Ekleme: `POST /api/payment-methods`
  - Güncelleme: `PUT /api/payment-methods/{id}`
  - Silme: `DELETE /api/payment-methods/{id}`
  - Varsayılan ayarlama: `POST /api/payment-methods/{id}/set-default`

**Özellikler:**
- Kredi kartı kaydetme
- Kayıtlı kartları görüntüleme
- Varsayılan kart belirleme
- Kart numarası formatlama (4'lü gruplar)
- CVV ve son kullanma tarihi yönetimi

#### 3.6.2. Ödeme Ekranı
- Kayıtlı kartların listelenmesi
- Yeni kart ekleme
- Ödeme işlemi tamamlama
- Hata yönetimi

### 3.7. Profil Yönetimi

#### 3.7.1. Kullanıcı Profili
- **Endpoint:** `GET /api/me`
- **Güncelleme:** `PUT /api/profile`
- **Özellikler:**
  - Profil bilgileri görüntüleme
  - Profil düzenleme
  - Şifre değiştirme (`POST /api/change-password`)
  - Avatar yönetimi

#### 3.7.2. Biletlerim
- **Endpoint:** `GET /api/my-tickets`
- **Özellikler:**
  - Aktif biletler
  - Geçmiş biletler
  - Bilet detayları
  - QR kod görüntüleme
  - Bilet iptal etme

#### 3.7.3. Çıkış (Logout)
- **Endpoint:** `POST /api/logout`
- Token temizleme
- Kullanıcı verilerini silme (Remember Me durumuna göre)

---

## 4. API BAĞLANTI YÖNETİMİ

### 4.1. API Connection Sınıfı

**Dosya:** `lib/api_connection/api_connection.dart`

#### 4.1.1. Yapılandırma
```dart
static const bool isProduction = true;
static const String productionUrl = 'https://nmustafaozkaya.com.tr/api';
static const String localUrl = 'http://10.0.2.2:8000/api';
static const hostConnection = isProduction ? productionUrl : localUrl;
```

#### 4.1.2. Endpoint'ler

**Kimlik Doğrulama:**
- `signUp`: `/api/register`
- `login`: `/api/login`

**Filmler:**
- `movies`: `/api/movies`
- `futureMovies`: `/api/future-movies`
- `distributedMovies`: `/api/movies/distributed`

**Seanslar:**
- `showtimes`: `/api/showtimes`
- `getAvailableSeatsUrl(showtimeId)`: `/api/showtimes/{id}/available-seats`
- `getTicketPricesUrl(showtimeId)`: `/api/tickets/prices/{id}`

**Koltuk İşlemleri:**
- `reserveSeatUrl(showtimeId)`: `/api/showtimes/{id}/reserve`
- `releaseSeatUrl(seatId)`: `/api/seats/{id}/release`

**Biletler:**
- `buyTicket`: `/api/tickets`
- `myTickets`: `/api/my-tickets`
- `updateTicketUrl(ticketId)`: `/api/tickets/{id}`
- `deleteTicketUrl(ticketId)`: `/api/tickets/{id}`

**Ödeme Yöntemleri:**
- `paymentMethods`: `/api/payment-methods`
- `addPaymentMethod`: `/api/payment-methods`
- `updatePaymentMethodUrl(id)`: `/api/payment-methods/{id}`
- `deletePaymentMethodUrl(id)`: `/api/payment-methods/{id}`
- `setDefaultPaymentMethodUrl(id)`: `/api/payment-methods/{id}/set-default`

**Favori Filmler:**
- `favoriteMovies`: `/api/favorite-movies`
- `toggleFavoriteMovie`: `/api/favorite-movies/toggle`
- `checkFavoriteMovieUrl(movieId)`: `/api/favorite-movies/{id}/check`
- `removeFavoriteMovieUrl(movieId)`: `/api/favorite-movies/{id}`

### 4.2. HTTP İstek Yönetimi

#### 4.2.1. Header Yapılandırması
```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
  'Accept': 'application/json',
}
```

#### 4.2.2. Hata Yönetimi
- 401 Unauthorized: Token yenileme veya yeniden giriş
- 400 Bad Request: Validasyon hataları
- 500 Server Error: Sunucu hataları
- Network Error: İnternet bağlantı hataları

---

## 5. VERİ YÖNETİMİ

### 5.1. Local Storage (SharedPreferences)

#### 5.1.1. UserPreferences Sınıfı
**Dosya:** `lib/components/user_preferences.dart`

**Fonksiyonlar:**
- `saveData(User user)`: Kullanıcı bilgilerini kaydet
- `readData()`: Kullanıcı bilgilerini oku
- `removeData()`: Tüm kullanıcı verilerini sil
- `saveToken(String token)`: Token kaydet
- `getToken()`: Token oku
- `removeToken()`: Token sil
- `setRememberMe(bool value)`: "Beni Hatırla" ayarla
- `getRememberMe()`: "Beni Hatırla" durumunu oku

#### 5.1.2. Veri Modelleri

**User Model:**
```dart
class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? birthDate;
  final String? gender;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? cinemaId;
  final int roleId;
  final bool isActive;
  final Role? role;
  final dynamic cinema;
}
```

**Role Model:**
```dart
class Role {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### 5.2. State Management

#### 5.2.1. StatefulWidget Kullanımı
- Tüm ekranlar StatefulWidget olarak yapılandırılmış
- `setState()` ile durum güncellemeleri
- `mounted` kontrolü ile güvenli state güncellemeleri

#### 5.2.2. Async İşlemler
- `Future` ve `async/await` kullanımı
- Loading state yönetimi
- Error handling

---

## 6. KULLANICI ARAYÜZÜ (UI)

### 6.1. Tasarım Sistemi

#### 6.1.1. Renk Paleti
**Dosya:** `lib/constant/app_color_style.dart`

```dart
scaffoldBackground: #0D1B2A  // Ana arka plan
appBarColor: #1B263B          // AppBar rengi
primaryAccent: #415A77        // Vurgu rengi
secondaryAccent: #778DA9      // İkincil vurgu
textPrimary: #E0E1DD          // Ana metin
textSecondary: #A8B5C3        // İkincil metin
errorColor: #FF0000           // Hata rengi
```

#### 6.1.2. Tipografi
- **Font Ailesi:** Poppins
- **Varyantlar:**
  - Regular
  - Bold (700)
  - Italic

### 6.2. Bileşenler

#### 6.2.1. Özel Widget'lar
- `RoundedButton`: Yuvarlatılmış buton
- `RoundedInputField`: Yuvarlatılmış input alanı
- `AutoImageSlider`: Otomatik görsel slider
- `FavoriteButton`: Favori butonu
- `MovieListSection`: Film listesi bölümü

#### 6.2.2. Navigasyon
- Bottom Navigation Bar
- Drawer Menu
- AppBar Navigation

---

## 7. GÜVENLİK

### 7.1. Kimlik Doğrulama
- Laravel Sanctum token tabanlı kimlik doğrulama
- Token otomatik yenileme mekanizması
- Güvenli token depolama (SharedPreferences)

### 7.2. Veri Güvenliği
- HTTPS bağlantıları (Production)
- Token şifreleme
- Hassas verilerin güvenli depolanması

### 7.3. Hata Yönetimi
- Kullanıcıya hassas bilgi göstermeme
- Güvenli hata mesajları
- Log yönetimi

---

## 8. PLATFORM ÖZELLİKLERİ

### 8.1. Android
- **Min SDK:** Flutter default
- **Target SDK:** Flutter default
- **NDK Version:** 27.0.12077973
- **Kotlin:** JVM Target 11
- **Java:** Version 11

### 8.2. iOS
- Xcode proje yapılandırması
- Podfile yönetimi
- Info.plist ayarları

### 8.3. Web
- Responsive tasarım
- PWA desteği
- Browser uyumluluğu

---

## 9. PERFORMANS OPTİMİZASYONU

### 9.1. Görsel Optimizasyonu
- Asset yönetimi
- Lazy loading
- Image caching

### 9.2. Network Optimizasyonu
- API response caching
- Request batching
- Error retry mekanizması

### 9.3. Memory Management
- Widget lifecycle yönetimi
- Controller dispose
- Timer cleanup

---

## 10. HATA AYIKLAMA VE TEST

### 10.1. Debug Modu
- `debugShowCheckedModeBanner: false`
- Console logging
- Error tracking

### 10.2. Linter Kuralları
- `flutter_lints: ^6.0.0`
- `analysis_options.yaml` yapılandırması
- Code quality kontrolleri

---

## 11. DEPLOYMENT

### 11.1. Build Yapılandırması
- **Release Build:** Optimize edilmiş build
- **Debug Build:** Geliştirme build'i

### 11.2. Platform Build Komutları
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

---

## 12. BİLİNEN ÖZELLİKLER VE KISITLAMALAR

### 12.1. Özellikler
- ✅ Çoklu platform desteği
- ✅ Offline veri depolama
- ✅ Gerçek zamanlı koltuk güncellemesi
- ✅ Favori film senkronizasyonu
- ✅ Kayıtlı ödeme yöntemleri
- ✅ QR kod oluşturma
- ✅ İlk alışveriş indirimi

### 12.2. Kısıtlamalar
- İnternet bağlantısı gereklidir (API bağımlılığı)
- Token süresi dolduğunda yeniden giriş gerekir
- Offline mod desteği yoktur

---

## 13. GELECEK GELİŞTİRMELER

### 13.1. Önerilen Özellikler
- Push notification desteği
- Offline mod
- Dark/Light theme toggle
- Çoklu dil desteği
- Biometric authentication
- Social media login

---

## 14. İLETİŞİM VE DESTEK

### 14.1. Teknik Destek
- Proje repository: GitHub
- API Endpoint: https://nmustafaozkaya.com.tr/api

### 14.2. Dokümantasyon
- API dokümantasyonu: Laravel API routes
- Kod yorumları: Inline comments

---

## 15. SÜRÜM GEÇMİŞİ

### Version 1.0.0+1
- İlk stabil sürüm
- Temel özellikler
- Multi-platform desteği
- API entegrasyonu
- Kullanıcı yönetimi
- Bilet satın alma sistemi
- Ödeme yöntemleri
- Favori filmler

---

**Dokümantasyon Tarihi:** 2025  
**Son Güncelleme:** 2025  
**Hazırlayan:** Teknik Ekip
