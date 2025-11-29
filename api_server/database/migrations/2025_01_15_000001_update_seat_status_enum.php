<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Önce enum'u genişlet (hem eski hem yeni değerleri içersin)
        DB::statement("ALTER TABLE seats MODIFY COLUMN status ENUM('available', 'occupied', 'pending', 'Blank', 'Filled', 'In Another Basket') DEFAULT 'available'");
        
        // Sonra mevcut verileri güncelle
        DB::table('seats')->where('status', 'available')->update(['status' => 'Blank']);
        DB::table('seats')->where('status', 'occupied')->update(['status' => 'Filled']);
        DB::table('seats')->where('status', 'pending')->update(['status' => 'In Another Basket']);

        // Son olarak enum'u sadece yeni değerlere indir
        DB::statement("ALTER TABLE seats MODIFY COLUMN status ENUM('Blank', 'Filled', 'In Another Basket') DEFAULT 'Blank'");
    }

    public function down(): void
    {
        // Önce enum'u genişlet
        DB::statement("ALTER TABLE seats MODIFY COLUMN status ENUM('available', 'occupied', 'pending', 'Blank', 'Filled', 'In Another Basket') DEFAULT 'Blank'");
        
        // Sonra verileri geri al
        DB::table('seats')->where('status', 'Blank')->update(['status' => 'available']);
        DB::table('seats')->where('status', 'Filled')->update(['status' => 'occupied']);
        DB::table('seats')->where('status', 'In Another Basket')->update(['status' => 'pending']);

        // Son olarak enum'u eski değerlere indir
        DB::statement("ALTER TABLE seats MODIFY COLUMN status ENUM('available', 'occupied', 'pending') DEFAULT 'available'");
    }
};

