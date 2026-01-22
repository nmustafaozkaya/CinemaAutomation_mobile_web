#!/bin/bash

# 🚀 Laravel Cinema App - Production Deployment Script
# Kullanım: sudo bash deploy.sh

set -e

echo "🚀 Laravel Cinema App Deployment Başlıyor..."

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kontroller
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}❌ Bu script root olarak çalıştırılmalı (sudo bash deploy.sh)${NC}"
    exit 1
fi

# Dizin kontrolü
if [ ! -d "/var/www/html/api_server" ]; then
    echo -e "${YELLOW}⚠️  /var/www/html/api_server dizini bulunamadı${NC}"
    read -p "Dosyalar başka bir yerde mi? (y/n): " answer
    if [ "$answer" != "y" ]; then
        echo -e "${RED}❌ Lütfen önce dosyaları /var/www/html/api_server dizinine kopyalayın${NC}"
        exit 1
    fi
    read -p "Dizin yolunu girin: " APP_DIR
else
    APP_DIR="/var/www/html/api_server"
fi

cd "$APP_DIR"

echo -e "${GREEN}✅ Dizin: $APP_DIR${NC}"

# 1. İzinleri Ayarla
echo -e "\n${YELLOW}📁 İzinler ayarlanıyor...${NC}"
chown -R www-data:www-data "$APP_DIR"
chmod -R 755 "$APP_DIR"
chmod -R 775 "$APP_DIR/storage"
chmod -R 775 "$APP_DIR/bootstrap/cache"
echo -e "${GREEN}✅ İzinler ayarlandı${NC}"

# 2. Composer Dependencies
echo -e "\n${YELLOW}📦 Composer dependencies yükleniyor...${NC}"
if [ -f "composer.json" ]; then
    composer install --optimize-autoloader --no-dev --no-interaction
    echo -e "${GREEN}✅ Composer dependencies yüklendi${NC}"
else
    echo -e "${RED}❌ composer.json bulunamadı${NC}"
    exit 1
fi

# 3. .env Dosyası Kontrolü
echo -e "\n${YELLOW}⚙️  .env dosyası kontrol ediliyor...${NC}"
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ .env dosyası .env.example'dan oluşturuldu${NC}"
        echo -e "${YELLOW}⚠️  LÜTFEN .env DOSYASINI DÜZENLEYİN!${NC}"
        echo -e "${YELLOW}   nano $APP_DIR/.env${NC}"
        read -p "Devam etmek için Enter'a basın..."
    else
        echo -e "${RED}❌ .env.example bulunamadı${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ .env dosyası mevcut${NC}"
fi

# 4. Application Key
echo -e "\n${YELLOW}🔑 Application key oluşturuluyor...${NC}"
php artisan key:generate --force
echo -e "${GREEN}✅ Application key oluşturuldu${NC}"

# 5. Storage Link
echo -e "\n${YELLOW}🔗 Storage link oluşturuluyor...${NC}"
php artisan storage:link
echo -e "${GREEN}✅ Storage link oluşturuldu${NC}"

# 6. Veritabanı Migration
echo -e "\n${YELLOW}🗄️  Veritabanı migration'ları çalıştırılıyor...${NC}"
read -p "Migration'ları çalıştırmak istiyor musunuz? (y/n): " run_migrate
if [ "$run_migrate" = "y" ]; then
    php artisan migrate --force
    echo -e "${GREEN}✅ Migration'lar tamamlandı${NC}"
    
    read -p "Seeders'ı çalıştırmak istiyor musunuz? (y/n): " run_seed
    if [ "$run_seed" = "y" ]; then
        php artisan db:seed --force
        echo -e "${GREEN}✅ Seeders tamamlandı${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Migration atlandı${NC}"
fi

# 7. Cache Temizleme
echo -e "\n${YELLOW}🧹 Cache temizleniyor...${NC}"
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear
echo -e "${GREEN}✅ Cache temizlendi${NC}"

# 8. Cache Oluşturma
echo -e "\n${YELLOW}⚡ Cache oluşturuluyor...${NC}"
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize
echo -e "${GREEN}✅ Cache oluşturuldu${NC}"

# 9. Nginx Test
echo -e "\n${YELLOW}🌐 Nginx test ediliyor...${NC}"
if nginx -t 2>/dev/null; then
    echo -e "${GREEN}✅ Nginx konfigürasyonu geçerli${NC}"
    read -p "Nginx'i yeniden yüklemek istiyor musunuz? (y/n): " reload_nginx
    if [ "$reload_nginx" = "y" ]; then
        systemctl reload nginx
        echo -e "${GREEN}✅ Nginx yeniden yüklendi${NC}"
    fi
else
    echo -e "${RED}❌ Nginx konfigürasyonu hatalı!${NC}"
    echo -e "${YELLOW}   Lütfen manuel olarak kontrol edin: nginx -t${NC}"
fi

# 10. PHP-FPM Restart
echo -e "\n${YELLOW}🔄 PHP-FPM yeniden başlatılıyor...${NC}"
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
systemctl restart php${PHP_VERSION}-fpm
echo -e "${GREEN}✅ PHP-FPM yeniden başlatıldı${NC}"

# Sonuç
echo -e "\n${GREEN}🎉 Deployment tamamlandı!${NC}"
echo -e "\n${YELLOW}📝 Yapılacaklar:${NC}"
echo -e "1. .env dosyasını kontrol edin ve düzenleyin"
echo -e "2. Veritabanı bağlantısını test edin"
echo -e "3. API endpoint'lerini test edin"
echo -e "4. SSL sertifikası kurun (Let's Encrypt)"
echo -e "5. Firewall ayarlarını yapın"
echo -e "\n${GREEN}✅ Başarılı!${NC}"
