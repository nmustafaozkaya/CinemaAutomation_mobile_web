<?php

namespace Database\Seeders\Users;

use Illuminate\Database\Seeder;
use App\Models\Permission;
use App\Models\Role;

class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        $this->command->info('🔐 İzinler oluşturuluyor...');

        $permissions = [
            ['name' => 'view_movies', 'description' => 'Filmleri görüntüleme'],
            ['name' => 'manage_movies', 'description' => 'Film yönetimi (CRUD)'],
            ['name' => 'manage_showtimes', 'description' => 'Seans yönetimi'],
            ['name' => 'sell_tickets', 'description' => 'Bilet satışı'],
            ['name' => 'view_reports', 'description' => 'Raporları görüntüleme'],
            ['name' => 'manage_users', 'description' => 'Kullanıcı yönetimi'],
            ['name' => 'manage_cinemas', 'description' => 'Sinema yönetimi'],
        ];

        foreach ($permissions as $permission) {
            Permission::firstOrCreate(['name' => $permission['name']], $permission);
        }

        $this->command->info('✅ ' . count($permissions) . ' izin oluşturuldu.');

        // İzinleri rollere ata
        $this->assignPermissionsToRoles();
    }

    private function assignPermissionsToRoles(): void
    {
        $this->command->info('🔗 İzinler rollere atanıyor...');

        // Super Admin - tüm izinler
        $superAdminRole = Role::where('name', 'super_admin')->first();
        if ($superAdminRole) {
            $superAdminRole->permissions()->sync(Permission::pluck('id'));
        }

        // Admin - sadece bazı yönetimsel izinler
        $adminRole = Role::where('name', 'admin')->first();
        if ($adminRole) {
            $adminPermissions = Permission::whereIn('name', [
                'view_movies',
                'manage_movies',
                'manage_showtimes',
                'view_reports',
                'manage_users',
                'manage_cinemas',
            ])->get();
            $adminRole->permissions()->sync($adminPermissions->pluck('id'));
        }

        // Customer - sadece görüntüleme
        $customerRole = Role::where('name', 'customer')->first();
        if ($customerRole) {
            $customerPermissions = Permission::whereIn('name', [
                'view_movies',
            ])->get();
            $customerRole->permissions()->sync($customerPermissions->pluck('id'));
        }

        $this->command->info('✅ İzinler rollere atandı.');
    }
}