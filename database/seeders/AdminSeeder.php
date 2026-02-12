<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        $adminRole = Role::firstOrCreate(['name' => 'superadmin']);

        $user = User::updateOrCreate(
            ['email' => 'admin@fesc.edu.co'],
            [
                'first_name' => 'Super',
                'middle_name' => null,
                'first_surname' => 'Admin',
                'second_surname' => 'FESC',
                'gender' => 'M',
                'password' => Hash::make('Password123*'),
                'email_verified_at' => now(),
                'role_name' => 'superadmin',
                'is_active' => true,
                'is_blocked' => false,
            ]
        );

        $user->syncRoles([$adminRole->name]);
    }
}
