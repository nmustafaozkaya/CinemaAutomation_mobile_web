<?php

namespace Database\Seeders\Users;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Role;
use App\Models\Cinema;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('👤 Kullanıcılar oluşturuluyor...');

        $roles = Role::all()->keyBy('name');
        $firstCinema = Cinema::first();

        if ($roles->isEmpty()) {
            $this->command->error('❌ Önce roller oluşturulmalı! RoleSeeder çalıştır.');
            return;
        }

        $users = [
            [
                'name' => 'Super Admin User',
                'email' => 'superadmin@cinema.com',
                'password' => bcrypt('password'),
                'cinema_id' => null, // Super Admin tüm sinemalara erişebilir
                'role_id' => $roles['super_admin']->id,
                'is_active' => true
            ],
            [
                'name' => 'Admin User',
                'email' => 'admin@cinema.com',
                'password' => bcrypt('password'),
                'cinema_id' => $firstCinema?->id,
                'role_id' => $roles['admin']->id,
                'is_active' => true
            ],
            [
                'name' => 'Test Customer',
                'email' => 'customer@cinema.com',
                'password' => bcrypt('password'),
                'cinema_id' => null,
                'role_id' => $roles['customer']->id,
                'is_active' => true
            ]
        ];

        foreach ($users as $user) {
            User::firstOrCreate(
                ['email' => $user['email']], 
                $user
            );
        }

        $this->command->info('✅ ' . count($users) . ' kullanıcı oluşturuldu.');
        $this->command->info('🔑 Test hesapları:');
        $this->command->info('   Super Admin: superadmin@cinema.com / password');
        $this->command->info('   Admin: admin@cinema.com / password');
        $this->command->info('   Customer: customer@cinema.com / password');
    }
}