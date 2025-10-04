## Sinema Uygulaması Dokümantasyonu

Bu doküman, Flutter ile geliştirilmiş Sinema Uygulaması'nın mimarisini, kurulum adımlarını, ekran akışlarını, veri modellerini, ağ/HTTP entegrasyonunu, oturum/persistans yönetimini ve ödeme/koltuk rezervasyonu süreçlerini özetler. Son bölümde Word (.docx) çıktısı alma talimatları yer alır.

### Genel Bakış
- **Platform**: Flutter (Dart)
- **Hedefler**: Android, iOS, Web, Desktop
- **Dil/Locale**: tr_TR tarih formatları (intl)
- **Ana Başlangıç**: `lib/main.dart`
- **Giriş Mantığı**: Remember Me ile `SharedPreferences` üzerinden kalıcı oturum ve token saklama
- **API Sunucusu**: `lib/api_connection/api_connection.dart` ile taban URL ve uç noktalar

### Bağımlılıklar (pubspec.yaml)
- **http**: REST istekleri
- **shared_preferences**: Kullanıcı ve token saklama
- **intl**: Yerelleştirilmiş tarih biçimlendirme
- **flutter_svg**: SVG varlıkları
- **font_awesome_flutter**: İkon seti
- **smooth_page_indicator**, **fluttertoast**, **equatable**: UI/yardımcı paketler
- **Varlıklar**: `assets/images`, `assets/logo`, yazı tipleri: `Poppins`

### Proje Yapısı (lib/)
- `main.dart`: Uygulama giriş noktası, locale init, oturum kontrolü, `MaterialApp` yönlendirmesi
- `api_connection/`: API uç noktalarının merkezi tanımı
- `components/`: Veri modelleri ve UI bileşenleri (ör. `movies.dart`, `seat.dart`, `taxes.dart`, `user.dart`)
- `screens/`: Sayfalar/akış ekranları (Login, Home, Movies, Cinema, Seat Selection, Payment, Profile, vb.)
- `constant/`: Tema ve tipografi (`app_color_style.dart`, `app_text_style.dart`)

### Uygulama Yaşam Döngüsü ve Oturum
1. `main()` içinde `initializeDateFormatting('tr_TR')` çalışır.
2. `UserPreferences.getRememberMe()` ve `readData()` ile kalıcı kullanıcı okunur.
3. Kullanıcı varsa `HomePage`, yoksa `LoginScreen` açılır.
4. Login sonrası token (`Bearer`) ve kullanıcı bilgisi `SharedPreferences`'a yazılır.

### API ve Ağ Katmanı
- Taban URL: `http://127.0.0.1:8000/api`
- Uç Noktular: `login`, `register`, `cities`, `cinemas`, `movies`, `future-movies`, `showtimes`, `halls`, `tickets/prices/{showtimeId}`, `showtimes/{id}/available-seats`, `showtimes/{id}/reserve`, `seats/{id}/release`, `taxes`, `tickets`, `my-tickets`
- İstekler `http` paketi ile yapılır. JSON içerik tipleri kullanılır. Ödeme satın alma çağrısında `Authorization: Bearer <token>` başlığı gönderilir.

### Ekranlar ve Akışlar
- **Login (`screens/login_screen.dart`)**
  - Email/şifre ile giriş, `Remember me` seçeneği
  - Başarılı girişte kullanıcı ve token saklanır, `HomePage`'e yönlenir
- **Home (`screens/home.dart`)**
  - Alt sekmeli navigasyon: Home, Movies, Cinemas, Profile
  - `initialIndex` ile hedef sekmeye açılma desteği (satın alma sonrası Profile'a dönüyor)
- **Movies (`screens/movies_screen.dart`)**
  - Kategoriler: Now Showing, Coming Soon, Pre Order
  - Filmler `ApiConnection.movies` ve `futureMovies` üzerinden çekilir
  - Poster yüklenme/hataya dayanıklı resim bileşeni
- **Seat Selection (`screens/seat_selection_screen.dart`)**
  - Periyodik (10 sn) koltuk yenileme
  - Koltuk durumları: available, pending, occupied; renk efsanesi
  - Koltuk rezerve/serbest bırakma akışı ve kapasite kontrolü
  - Seçim tamamlanınca `ReservationScreen`'e geçiş (seçimler ve fiyat özetleri aktarılır)
- **Payment (`screens/payment_screen.dart`)**
  - Kullanıcı/Token `SharedPreferences`'tan çekilir; kullanıcı bilgileri forma doldurulur
  - Ödeme yöntemi seçimi (card/cash)
  - Vergi hesaplama özeti ve son toplam
  - `POST /tickets` ile satın alma ve başarılı işlemde `HomePage(initialIndex: 3)`

### Veri Modelleri ve Persistans
- **User (`components/user.dart`)**: id, name, email, role, durum alanları; `Role` modeli içerir
- **UserPreferences (`components/user_preferences.dart`)**: `saveData/readData/removeData`, `saveToken/getToken`, `setRememberMe/getRememberMe`
- **Seat/Showtime/Movie/Tax**: Koltuk durumları, seans, film kartları ve vergi hesaplamaları için modeller ve yardımcılar

### Koltuk Rezervasyonu Detayları
- Mevcut koltuklar: `GET /showtimes/{id}/available-seats`
- Rezervasyon: `POST /showtimes/{id}/reserve` gövde: `{ seat_id }`
- Serbest bırakma: `POST /seats/{id}/release`
- UI periyodik yenileme yapar; seçilen koltuk, sunucu tarafında pending/available değilse kullanıcı bilgilendirilir ve seçim listesi güncellenir.

### Ödeme Süreci
- Biletler: `selectedTicketDetails`'dan sayıya göre koltuklara dağıtılır (`seat_id`, `customer_type`)
- Vergiler: `TaxService.calculateTaxAmount` ile aktif vergiler toplanır
- Satın alma isteği örnek gövde alanları: `showtime_id`, `tickets`, `customer_*`, `payment_method`, `tax_calculation`, `user_id`
- Başarılı yanıt sonrası ana ekrana profil sekmesiyle dönüş

### Kurulum ve Çalıştırma
1. Flutter SDK kurulu olmalı (stable kanal önerilir)
2. Proje kökünde aşağıdakileri çalıştırın:
   - `flutter pub get`
   - Gerekirse: `flutter run -d chrome` veya bağlı cihaza `flutter run`
3. API sunucusu için: `cinema_api_server` (zip içeriği) yerel olarak `http://127.0.0.1:8000/api` altında çalışır olmalı
4. Android/iOS için ilgili platform ayarlarını yapılandırın (Android manifest, iOS ATS vb.)

### Ortam/Config
- API tabanı `ApiConnection.hostConnection` üzerinden yönetilir. Gerekirse `.env` benzeri yapı için kod genişletilebilir.
- Geliştirmede `127.0.0.1` mobil emülatörde cihaza göre farklılık gösterebilir:
  - Android Emülatör: `10.0.2.2`
  - iOS Simülatör: `127.0.0.1`
  - Fiziksel cihaz: Makine IP'si ve aynı ağ

### Hata Yönetimi ve Bildirimler
- Login ve koltuk işlemlerinde `Fluttertoast` ve `SnackBar` ile kullanıcı geri bildirimi
- HTTP hatalarında durum kodu ve gövde içeriği kullanıcıya kısmen iletilir
- Poster yükleme hatalarında yedek ikon gösterimi

### Güvenlik Notları
- Token, `SharedPreferences`'ta düz metin olarak tutulur (deneysel/prototip). Üretimde güvenli depolama çözümleri önerilir (örn. Keychain/Keystore, flutter_secure_storage).
- Sunucuya tüm mutasyon işlemlerinde `Authorization: Bearer` başlığı gerekir.

### UI/Temalandırma
- Renk/tema: `constant/app_color_style.dart`
- Yazı stili: `constant/app_text_style.dart`, `Poppins` fontları dahil
- SVG desenler ve görseller `assets` altında listelenmiştir (pubspec.yaml)

### Yaygın Sorunlar ve Çözümler
- Emülatörde API'ye bağlanamama: Android için `10.0.2.2` deneyin; CORS/Web için `web/index.html` ve sunucu ayarlarını kontrol edin.
- Boş/yanıtsız istekler: Sunucu loglarını ve endpoint URL'lerini doğrulayın.
- Koltuk durumu yarış şartları: Periyodik yenileme ve sunucu doğrulamaları zaten mevcut; uyarılar `SnackBar` ile gösterilir.

### Geliştirme Önerileri
- API katmanını servis sınıflarına ayırma ve hata/süreölçer/loglama ekleme
- State management (Provider/Bloc/Riverpod) ile ekranlar arası veri akışı
- Yönlendirmeyi `GoRouter`/`auto_route` ile tip güvenli hale getirme
- Ödeme yöntemleri ve 3. parti ödeme geçitleri için soyutlama

### Word (.docx) Olarak Dışa Aktarma
Bu dosya Markdown formatındadır. Word'e aktarmak için aşağıdaki yöntemlerden birini kullanın:

1. Visual Studio Code veya Cursor içinde dosyayı açın, tamamını kopyalayın, Word'e yapıştırın. Word otomatik olarak başlıkları ve listeleri algılar. Ardından `Farklı Kaydet > Word Belgesi (*.docx)`.
2. Pandoc ile dönüştürme:
   - Pandoc kurun, sonra proje kökünde çalıştırın:
   - Windows PowerShell:
     - `pandoc -f markdown -t docx -o SinemaUygulamasi.docx DOCUMENTATION.md`
3. Online dönüştürücü kullanın: Markdown'dan Word'e çeviren güvenilir bir araçla `DOCUMENTATION.md` yükleyip `.docx` indirin.

—
Sorular veya ek dokümantasyon talepleri için belirtin; ekran görüntüleri ve veri akış diyagramları eklenebilir.


