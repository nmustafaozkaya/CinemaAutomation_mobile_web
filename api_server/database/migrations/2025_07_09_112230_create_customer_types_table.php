<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('customer_types', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // 'Yetişkin', 'Öğrenci', 'Emekli', 'Çocuk'
            $table->string('code'); // 'adult', 'student', 'senior', 'child'
            $table->string('icon')->default('fa-user'); // FontAwesome ikonu
            $table->decimal('discount_rate', 5, 2)->default(0); // İndirim %'si
            $table->string('description')->nullable(); // 'Tam bilet', '%20 indirim'
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0); // Sıralama
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('customer_types');
    }
};
