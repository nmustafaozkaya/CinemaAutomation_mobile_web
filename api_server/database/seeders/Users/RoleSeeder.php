<?php

namespace Database\Seeders\Users;

use Illuminate\Database\Seeder;
use App\Models\Role;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('👥 Roller oluşturuluyor...');

        $roles = [
            [
                'name' => 'super_admin',
                'description' => 'Sistem yöneticisi - Tüm yetkiler'
            ],
            [
                'name' => 'admin',
                'description' => 'Sinema müdürü - Yönetim yetkileri'
            ],
            [
                'name' => 'customer',
                'description' => 'Müşteri - Temel görüntüleme yetkileri'
            ]
        ];

        foreach ($roles as $role) {
            Role::firstOrCreate(
                ['name' => $role['name']], 
                $role
            );
        }

        $this->command->info('✅ ' . count($roles) . ' rol oluşturuldu.');
    }
}