<?php

namespace Database\Seeders\Users;
use Illuminate\Database\Seeder;
use App\Models\CustomerType;

class CustomerTypeSeeder extends Seeder
{
    public function run()
    {
        $customerTypes = [
            [
                'name' => 'Yetişkin',
                'code' => 'adult',
                'icon' => 'fa-user',
                'discount_rate' => 0,
                'description' => 'Tam bilet',
                'is_active' => true,
                'sort_order' => 1
            ],
            [
                'name' => 'Öğrenci',
                'code' => 'student',
                'icon' => 'fa-graduation-cap',
                'discount_rate' => 20,
                'description' => '%20 indirim',
                'is_active' => true,
                'sort_order' => 2
            ],
            [
                'name' => 'Emekli',
                'code' => 'senior',
                'icon' => 'fa-user-tie',
                'discount_rate' => 15,
                'description' => '%15 indirim',
                'is_active' => true,
                'sort_order' => 3
            ],
            [
                'name' => 'Çocuk',
                'code' => 'child',
                'icon' => 'fa-child',
                'discount_rate' => 25,
                'description' => '%25 indirim',
                'is_active' => true,
                'sort_order' => 4
            ]
        ];

        foreach ($customerTypes as $type) {
            CustomerType::create($type);
        }
    }
}