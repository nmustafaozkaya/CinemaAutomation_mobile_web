<?php

namespace Database\Seeders\Cinemas;

use Illuminate\Database\Seeder;
use App\Models\Cinema;
use App\Models\City;
use Faker\Factory as Faker;

class CinemaSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🎪 Sinemalar oluşturuluyor...');

        $faker = Faker::create('tr_TR');
        $cities = City::all();

        if ($cities->isEmpty()) {
            $this->command->error('❌ Önce şehirler oluşturulmalı! CitySeeder çalıştır.');
            return;
        }

        $cinemaChains = [
            'Cinemaximum',
            'Cinemarine', 
            'Cinepink',
            'Avşar Sinemaları',
            'Prestige Sinemaları',
            'Cinetime',
            'Cinetech',
            'Metropol Sinemaları'
        ];

        $mallNames = [
            'Forum',
            'Optimum', 
            'Piazza',
            'ÖzdilekPark',
            'Marmara Park',
            'Palladium',
            'Viaport',
            'Kanyon',
            'Cevahir',
            'Akasya'
        ];

        $totalCinemas = 0;

        foreach ($cities as $city) {
            // Büyük şehirlerde 2 sinema, diğerlerinde 1
            $cinemaCount = in_array($city->name, ['İstanbul', 'Ankara', 'İzmir']) ? 2 : 1;

            for ($i = 1; $i <= $cinemaCount; $i++) {
                $chain = $faker->randomElement($cinemaChains);
                $mall = $faker->randomElement($mallNames);
                
                $cinemaName = "{$chain} {$mall} {$city->name}";
                
                Cinema::firstOrCreate([
                    'name' => $cinemaName,
                    'city_id' => $city->id
                ], [
                    'address' => "{$mall} AVM, Kat: {$faker->numberBetween(1, 3)}, {$city->name}",
                    'phone' => $this->generatePhoneNumber(),
                    'email' => $this->generateEmail($chain, $mall, $city->name)
                ]);

                $totalCinemas++;
            }
        }

        $this->command->info("✅ {$totalCinemas} sinema oluşturuldu.");
    }

    private function generatePhoneNumber(): string
    {
        return '0' . rand(500, 599) . ' ' . rand(100, 999) . ' ' . rand(1000, 9999);
    }

    private function generateEmail(string $chain, string $mall, string $city): string
    {
        $email = strtolower(str_replace([' ', 'ı', 'ğ', 'ü', 'ş', 'ö', 'ç'], 
            ['.',  'i', 'g', 'u', 's', 'o', 'c'], 
            $chain . '.' . $mall . '.' . $city
        ));
        
        return $email . '@sinema.com';
    }
}