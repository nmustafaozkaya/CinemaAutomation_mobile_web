# 🎬 Sinema Uygulaması (Cinema Automation System)

Modern cinema management and automation platform built with **Flutter** (mobile) and **Laravel** (backend API).

## ✨ Features

### 🎬 Film Yönetimi (Movie Management)
- 2024-2025 güncel filmler (200+ film)
- TMDB API entegrasyonu
- Türkçe içerik (başlık, açıklama, türler)
- Yüksek kalite posterler
- IMDB puanları
- Otomatik film güncelleme

### 🎫 Bilet Sistemi (Ticket System)
- Otomatik bilet rezervasyon
- Koltuk seçimi (Standard, VIP, Premium, Couple)
- Çoklu bilet satın alma
- QR kod ile bilet doğrulama
- Bilet geçmişi

### 🏢 Sinema Yönetimi (Cinema Management)
- Türkiye'nin 81 ilinde 160+ sinema
- Gerçek sinema zincirleri (Cinemaximum, Paribu Cineverse, Avşar, Cinemarine)
- Çoklu salon desteği
- Dinamik fiyatlandırma
- Seans yönetimi

### 📱 Mobil Uygulama (Mobile App - Flutter)
- Android & iOS desteği
- Modern ve kullanıcı dostu arayüz
- GetX state management
- Gerçek zamanlı güncellemeler
- Karanlık tema desteği
- Türkçe dil desteği

### 🌐 API Backend (Laravel)
- RESTful API
- JWT Authentication
- Role-based access (Admin, Manager, Cashier, Customer)
- SQLite veritabanı
- Sanctum API güvenliği

## 🚀 Kurulum (Installation)

### Backend API (Laravel)

```bash
# API server dizinine git
cd api_server

# Bağımlılıkları yükle
composer install

# .env dosyasını oluştur
cp .env.example .env

# Uygulama key'ini oluştur
php artisan key:generate

# Veritabanını oluştur ve seederleri çalıştır
php artisan migrate:fresh --seed

# Sunucuyu başlat
php artisan serve
```

### Mobile App (Flutter)

```bash
# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

## 📊 Veritabanı İçeriği

- **Filmler**: ~200 güncel 2024-2025 filmleri
- **Şehirler**: 81 il
- **Sinemalar**: 160+ lokasyon
- **Salonlar**: 400+ sinema salonu
- **Koltuklar**: 40,000+ koltuk
- **Seanslar**: Günlük otomatik oluşturma

## 🔑 Test Hesapları

```
Admin:    admin@cinema.com / password
Manager:  manager@cinema.com / password
Cashier:  cashier@cinema.com / password
Customer: customer@cinema.com / password
```

## 🌐 API Endpoints

```
GET  /api/movies              # Tüm filmler
GET  /api/movies/{id}          # Film detayı
GET  /api/cinemas             # Tüm sinemalar
GET  /api/cities              # Şehirler
GET  /api/showtimes           # Seanslar
GET  /api/future-movies       # Yaklaşan filmler
POST /api/tickets             # Bilet al
GET  /api/my-tickets          # Biletlerim
POST /api/register            # Kayıt ol
POST /api/login               # Giriş yap
```

## 📱 Mobil Uygulama Ekranları

- **Ana Sayfa**: Güncel filmler ve banner slider
- **Film Detayı**: Detaylı bilgi, oyuncular, fragman
- **Sinema Seçimi**: Şehir ve sinema seçimi
- **Seans Seçimi**: Tarih ve saat seçimi
- **Koltuk Seçimi**: İnteraktif salon haritası
- **Ödeme**: Bilet türü ve ödeme bilgileri
- **Biletlerim**: Aktif ve geçmiş biletler
- **Profil**: Kullanıcı bilgileri ve ayarlar

## 🛠️ Teknolojiler

### Frontend (Mobile)
- **Flutter** 3.x
- **GetX** - State management & routing
- **HTTP** - API istekleri
- **Shared Preferences** - Local storage
- **Fluttertoast** - Bildirimler

### Backend (API)
- **Laravel** 11.x
- **PHP** 8.2+
- **SQLite** - Database
- **Sanctum** - API authentication
- **TMDB API** - Film verileri

## 📸 Screenshots

<video src="Information/video.mp4" controls width="600"></video>

Daha fazla ekran görüntüsü için `Information/` klasörüne bakınız.

## 📝 Dokümantasyon

- [Veritabanı Güncelleme Kılavuzu](api_server/VERITABANI_GUNCELLEME.md)
- [API Dokümantasyonu](api_server/README.md)
- [Detaylı Dokümantasyon](DOCUMENTATION.md)

## 🔄 Güncellemeler

### Son Güncellemeler (Aralık 2024)
- ✅ 2024-2025 güncel filmler eklendi
- ✅ TMDB API Türkçe'ye çevrildi
- ✅ Türkiye'deki gerçek sinema zincirleri eklendi
- ✅ 81 ilde sinema lokasyonları
- ✅ Flutter linter hataları düzeltildi
- ✅ Modern UI/UX iyileştirmeleri

## 🤝 Katkıda Bulunma

1. Bu repository'yi fork edin
2. Yeni bir branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

## 📄 Lisans

Bu proje eğitim amaçlıdır.

## 📧 İletişim

Sorularınız için issue açabilir veya pull request gönderebilirsiniz.

---

**Not**: TMDB API key bu projede test amaçlı kullanılmaktadır. Production kullanımı için kendi API keyinizi [TMDB](https://www.themoviedb.org/settings/api) üzerinden alınız.
