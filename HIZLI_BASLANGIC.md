# 🚀 Hızlı Başlangıç Kılavuzu

## 1️⃣ Backend (API Server) Kurulumu

```bash
# 1. API dizinine git
cd api_server

# 2. Composer bağımlılıklarını yükle
composer install

# 3. .env dosyasını oluştur
cp .env.example .env

# 4. Uygulama anahtarını oluştur
php artisan key:generate

# 5. VERİTABANINI GÜNCEL FİLMLERLE DOLDUR
# Windows için:
update_database.bat

# Linux/Mac için:
chmod +x update_database.sh
./update_database.sh

# 6. API sunucusunu başlat
php artisan serve
```

✅ API Sunucu: `http://127.0.0.1:8000/api`

---

## 2️⃣ Mobil Uygulama (Flutter) Kurulumu

```bash
# 1. Ana dizine dön
cd ..

# 2. Flutter bağımlılıklarını yükle
flutter pub get

# 3. Uygulamayı çalıştır
flutter run
```

---

## 🎬 Ne İçeriyor?

### Filmler
- ✅ **200+ güncel film** (2024-2025)
- ✅ **Türkçe içerik** (başlık, açıklama, türler)
- ✅ **Yüksek kalite posterler** (TMDB)
- ✅ **IMDB puanları**

### Sinemalar
- ✅ **81 il** (Tüm Türkiye)
- ✅ **160+ sinema lokasyonu**
- ✅ **Gerçek sinema zincirleri**
  - Cinemaximum, Paribu Cineverse
  - Avşar Sinemaları, Cinemarine
  - Cinetime, Prestige, Cinepink

### Özellikler
- ✅ **Koltuk seçimi** (Standard, VIP, Premium, Couple)
- ✅ **Bilet satın alma**
- ✅ **QR kodlu biletler**
- ✅ **Kullanıcı profili**
- ✅ **Şifre değiştirme**
- ✅ **Bilet geçmişi**

---

## 🔑 Test Hesapları

```
📧 admin@cinema.com    🔒 password  (Yönetici)
📧 manager@cinema.com  🔒 password  (Müdür)
📧 cashier@cinema.com  🔒 password  (Gişe)
📧 customer@cinema.com 🔒 password  (Müşteri)
```

---

## 🌐 API Örnekleri

### Filmleri Getir
```bash
curl http://127.0.0.1:8000/api/movies
```

### Şehirleri Listele
```bash
curl http://127.0.0.1:8000/api/cities
```

### Giriş Yap
```bash
curl -X POST http://127.0.0.1:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"customer@cinema.com","password":"password"}'
```

---

## 📱 Mobil Uygulama Ekranları

1. **Giriş/Kayıt** → Kullanıcı girişi
2. **Ana Sayfa** → Güncel filmler + banner slider
3. **Film Detayı** → Detaylı bilgi, oyuncular, IMDB
4. **Sinema Seçimi** → 81 il, 160+ sinema
5. **Seans Seçimi** → Tarih ve saat
6. **Koltuk Seçimi** → İnteraktif salon haritası
7. **Ödeme** → Bilet türü ve ödeme bilgileri
8. **Biletlerim** → Aktif ve geçmiş biletler
9. **Profil** → Kullanıcı ayarları

---

## 🔧 Sorun Giderme

### "Class does not exist" hatası
```bash
cd api_server
composer dump-autoload
```

### "TMDB API error" hatası
- İnternet bağlantınızı kontrol edin
- Birkaç dakika bekleyin (rate limit)

### Boş veritabanı
```bash
cd api_server
php artisan migrate:fresh --seed
```

### Flutter bağlantı hatası
`lib/api_connection/api_connection.dart` dosyasında API URL'i kontrol edin:
```dart
static String baseUrl = 'http://127.0.0.1:8000';
```

Android emülatörde: `http://10.0.2.2:8000`
Gerçek cihazda: `http://BILGISAYAR_IP:8000`

---

## 📚 Daha Fazla Bilgi

- 📖 [Detaylı README](README.md)
- 🎬 [Veritabanı Güncelleme Kılavuzu](api_server/VERITABANI_GUNCELLEME.md)
- 📋 [Güncelleme Özeti](GUNCELLEME_OZETI.md)
- 📝 [Dokümantasyon](DOCUMENTATION.md)

---

## 🎉 Hazırsınız!

Artık:
- ✅ Backend API çalışıyor
- ✅ 200+ güncel film yüklendi
- ✅ 160+ sinema lokasyonu hazır
- ✅ Flutter uygulaması çalışıyor

**Keyifli kodlamalar!** 🚀

---

*💡 İpucu: Veritabanını güncellemek için `api_server/update_database.bat` (Windows) veya `update_database.sh` (Linux/Mac) scriptlerini kullanın.*

