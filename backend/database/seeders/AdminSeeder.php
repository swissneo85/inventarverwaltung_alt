<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        // Prüfen ob Admin bereits existiert
        if (User::where('username', 'admin')->exists()) {
            $this->command->info('Admin existiert bereits.');
            return;
        }

        User::create([
            'name' => 'Administrator',
            'username' => 'admin',
            'email' => 'admin@inventar.local',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'active' => true,
        ]);

        $this->command->info('Admin erstellt: admin / admin123');
    }
}