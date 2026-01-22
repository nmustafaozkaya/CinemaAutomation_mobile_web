# 🚀 Production Deployment Guide - Laravel Cinema App

## 📋 Gereksinimler

- Ubuntu/Debian sunucu
- Nginx kurulu
- PHP 8.2+ ve PHP-FPM
- MySQL/MariaDB
- Composer
- Git (opsiyonel)

---

## 📦 1. Dosyaları Sunucuya Yükleme

### Seçenek A: Git ile (Önerilen)
```bash
cd /var/www
git clone <your-repo-url> html
cd html/api_server
```

### Seçenek B: FTP/SCP ile
```bash
# Local'den sunucuya tüm dosyaları kopyala
scp -r api_server/* root@your-server:/var/www/html/api_server/
```

---

## 🗄️ 2. Veritabanı Kurulumu

### MySQL/MariaDB Kurulumu
```bash
sudo apt update
sudo apt install mysql-server -y
sudo mysql_secure_installation
```

### Veritabanı ve Kullanıcı Oluşturma
```bash
sudo mysql -u root -p
```

MySQL içinde:
```sql
CREATE DATABASE cinema_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'cinema_user'@'localhost' IDENTIFIED BY 'güçlü_şifre_buraya';
GRANT ALL PRIVILEGES ON cinema_db.* TO 'cinema_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

---

## ⚙️ 3. Laravel Konfigürasyonu

### Dizin İzinleri
```bash
cd /var/www/html/api_server
sudo chown -R www-data:www-data .
sudo chmod -R 755 .
sudo chmod -R 775 storage bootstrap/cache
```

### Composer Dependencies
```bash
composer install --optimize-autoloader --no-dev
```

### .env Dosyası Oluşturma
```bash
cp .env.example .env
nano .env
```

`.env` dosyasında şunları ayarla:
```env
APP_NAME="Cinema Automation"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://nmustafaozkaya.com.tr

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=cinema_db
DB_USERNAME=cinema_user
DB_PASSWORD=güçlü_şifre_buraya

SESSION_DRIVER=file
SESSION_LIFETIME=120

SANCTUM_STATEFUL_DOMAINS=nmustafaozkaya.com.tr
```

### Application Key Oluşturma
```bash
php artisan key:generate
```

### Storage Link
```bash
php artisan storage:link
```

---

## 🗃️ 4. Veritabanı Migration ve Seeding

### Migration'ları Çalıştır
```bash
php artisan migrate --force
```

### Seeders'ı Çalıştır (İlk kurulum için)
```bash
php artisan db:seed --force
```

**ÖNEMLİ:** Seeders şunları yükler:
- Şehirler
- Sinemalar
- Salonlar
- Koltuklar
- Filmler
- Gösterimler
- Kullanıcılar (admin ve customer)
- Vergiler

---

## 🌐 5. Nginx Konfigürasyonu

### Nginx Site Konfigürasyonu Oluştur
```bash
sudo nano /etc/nginx/sites-available/cinema
```

İçeriği:
```nginx
server {
    listen 80;
    server_name nmustafaozkaya.com.tr www.nmustafaozkaya.com.tr;
    
    # HTTP'den HTTPS'e yönlendirme (SSL kurulumundan sonra)
    # return 301 https://$server_name$request_uri;
    
    root /var/www/html/api_server/public;
    index index.php index.html;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

### Site'ı Aktif Et
```bash
sudo ln -s /etc/nginx/sites-available/cinema /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🔒 6. SSL Sertifikası (Let's Encrypt)

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d nmustafaozkaya.com.tr -d www.nmustafaozkaya.com.tr
```

SSL kurulumundan sonra Nginx config'teki redirect satırının yorumunu kaldır.

---

## 🔧 7. PHP-FPM Ayarları

### PHP Memory Limit Artır
```bash
sudo nano /etc/php/8.2/fpm/php.ini
```

Şunları değiştir:
```ini
memory_limit = 256M
upload_max_filesize = 20M
post_max_size = 20M
max_execution_time = 300
```

### PHP-FPM Restart
```bash
sudo systemctl restart php8.2-fpm
```

---

## 🎯 8. Cache ve Optimizasyon

```bash
cd /var/www/html/api_server

# Config cache
php artisan config:cache

# Route cache
php artisan route:cache

# View cache
php artisan view:cache

# Optimize
php artisan optimize
```

---

## ✅ 9. Test ve Kontrol

### Veritabanı Bağlantısı Test
```bash
php artisan tinker
>>> DB::connection()->getPdo();
```

### API Test
```bash
curl http://localhost/api/movies
```

### Log Kontrol
```bash
tail -f storage/logs/laravel.log
```

---

## 🔄 10. Güncelleme İşlemi (Gelecekte)

```bash
cd /var/www/html/api_server

# Git pull (eğer Git kullanıyorsanız)
git pull origin main

# Composer update
composer install --optimize-autoloader --no-dev

# Migration
php artisan migrate --force

# Cache temizle ve yeniden oluştur
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear

php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
```

---

## 🛠️ 11. Sorun Giderme

### Permission Hataları
```bash
sudo chown -R www-data:www-data /var/www/html/api_server
sudo chmod -R 755 /var/www/html/api_server
sudo chmod -R 775 /var/www/html/api_server/storage
sudo chmod -R 775 /var/www/html/api_server/bootstrap/cache
```

### 500 Error
```bash
# Log kontrol
tail -f storage/logs/laravel.log

# Permission kontrol
ls -la storage/
ls -la bootstrap/cache/
```

### Nginx 502 Bad Gateway
```bash
# PHP-FPM durumu
sudo systemctl status php8.2-fpm

# PHP-FPM restart
sudo systemctl restart php8.2-fpm
```

---

## 📝 12. Önemli Notlar

1. **.env dosyası** asla Git'e commit edilmemeli
2. **APP_DEBUG=false** production'da mutlaka false olmalı
3. **APP_KEY** mutlaka oluşturulmalı
4. **Storage** klasörü yazılabilir olmalı
5. **Log** dosyaları düzenli temizlenmeli
6. **Backup** stratejisi oluşturulmalı

---

## 🔐 13. Güvenlik Kontrol Listesi

- [ ] APP_DEBUG=false
- [ ] .env dosyası güvenli
- [ ] Veritabanı şifresi güçlü
- [ ] SSL sertifikası kurulu
- [ ] Firewall aktif
- [ ] Gereksiz portlar kapalı
- [ ] Düzenli backup alınıyor

---

## 📞 Destek

Sorun yaşarsanız:
1. `storage/logs/laravel.log` dosyasını kontrol edin
2. Nginx error log: `/var/log/nginx/error.log`
3. PHP-FPM log: `/var/log/php8.2-fpm.log`
