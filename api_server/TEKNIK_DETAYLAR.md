# Cinema Automation System - Technical Details and Technologies Used

## 🎯 Project Architecture

This project is a **Full-Stack** cinema automation system:
- **Backend API**: RESTful API (Laravel)
- **Web Interface**: Blade Templates (Server-Side Rendering)
- **Frontend Assets**: Vite + Tailwind CSS + JavaScript

---

## 🔧 Backend Teknolojileri

### 1. **Framework and Core**
- **Laravel Framework**: `^12.0` 
  - **Location**: `composer.json`
  - Modern PHP framework for web applications
- **PHP**: `^8.2` (Modern PHP features)
  - Type declarations, attributes, enums
  - Improved performance and error handling
- **Composer**: Dependency management
  - **Location**: `composer.json`, `composer.lock`
  - Package manager for PHP

### 2. **Authentication & Security**
- **Laravel Sanctum**: `^4.1` - Token-based API authentication
  - Bearer token authentication
  - Multi-device token management
  - Token abilities (permission-based)
- **Laravel Authentication**: Session-based web authentication
- **Password Hashing**: Bcrypt (Hash::make)
- **CSRF Protection**: Laravel built-in CSRF tokens
- **Middleware**: Custom AdminMiddleware

### 3. **Database and ORM**
- **Eloquent ORM**: Laravel's ORM system
  - **Location**: `app/Models/` directory
  - Model relationships (HasMany, BelongsTo, Many-to-Many)
  - Query Builder
  - Eager Loading (prevents N+1 problem)
- **Database Migrations**: 27 migration files
  - **Location**: `database/migrations/` directory
  - Version-controlled database schema
- **Database Seeders**: Test data creation
  - **Location**: `database/seeders/` directory
  - Categorized by feature (Users, Movies, Cinemas, etc.)
- **Database**: SQLite (development), MySQL/PostgreSQL (production)
  - **Location**: `database/database.sqlite` (development)
  - Configuration: `config/database.php`

### 4. **Laravel Features**
- **Routing**: 
  - Web routes (`routes/web.php`) - For Blade views
    - **Location**: `routes/web.php`
  - API routes (`routes/api.php`) - For RESTful API
    - **Location**: `routes/api.php`
- **Controllers**: 
  - API Controllers (`app/Http/Controllers/Api/`)
    - **Location**: `app/Http/Controllers/Api/` directory
  - Web Controllers (`app/Http/Controllers/`)
    - **Location**: `app/Http/Controllers/` directory
- **Models**: 15+ Eloquent Models
  - **Location**: `app/Models/` directory
- **Middleware**: 
  - `auth:sanctum` - API token authentication
    - **Location**: `app/Http/Middleware/` (Laravel built-in)
  - `auth` - Web session authentication
    - **Location**: `app/Http/Middleware/` (Laravel built-in)
  - `admin` - Custom admin middleware
    - **Location**: `app/Http/Middleware/AdminMiddleware.php`
- **Validation**: Laravel Validation Rules
  - **Location**: Controllers and Form Request classes
- **Error Handling**: Try-catch blocks, standard error responses
  - **Location**: Controllers and Exception handlers

### 5. **Development Tools**
- **Laravel Tinker**: `^2.10.1` - REPL tool
- **Laravel Pint**: `^1.13` - Code formatter
- **Laravel Pail**: `^1.2.2` - Log viewer
- **Laravel Sail**: `^1.41` - Docker development
- **PHPUnit**: `^11.5.3` - Testing framework
- **Faker**: `^1.23` - Fake data generation

---

## 🎨 Frontend Teknolojileri

### 1. **Template Engine**
- **Laravel Blade**: Server-side templating
  - **Location**: `resources/views/` directory
  - Component system (`@component`, `@include`)
  - Layout inheritance (`@extends`, `@section`)
  - Directives (`@if`, `@foreach`, `@auth`)
  - CSRF token integration
  - 15+ Blade view files

### 2. **CSS Framework**
- **Tailwind CSS**: `^4.0.0` - Utility-first CSS
  - **Location**: `package.json`, CDN in `resources/views/layout.blade.php`
  - Responsive design
  - Custom components
  - Modern UI/UX
- **CDN Tailwind**: CDN usage for production
  - **Location**: `resources/views/layout.blade.php` (CDN link)

### 3. **JavaScript and Build Tools**
- **Vite**: `^6.2.4` - Modern build tool
  - **Location**: `package.json`, `vite.config.js`
  - Hot Module Replacement (HMR)
  - Fast builds
  - Asset bundling
- **Axios**: `^1.8.2` - HTTP client
  - **Location**: `package.json`, CDN in `resources/views/layout.blade.php`
  - API requests
  - Request/Response interceptors
- **Laravel Vite Plugin**: `^1.2.0` - Laravel integration
  - **Location**: `package.json`, `vite.config.js`
- **Concurrently**: `^9.0.1` - Parallel script execution
  - **Location**: `package.json`

### 4. **Frontend Assets**
- **Font Awesome**: `6.0.0` - Icon library (CDN)
  - **Location**: CDN link in `resources/views/layout.blade.php`
- **Google Fonts**: Inter font family
  - **Location**: CDN link in `resources/views/layout.blade.php`
- **Custom JavaScript**: 
  - `resources/js/app.js` - Main application JavaScript
    - **Location**: `resources/js/app.js`
  - `resources/js/admin.js` - Admin panel JavaScript
    - **Location**: `resources/js/admin.js`
- **Custom CSS**: `resources/css/app.css`
  - **Location**: `resources/css/app.css`

---

## 🗄️ Database Structure

### Database Features
- **ORM**: Eloquent
  - **Location**: `app/Models/` directory
- **Migrations**: 27 migration files
  - **Location**: `database/migrations/` directory
- **Seeders**: Seeders for test data
  - **Location**: `database/seeders/` directory
- **Relationships**:
  - One-to-Many: City → Cinemas → Halls → Seats
  - One-to-Many: Movie → Showtimes → Tickets
  - Many-to-Many: Role → Permissions
  - BelongsTo: User → Role, Ticket → Showtime

### Main Tables
1. `users` - Users
   - **Model**: `app/Models/User.php`
   - **Migration**: `database/migrations/0001_01_01_000000_create_users_table.php`
2. `roles` - Roles (admin, customer)
   - **Model**: `app/Models/Role.php`
   - **Migration**: `database/migrations/2025_07_03_065807_create_roles_table.php`
3. `permissions` - Permissions
   - **Model**: `app/Models/Permission.php`
   - **Migration**: `database/migrations/2025_07_03_065808_create_permissions_table.php`
4. `cities` - Cities
   - **Model**: `app/Models/City.php`
   - **Migration**: `database/migrations/2025_07_03_065800_create_cities_table.php`
5. `cinemas` - Cinemas
   - **Model**: `app/Models/Cinema.php`
   - **Migration**: `database/migrations/2025_07_03_065801_create_cinemas_table.php`
6. `halls` - Halls
   - **Model**: `app/Models/Hall.php`
   - **Migration**: `database/migrations/2025_07_03_065802_create_halls_table.php`
7. `seats` - Seats
   - **Model**: `app/Models/Seat.php`
   - **Migration**: `database/migrations/2025_07_03_065803_create_seats_table.php`
8. `movies` - Movies
   - **Model**: `app/Models/Movie.php`
   - **Migration**: `database/migrations/2025_07_03_065804_create_movies_table.php`
9. `future_movies` - Future movies
   - **Model**: `app/Models/FutureMovie.php`
   - **Migration**: `database/migrations/2025_07_03_065805_create_future_movies_table.php`
10. `showtimes` - Showtimes
    - **Model**: `app/Models/Showtime.php`
    - **Migration**: `database/migrations/2025_07_03_065806_create_showtimes_table.php`
11. `tickets` - Tickets
    - **Model**: `app/Models/Ticket.php`
    - **Migration**: `database/migrations/2025_07_03_065812_create_tickets_table.php`
12. `sales` - Sales
    - **Model**: `app/Models/Sale.php`
    - **Migration**: `database/migrations/2025_07_03_065813_create_sales_table.php`
13. `taxes` - Taxes
    - **Model**: `app/Models/Tax.php`
    - **Migration**: `database/migrations/2025_07_03_065814_create_taxes_table.php`
14. `payment_methods` - Payment methods
    - **Model**: `app/Models/PaymentMethod.php`
    - **Migration**: `database/migrations/2026_01_14_000001_create_payment_methods_table.php`
15. `favorite_movies` - Favorite movies
    - **Model**: `app/Models/FavoriteMovie.php`
    - **Migration**: `database/migrations/2026_01_14_000002_create_favorite_movies_table.php`

---

## 📋 Database Migrations

### What is a Migration?

**Migration** is a Laravel feature that keeps the database schema (table structures) under version control and tracks changes. With migrations:
- Database structure is stored as code
- Database synchronization is ensured in team work
- Database updates are automatically performed when deploying to production
- Rollback operations can be performed

### Migration Files

The project contains **27 migration files**. Migration files are located in the `database/migrations/` directory and are named in date format.

**Location**: `database/migrations/` directory

#### 1. **Core Laravel Migrations**
- `0001_01_01_000000_create_users_table.php` - Users table
  - **Location**: `database/migrations/0001_01_01_000000_create_users_table.php`
- `0001_01_01_000001_create_cache_table.php` - Cache tables
  - **Location**: `database/migrations/0001_01_01_000001_create_cache_table.php`
- `0001_01_01_000002_create_jobs_table.php` - Queue jobs table
  - **Location**: `database/migrations/0001_01_01_000002_create_jobs_table.php`
- `2025_07_03_080220_create_personal_access_tokens_table.php` - Sanctum token table
  - **Location**: `database/migrations/2025_07_03_080220_create_personal_access_tokens_table.php`

#### 2. **Cinema Infrastructure Migrations**
- `2025_07_03_065800_create_cities_table.php` - Cities table
  - **Location**: `database/migrations/2025_07_03_065800_create_cities_table.php`
- `2025_07_03_065801_create_cinemas_table.php` - Cinemas table
  - **Location**: `database/migrations/2025_07_03_065801_create_cinemas_table.php`
- `2025_07_03_065802_create_halls_table.php` - Halls table
  - **Location**: `database/migrations/2025_07_03_065802_create_halls_table.php`
- `2025_07_03_065803_create_seats_table.php` - Seats table
  - **Location**: `database/migrations/2025_07_03_065803_create_seats_table.php`

#### 3. **Movie and Showtime Migrations**
- `2025_07_03_065804_create_movies_table.php` - Movies table
  - **Location**: `database/migrations/2025_07_03_065804_create_movies_table.php`
- `2025_07_03_065805_create_future_movies_table.php` - Future movies table
  - **Location**: `database/migrations/2025_07_03_065805_create_future_movies_table.php`
- `2025_07_03_065806_create_showtimes_table.php` - Showtimes table
  - **Location**: `database/migrations/2025_07_03_065806_create_showtimes_table.php`

#### 4. **User and Authorization Migrations**
- `2025_07_03_065807_create_roles_table.php` - Roles table
  - **Location**: `database/migrations/2025_07_03_065807_create_roles_table.php`
- `2025_07_03_065808_create_permissions_table.php` - Permissions table
  - **Location**: `database/migrations/2025_07_03_065808_create_permissions_table.php`
- `2025_07_03_065809_create_role_permissions_table.php` - Role-Permission relationship table
  - **Location**: `database/migrations/2025_07_03_065809_create_role_permissions_table.php`
- `2025_07_03_065810_create_user_permissions_table.php` - User-Permission relationship table
  - **Location**: `database/migrations/2025_07_03_065810_create_user_permissions_table.php`
- `2025_07_03_065811_add_cinema_role_to_users_table.php` - Adds cinema_id, role_id to users table
  - **Location**: `database/migrations/2025_07_03_065811_add_cinema_role_to_users_table.php`
- `2025_11_07_135154_add_phone_birth_date_gender_to_users_table.php` - Adds profile fields to users table
  - **Location**: `database/migrations/2025_11_07_135154_add_phone_birth_date_gender_to_users_table.php`

#### 5. **Ticket and Sales Migrations**
- `2025_07_03_065812_create_tickets_table.php` - Tickets table
  - **Location**: `database/migrations/2025_07_03_065812_create_tickets_table.php`
- `2025_07_03_065813_create_sales_table.php` - Sales table
  - **Location**: `database/migrations/2025_07_03_065813_create_sales_table.php`
- `2025_07_09_071615_add_sale_id_to_tickets_table.php` - Adds sale_id to tickets table
  - **Location**: `database/migrations/2025_07_09_071615_add_sale_id_to_tickets_table.php`
- `2025_07_09_112230_create_customer_types_table.php` - Customer types table (adult, student, senior, child)
  - **Location**: `database/migrations/2025_07_09_112230_create_customer_types_table.php`

#### 6. **Tax and Payment Migrations**
- `2025_07_03_065814_create_taxes_table.php` - Taxes table
  - **Location**: `database/migrations/2025_07_03_065814_create_taxes_table.php`
- `2026_01_14_000001_create_payment_methods_table.php` - Payment methods table
  - **Location**: `database/migrations/2026_01_14_000001_create_payment_methods_table.php`

#### 7. **Other Features**
- `2026_01_14_000002_create_favorite_movies_table.php` - Favorite movies table
  - **Location**: `database/migrations/2026_01_14_000002_create_favorite_movies_table.php`
- `2025_07_11_065730_add_reservation_fields_to_seats_table.php` - Seat reservation fields
  - **Location**: `database/migrations/2025_07_11_065730_add_reservation_fields_to_seats_table.php`
- `2025_01_15_000001_update_seat_status_enum.php` - Seat status enum update
  - **Location**: `database/migrations/2025_01_15_000001_update_seat_status_enum.php`
- `2026_01_10_000000_update_avatar_ticket_showtime.php` - Avatar and ticket updates
  - **Location**: `database/migrations/2026_01_10_000000_update_avatar_ticket_showtime.php`

### Migration Özellikleri

#### Foreign Key Constraints
Foreign key relationships are defined in migrations:
```php
$table->foreignId('showtime_id')->constrained('showtimes')->onDelete('cascade');
$table->foreignId('seat_id')->constrained('seats')->onDelete('cascade');
$table->foreignId('user_id')->nullable()->constrained()->onDelete('set null');
```

#### Enum Usage
Enum is used for seat statuses:
- `Blank` - Empty seat
- `Filled` - Occupied seat
- `In Another Basket` - Reserved seat

#### Unique Constraints
Unique constraints are defined in some tables:
```php
$table->unique(['showtime_id', 'seat_id']); // Single ticket for same showtime and seat
```

### Migration Commands

```bash
# Run all migrations
php artisan migrate

# Rollback last migration
php artisan migrate:rollback

# Rollback all migrations
php artisan migrate:reset

# Fresh migration (drop all tables and recreate)
php artisan migrate:fresh

# Check migration status
php artisan migrate:status

# Create new migration
php artisan make:migration create_example_table
```

---

## 🌱 Database Seeders

### What is a Seeder?

**Seeder** is a Laravel feature used to add test data or initial data to the database. With seeders:
- Test data is quickly created
- Demo data is prepared in development environment
- Initial data (roles, permissions, etc.) is added in production
- Repeatable data sets are created

### Seeder Files

The project contains **16 seeder files**. Seeders are categorized in the `database/seeders/` directory.

**Location**: `database/seeders/` directory

#### 1. **Users Category** (`database/seeders/Users/`)
- **RoleSeeder.php**: Creates basic roles
  - **Location**: `database/seeders/Users/RoleSeeder.php`
  - `admin` - Administrator role
  - `customer` - Customer role
  
- **PermissionSeeder.php**: Creates permissions and assigns to roles
  - **Location**: `database/seeders/Users/PermissionSeeder.php`
  - CRUD permissions
  - Special permissions (ticket sales, report viewing, etc.)
  
- **UserSeeder.php**: Creates test users
  - **Location**: `database/seeders/Users/UserSeeder.php`
  - Admin: `admin@cinema.com` / `password`
  - Manager: `manager@cinema.com` / `password`
  - Cashier: `cashier@cinema.com` / `password`
  - Customer: `customer@cinema.com` / `password`
  
- **CustomerTypeSeeder.php**: Creates customer types
  - **Location**: `database/seeders/Users/CustomerTypeSeeder.php`
  - `adult` - Adult (discount: 0%)
  - `student` - Student (discount: 20%)
  - `senior` - Senior (discount: 15%)
  - `child` - Child (discount: 25%)

#### 2. **Movies Category** (`database/seeders/Movies/`)
- **MovieImportSeeder.php**: Imports movies from CSV file
  - **Location**: `database/seeders/Movies/MovieImportSeeder.php`
  - Reads from `storage/app/movies.csv` file
  - Imports first 100 movies
  - Adds movie posters and details
  
- **Movies2025Seeder.php**: Adds 2025 movies
  - **Location**: `database/seeders/Movies/Movies2025Seeder.php`
  - Popular 2025 movies
  - Movie details, poster URLs
  
- **FutureMoviesSeeder.php**: Adds future movies
  - **Location**: `database/seeders/Movies/FutureMoviesSeeder.php`
  - Movies not yet released
  - Release dates
  
- **MovieSeeder.php**: General movie seeder
  - **Location**: `database/seeders/Movies/MovieSeeder.php`

#### 3. **Cinemas Category** (`database/seeders/Cinemas/`)
- **CitySeeder.php**: Creates cities
  - **Location**: `database/seeders/Cinemas/CitySeeder.php`
  - Major cities of Turkey
  - Istanbul, Ankara, Izmir, Bursa, Antalya, etc.
  
- **CinemaSeeder.php**: Creates cinemas
  - **Location**: `database/seeders/Cinemas/CinemaSeeder.php`
  - Multiple cinemas per city
  - Cinema names, addresses
  
- **HallSeeder.php**: Creates halls
  - **Location**: `database/seeders/Cinemas/HallSeeder.php`
  - Multiple halls per cinema
  - Hall capacities, names
  
- **SeatSeeder.php**: Creates seats
  - **Location**: `database/seeders/Cinemas/SeatSeeder.php`
  - Seat map for each hall
  - Row and number based seats
  - Example: A1, A2, B1, B2, etc.

#### 4. **Showtimes Category** (`database/seeders/Showtimes/`)
- **ShowtimeSeeder.php**: Creates showtimes
  - **Location**: `database/seeders/Showtimes/ShowtimeSeeder.php`
  - Different showtimes for movies
  - Date, time, hall information
  - Price information

#### 5. **Tickets Category** (`database/seeders/Tickets/`)
- **TaxSeeder.php**: Creates tax rates
  - **Location**: `database/seeders/Tickets/TaxSeeder.php`
  - VAT rates
  - Special taxes

#### 6. **Main Seeder**
- **DatabaseSeeder.php**: Runs all seeders in order
  - **Location**: `database/seeders/DatabaseSeeder.php`
  - First roles and permissions
  - Then movies
  - Then cinema infrastructure
  - Finally showtimes and users

### Seeder Execution Order

Seeders are executed in a specific order within `DatabaseSeeder.php`:

1. **Users Feature** (User System)
   - RoleSeeder
   - PermissionSeeder

2. **Movies Feature** (Movie System)
   - MovieImportSeeder (Import from CSV)
   - Movies2025Seeder (2025 movies)
   - FutureMoviesSeeder (Future movies)

3. **Cinemas Feature** (Cinema Infrastructure)
   - CitySeeder
   - CinemaSeeder
   - HallSeeder
   - SeatSeeder

4. **Showtimes Feature** (Showtime System)
   - ShowtimeSeeder

5. **Users & Tickets** (Final Stage)
   - UserSeeder (Test users)
   - PermissionSeeder (Permission assignments)
   - CustomerTypeSeeder (Customer types)
   - TaxSeeder (Taxes)

### Seeder Commands

```bash
# Run all seeders
php artisan db:seed

# Run specific seeder
php artisan db:seed --class=Users\RoleSeeder

# Fresh migration + seed (drop all data and recreate)
php artisan migrate:fresh --seed

# Run only specific seeder
php artisan db:seed --class=Movies\MovieImportSeeder
```

### Seeder Özellikleri

#### CSV Import
`MovieImportSeeder` reads data from CSV file:
- **Location**: `storage/app/movies.csv` file
- Reads from `storage/app/movies.csv` file
- Batch processing (in groups of 100)
- Error handling and logging

#### Foreign Key Management
Seeders consider foreign key relationships:
- First parent tables (cities, movies)
- Then child tables (cinemas, showtimes)

#### Data Validation
Seeders perform data validation:
- `firstOrCreate` usage (prevents duplicates)
- Unique constraint checking

#### Progress Tracking
Seeders track progress:
- Log messages with `$this->command->info()`
- Statistics display
- Final summary

### Seeder Output

When seeder is executed, the following information is displayed:
```
🚀 Sinema otomasyonu sistemi oluşturuluyor...
👥 Kullanıcı sistemi...
🎬 Film sistemi...
🏛️ Sinema sistemi...
🎭 Seans sistemi...
🎫 Kullanıcı ve bilet sistemi...

🎉 SİNEMA OTOMASYONU SİSTEMİ HAZIR!

   Filmler: 150
   Gelecek Filmler: 25
   Şehirler: 10
   Sinemalar: 30
   Salonlar: 60
   Koltuklar: 3,000
   Seanslar: 500
   Kullanıcılar: 4
   Roller: 2

🔑 Test Hesapları:
   Admin: admin@cinema.com / password
   Manager: manager@cinema.com / password
   Cashier: cashier@cinema.com / password
   Customer: customer@cinema.com / password
```

---

## 🔐 Authentication System

### Two Different Authentication Methods

#### 1. **Web Authentication (Blade Views)**
- **Method**: Session-based authentication
- **Middleware**: `auth`
- **Usage**: For web pages
- **Route**: `routes/web.php`
  - **Location**: `routes/web.php`
- **Controller**: `AuthController` (web)
  - **Location**: `app/Http/Controllers/AuthController.php`

#### 2. **API Authentication (RESTful API)**
- **Method**: Token-based (Laravel Sanctum)
- **Middleware**: `auth:sanctum`
- **Usage**: For API endpoints
- **Route**: `routes/api.php`
  - **Location**: `routes/api.php`
- **Controller**: `Api/AuthController`
  - **Location**: `app/Http/Controllers/Api/AuthController.php`
- **Token Type**: Bearer Token
  - **Storage**: `personal_access_tokens` table (Sanctum)

### Authorization System
- **Role-Based Access Control (RBAC)**
- **Permission System**: Role → Permissions
  - **Models**: `app/Models/Role.php`, `app/Models/Permission.php`
- **Custom Middleware**: AdminMiddleware
  - **Location**: `app/Http/Middleware/AdminMiddleware.php`
- **Token Abilities**: Permission-based token abilities

---

## 📡 API Yapısı

### RESTful API Design
- **Standard HTTP Methods**: GET, POST, PUT, DELETE
- **Response Format**: 
```json
{
  "success": true/false,
  "message": "Operation message",
  "data": { ... }
}
```
- **Status Codes**: 200, 201, 400, 401, 403, 404, 422, 500
- **API Routes Location**: `routes/api.php`
- **API Controllers Location**: `app/Http/Controllers/Api/`

### API Endpoint Kategorileri
1. **Public Endpoints**: Token gerektirmez
2. **Protected Endpoints**: `auth:sanctum` middleware
3. **Admin Endpoints**: `auth:sanctum` + `admin` middleware

---

## 🏗️ Mimari Desenler

### 1. **MVC (Model-View-Controller)**
- **Models**: `app/Models/` - Data models
  - **Location**: `app/Models/` directory
- **Views**: `resources/views/` - Blade templates
  - **Location**: `resources/views/` directory
- **Controllers**: `app/Http/Controllers/` - Business logic
  - **Location**: `app/Http/Controllers/` directory

### 2. **Repository Pattern** (Kısmen)
- Eloquent ORM ile model-based yaklaşım

### 3. **Middleware Pattern**
- Request/Response pipeline
- Authentication, Authorization, Validation

### 4. **Service Provider Pattern**
- Laravel Service Providers
- Dependency Injection

---

## 🛠️ Development Workflow

### Build Process
```bash
# Development
npm run dev          # Vite dev server
php artisan serve    # Laravel dev server

# Production
npm run build        # Vite build
php artisan optimize # Laravel optimize
```

### Asset Management
- **Vite**: Modern build tool
  - **Location**: `vite.config.js`, `package.json`
- **Laravel Mix**: Not used (Vite is used)
- **Asset Compilation**: CSS, JS bundling
  - **Output Location**: `public/build/` directory
- **Hot Reload**: During development

---

## 📦 Kullanılan Paketler ve Kütüphaneler

### Backend Packages (Composer)
- `laravel/framework`: ^12.0
- `laravel/sanctum`: ^4.1
- `laravel/tinker`: ^2.10.1

### Frontend Packages (NPM)
- `vite`: ^6.2.4
- `tailwindcss`: ^4.0.0
- `@tailwindcss/vite`: ^4.0.0
- `axios`: ^1.8.2
- `laravel-vite-plugin`: ^1.2.0
- `concurrently`: ^9.0.1

### CDN Usage
- **Tailwind CSS**: CDN (production)
  - **Location**: `resources/views/layout.blade.php`
- **Axios**: CDN
  - **Location**: `resources/views/layout.blade.php`
- **Font Awesome**: CDN
  - **Location**: `resources/views/layout.blade.php`
- **Google Fonts**: CDN
  - **Location**: `resources/views/layout.blade.php`

---

## 🔄 Request/Response Flow

### Web Request Flow
```
User Request → Route (web.php) 
  → Middleware (auth, admin) 
  → Controller 
  → Model (Eloquent) 
  → Database 
  → View (Blade) 
  → Response (HTML)
```

### API Request Flow
```
API Request → Route (api.php) 
  → Middleware (auth:sanctum) 
  → Controller (Api/) 
  → Model (Eloquent) 
  → Database 
  → JSON Response
```

---

## 🎯 Öne Çıkan Teknik Özellikler

### 1. **Dual Authentication System**
- Web için session-based
- API için token-based
- Aynı User model, farklı authentication yöntemleri

### 2. **Hybrid Architecture**
- **Server-Side Rendering**: Blade templates
- **API-First Design**: RESTful API
- **Modern Frontend**: Vite + Tailwind

### 3. **Optimized Queries**
- Eager Loading (N+1 önleme)
- Select specific columns
- Query optimization
- Memory management

### 4. **Real-time Features**
- Seat reservation system
  - **Location**: `app/Http/Controllers/Api/TicketController.php`
- Pending seat cleanup
- Status updates

### 5. **Error Handling**
- Try-catch blocks
- Standardized error responses
- Validation errors
- User-friendly messages

---

## 📊 Proje İstatistikleri

### Kod Metrikleri
- **Controller Sayısı**: 12+ API Controller
- **Model Sayısı**: 15+ Model
- **Migration Sayısı**: 27 Migration
- **View Sayısı**: 15+ Blade View
- **API Endpoint**: 50+ Endpoint
- **Middleware**: 3+ Custom Middleware

### Teknoloji Versiyonları
- **Laravel**: 12.0 (Latest)
- **PHP**: 8.2+
- **Vite**: 6.2.4
- **Tailwind**: 4.0.0
- **Sanctum**: 4.1

---

## 🚀 Deployment Teknolojileri

### Server Configuration
- **Web Server**: Nginx (`nginx-cinema.conf`)
- **PHP**: PHP-FPM
- **Database**: MySQL/PostgreSQL (production)

### Deployment Scripts
- `deploy.sh` - Linux deployment
  - **Location**: `api_server/deploy.sh`
- `deploy-from-windows.ps1` - Windows deployment
  - **Location**: `api_server/deploy-from-windows.ps1`
- `first_setup.sh` - Initial setup
  - **Location**: `api_server/first_setup.sh`
- `update_database.sh` - Database update
  - **Location**: `api_server/update_database.sh`

---

## 💡 Teknik Kararlar ve Nedenleri

### 1. **Laravel Blade Usage**
- **Why**: Fast development, server-side rendering
- **Advantage**: SEO-friendly, fast page loading
- **Usage**: Admin panel, web interface
- **Location**: `resources/views/` directory

### 2. **RESTful API Design**
- **Why**: Integration with modern frontend frameworks
- **Advantage**: Mobile app, SPA support
- **Usage**: API-first approach
- **Location**: `routes/api.php`, `app/Http/Controllers/Api/`

### 3. **Laravel Sanctum**
- **Why**: Token-based authentication
- **Advantage**: Stateless, scalable
- **Usage**: API endpoints
- **Location**: `config/sanctum.php`, `app/Http/Middleware/`

### 4. **Tailwind CSS**
- **Why**: Utility-first, fast UI development
- **Advantage**: Responsive, modern design
- **Usage**: All web interface
- **Location**: `package.json`, CDN in `resources/views/layout.blade.php`

### 5. **Vite**
- **Why**: Modern build tool, fast
- **Advantage**: HMR, fast builds
- **Usage**: Asset compilation
- **Location**: `vite.config.js`, `package.json`

---

## 🔍 Kod Kalitesi ve Best Practices

### 1. **PSR Standards**
- PSR-4 Autoloading
- PSR-12 Coding Style

### 2. **Laravel Conventions**
- Naming conventions
- Directory structure
- Route naming

### 3. **Security Best Practices**
- Password hashing
- CSRF protection
- Input validation
- SQL injection prevention (Eloquent)

### 4. **Performance Optimization**
- Eager loading
- Query optimization
- Caching strategies
- Asset optimization

---

## 📝 Summary

This project is a **production-ready** cinema automation system developed using **modern web development** technologies.

**Teknoloji Stack Özeti**:
- **Backend**: Laravel 12.0 + PHP 8.2
- **Frontend**: Blade + Tailwind CSS + Vite
- **Authentication**: Sanctum (API) + Session (Web)
- **Database**: Eloquent ORM + Migrations
- **Build Tool**: Vite
- **CSS Framework**: Tailwind CSS 4.0

**Mimari Yaklaşım**:
- Hybrid architecture (SSR + API)
- MVC pattern
- RESTful API design
- Role-based access control

---

## 📁 File Structure and Locations

### Web Interface Files (Blade Views)

All web interface files are located in `resources/views/` directory. These files use Laravel Blade templating engine for server-side rendering.

#### Main Layout Files
- **`resources/views/layout.blade.php`** - Master layout template
  - Contains HTML structure, navigation, header, footer
  - Includes Tailwind CSS, Font Awesome, Axios CDN links
  - Defines global styles and JavaScript
  - Mobile-responsive hamburger menu
  - Role-based navigation links

#### Authentication Pages
- **`resources/views/login.blade.php`** - User login page
  - Email and password authentication form
  - "Remember Me" checkbox
  - Redirects to dashboard after successful login
  - CSRF token protection

- **`resources/views/register.blade.php`** - User registration page
  - New user registration form
  - Email, password, name fields
  - Password confirmation
  - Validation and error handling

#### Dashboard and Home Pages
- **`resources/views/dashboard.blade.php`** - Main dashboard page
  - Welcome page for authenticated users
  - Mobile app QR code (top-left for easy scanning)
  - Android app download link
  - Role-based content display
  - Quick access to main features

- **`resources/views/welcome.blade.php`** - Landing page
  - Public welcome page for guests
  - Introduction to the cinema system
  - Call-to-action buttons

#### Movie Pages
- **`resources/views/movies.blade.php`** - Movie listing page
  - Displays all available movies
  - Movie cards with posters, titles, ratings
  - Favorite button (heart icon) on each movie card
  - Filter and search functionality
  - Pagination support

- **`resources/views/posters.blade.php`** - Movie posters gallery
  - Visual gallery of movie posters
  - Grid layout with hover effects

#### Ticket Booking Pages
- **`resources/views/tickets.blade.php`** - Ticket booking page (Admin)
  - Admin ticket sales interface
  - Multi-step ticket booking process
  - Includes all booking components

- **`resources/views/buy-tiickets.blade.php`** - Customer ticket purchase page
  - Customer-facing ticket booking interface
  - Step-by-step booking process
  - Movie selection, cinema selection, seat selection, payment

- **`resources/views/my-tickets.blade.php`** - User's purchased tickets
  - Displays all tickets purchased by the logged-in user
  - Ticket details: movie, showtime, seats, price
  - Ticket status and QR codes
  - Filter and search options

#### User Profile Pages
- **`resources/views/profile.blade.php`** - User profile page
  - User information display and editing
  - Edit profile details (name, email, phone, birth date, gender)
  - Change password functionality
  - Links to Payment Methods and Favorite Movies
  - Profile picture upload (if implemented)

- **`resources/views/payment-methods.blade.php`** - Payment methods management
  - Add, edit, delete payment methods (credit cards)
  - Display saved cards with visual styling
  - Set default payment method
  - Card number formatting (4-digit groups)
  - Card type icons (Visa, Mastercard, etc.)

- **`resources/views/favorite-movies.blade.php`** - Favorite movies page
  - Displays user's favorite movies
  - Remove from favorites functionality
  - Movie cards with posters and details
  - Empty state when no favorites

#### Admin Pages
- **`resources/views/admin.blade.php`** - Admin management panel
  - Admin dashboard with system statistics
  - Management tools and settings
  - User management, cinema management
  - Reports and analytics

#### Reusable Components (`resources/views/components/`)
- **`components/ticket-steps.blade.php`** - Ticket booking step indicator
  - Visual progress indicator (Step 1, 2, 3, 4)
  - Shows current step in booking process

- **`components/movie-selection.blade.php`** - Movie selection component
  - Movie list with search and filter
  - Movie cards with posters
  - Selection functionality

- **`components/cinema-selection.blade.php`** - Cinema and showtime selection
  - City selection dropdown
  - Cinema selection based on city
  - Showtime selection based on cinema and movie
  - Date and time display

- **`components/seat-map.blade.php`** - Interactive seat map
  - Visual seat layout
  - Seat status (available, occupied, selected)
  - Seat selection with click
  - Ticket type selection (Adult, Student, Senior, Child)
  - Price calculation

- **`components/payment-form.blade.php`** - Payment form component
  - Saved payment methods display
  - New card input form
  - Card number formatting (4-digit groups)
  - Expiry date and CVV input
  - Card type selection
  - Payment submission

### Frontend Assets

#### JavaScript Files (`resources/js/`)
- **`resources/js/app.js`** - Main application JavaScript
  - Global JavaScript functions
  - API request helpers
  - Common utilities

- **`resources/js/admin.js`** - Admin panel JavaScript
  - Admin-specific functionality
  - Management interface interactions

#### CSS Files (`resources/css/`)
- **`resources/css/app.css`** - Main application stylesheet
  - Custom CSS styles
  - Additional styling beyond Tailwind

#### Build Configuration
- **`vite.config.js`** - Vite build configuration
  - Asset compilation settings
  - Laravel Vite plugin configuration
  - Entry points for JS and CSS

### Backend Files

#### Controllers (`app/Http/Controllers/`)
- **Web Controllers** (`app/Http/Controllers/`)
  - `AuthController.php` - Web authentication (login, register, logout)
  - `DashboardController.php` - Dashboard page controller
  - `MovieController.php` - Movie listing and details
  - `TicketController.php` - Ticket booking and management
  - `ProfileController.php` - User profile management
  - `PaymentMethodController.php` - Payment methods CRUD
  - `FavoriteMovieController.php` - Favorite movies management

- **API Controllers** (`app/Http/Controllers/Api/`)
  - `Api/AuthController.php` - API authentication endpoints
  - `Api/MovieController.php` - Movie API endpoints
  - `Api/CinemaController.php` - Cinema and showtime API
  - `Api/TicketController.php` - Ticket API endpoints
  - `Api/PaymentMethodController.php` - Payment methods API
  - `Api/FavoriteMovieController.php` - Favorite movies API
  - `Api/UserController.php` - User profile API

#### Models (`app/Models/`)
- `User.php` - User model with authentication
- `Movie.php` - Movie model
- `Cinema.php` - Cinema model
- `Hall.php` - Hall model
- `Seat.php` - Seat model
- `Showtime.php` - Showtime model
- `Ticket.php` - Ticket model
- `PaymentMethod.php` - Payment method model
- `FavoriteMovie.php` - Favorite movie model
- `Role.php` - Role model
- `Permission.php` - Permission model
- And more...

#### Routes
- **`routes/web.php`** - Web routes (Blade views)
  - `/` - Dashboard
  - `/login` - Login page
  - `/register` - Registration page
  - `/movies` - Movie listing
  - `/buy-tickets` - Ticket purchase
  - `/my-tickets` - User tickets
  - `/profile` - User profile
  - `/payment-methods` - Payment methods
  - `/favorite-movies` - Favorite movies
  - `/admin` - Admin panel

- **`routes/api.php`** - API routes (RESTful endpoints)
  - `/api/login` - API login
  - `/api/movies` - Movie endpoints
  - `/api/cinemas` - Cinema endpoints
  - `/api/tickets` - Ticket endpoints
  - `/api/payment-methods` - Payment methods API
  - `/api/favorite-movies` - Favorite movies API

### Configuration Files
- **`config/app.php`** - Application configuration
- **`config/auth.php`** - Authentication configuration
- **`config/database.php`** - Database configuration
- **`config/sanctum.php`** - Sanctum token configuration
- **`.env`** - Environment variables (database, API keys, etc.)

### Public Assets (`public/`)
- **`public/index.php`** - Application entry point
- **`public/images/`** - Public image files
- **`public/favicon.ico`** - Site favicon

### Storage (`storage/`)
- **`storage/app/`** - Application storage
  - `movies.csv` - Movie import CSV file
- **`storage/logs/`** - Application logs
- **`storage/framework/`** - Framework cache and sessions

---

