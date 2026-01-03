# 🎬 Sinema Uygulaması - Veritabanı Güncelleme Kılavuzu

## 📋 Güncellemeler

### ✅ Yapılan Değişiklikler

1. **Film Veritabanı Güncellemesi**
   - 2024 ve 2025 yıllarına ait güncel filmler eklendi
   - TMDB API'den otomatik film çekme sistemi Türkçe'ye çevrildi
   - Film başlıkları, açıklamaları ve türler artık Türkçe
   - IMDB puanları ile beraber filmler yükleniyor
   - En az 10 oy almış popüler filmler seçiliyor

2. **Sinema Lokasyonları**
   - Türkiye'nin 81 ilindeki sinema zincirleri mevcut
   - Gerçek sinema zincirleri: Cinemaximum, Paribu Cineverse, Avşar Sinemaları, Cinemarine, Cinetime, Prestige, Cinepink
   - Gerçek AVM'ler: Forum, Kanyon, Akasya, Mall of Antalya, TerraCity, Sanko Park vb.
   - Her şehirde en az 2 sinema lokasyonu
   - Toplam 160+ sinema lokasyonu

## 🚀 Veritabanını Güncelleme

### Adım 1: API Server Dizinine Git
```bash
cd api_server
```

### Adım 2: Veritabanını Sıfırla ve Yeniden Oluştur
```bash
# Tüm tabloları sil ve yeniden oluştur
php artisan migrate:fresh

# Tüm seederleri çalıştır
php artisan db:seed
```

### Adım 3: Sadece Filmleri Güncelle (Opsiyonel)
Eğer sadece filmleri güncellemek isterseniz:
```bash
php artisan db:seed --class=Database\\Seeders\\Movies\\Movies2025Seeder
```

### Adım 4: Sunucuyu Başlat
```bash
php artisan serve
```

## 📊 Veritabanı İçeriği

### Filmler
- **2024 Filmleri**: ~100 popüler film
- **2025 Filmleri**: ~100 yaklaşan film
- **Toplam**: ~200 güncel film
- **Dil**: Türkçe (başlık, açıklama, tür)
- **Poster**: Yüksek kalite TMDB posterleri
- **IMDB Puanları**: Güncel puanlar

### Sinema Lokasyonları
```
📍 İstanbul
  - Cinemaximum Kanyon İstanbul
  - Cinemarine Akasya İstanbul

📍 Ankara  
  - Cinemaximum Forum Ankara
  - Prestige Sinemaları Cevahir Ankara

📍 İzmir
  - Cinemaximum Forum İzmir
  - Cinemarine Palladium İzmir

📍 Gaziantep
  - Paribu Cineverse Forum Gaziantep
  - Avşar Sinema / Gaziantep Sanko Park

... ve 77 şehir daha!
```

### Salonlar ve Koltuklar
- Her sinemada 3-5 salon
- Her salonda 60-120 koltuk
- Koltuk tipleri: Standard, VIP, Premium, Couple
- Koltuk durumları: Available, Reserved, Sold

### Seanslar
- Her film için günlük çoklu seanslar
- 14 günlük gelecek seanslar
- Farklı fiyatlandırma
- Aktif/pasif durum kontrolü

## 🔧 Özelleştirme

### Film Sayısını Artırma
`api_server/database/seeders/Movies/Movies2025Seeder.php` dosyasında:
```php
$maxPages = 5; // Her yıl için 5 sayfa ≈ 100 film
// Bunu artırarak daha fazla film ekleyebilirsiniz
```

### Şehir Ekleme
`api_server/database/seeders/Cinemas/CitySeeder.php` dosyasına yeni şehir ekleyin ve ardından:
`api_server/database/seeders/Cinemas/CinemaSeeder.php` dosyasına o şehir için sinema eşleştirmesi ekleyin.

## 📝 Test Hesapları

Veritabanını güncelledikten sonra bu hesaplarla giriş yapabilirsiniz:

- **Admin**: admin@cinema.com / password
- **Manager**: manager@cinema.com / password  
- **Cashier**: cashier@cinema.com / password
- **Customer**: customer@cinema.com / password

## 🌐 API Endpoints

```
GET  /api/movies              # Tüm filmler
GET  /api/movies/{id}          # Film detayı
GET  /api/cinemas             # Tüm sinemalar
GET  /api/cities              # Tüm şehirler
GET  /api/showtimes           # Tüm seanslar
GET  /api/future-movies       # Yaklaşan filmler
POST /api/tickets             # Bilet satın al
GET  /api/my-tickets          # Kullanıcının biletleri
```

## ⚙️ TMDB API

Bu proje TMDB (The Movie Database) API'sini kullanmaktadır.
- API Key: `fd906554dbafae73a755cb63e9a595df`
- Dil: Türkçe (tr-TR)
- Rate Limit: Sayfa başına 0.5 saniye bekleme

## 🐛 Sorun Giderme

### "Class does not exist" hatası
```bash
# Composer autoload'u yenile
composer dump-autoload
```

### "TMDB API error" hatası
- İnternet bağlantınızı kontrol edin
- API key'in geçerli olduğundan emin olun
- Rate limit aşımı olabilir, bir süre bekleyin

### Boş veritabanı
```bash
# Veritabanını sıfırla ve seederleri çalıştır
php artisan migrate:fresh --seed
```

## 📅 Güncelleme Tarihi

Son güncelleme: Aralık 2024
- Güncel 2024-2025 filmleri
- Türkçe içerik
- Gerçek sinema zincirleri
- Optimized database structure

---

**Not**: Bu güncellemeler ile veritabanınız Türkiye'deki gerçek sinema zincirlerini ve güncel 2024-2025 filmlerini içerecektir. Posterler TMDB'den otomatik olarak yüklenmektedir.

