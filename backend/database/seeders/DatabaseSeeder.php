<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Category;
use App\Models\Room;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Admin Benutzer erstellen
        $admin = User::create([
            'name' => 'Administrator',
            'username' => 'admin',
            'email' => 'admin@inventar.local',
            'password' => Hash::make('admin123'),
            'role' => 'admin',
            'active' => true,
        ]);

        // Beispiel-Benutzer erstellen
        $user = User::create([
            'name' => 'Max Mustermann',
            'username' => 'max',
            'email' => 'max@example.com',
            'password' => Hash::make('password'),
            'role' => 'user',
            'active' => true,
        ]);

        // Kategorien erstellen
        $categories = [
            ['name' => 'Werkzeug', 'description' => 'Werkzeuge aller Art'],
            ['name' => 'Elektronik', 'description' => 'Elektronische Geräte'],
            ['name' => 'Spielzeug', 'description' => 'Spielzeug und Spiele'],
            ['name' => 'Haushalt', 'description' => 'Haushaltsgegenstände'],
            ['name' => 'Dokumente', 'description' => 'Wichtige Dokumente'],
            ['name' => 'Garten', 'description' => 'Gartengeräte und -bedarf'],
        ];

        foreach ($categories as $cat) {
            Category::create($cat);
        }

        // Dem Benutzer Kategorien zuweisen
        $user->categories()->attach([1, 2]); // Werkzeug, Elektronik

        // Räume erstellen
        $rooms = [
            ['name' => 'Keller', 'description' => 'Kellergeschoss'],
            ['name' => 'Garage', 'description' => 'Garage'],
            ['name' => 'Estrich', 'description' => 'Dachgeschoss'],
            ['name' => 'Büro', 'description' => 'Arbeitszimmer'],
            ['name' => 'Werkstatt', 'description' => 'Werkstatt im Untergeschoss'],
        ];

        foreach ($rooms as $room) {
            Room::create($room);
        }

        $this->command->info('Database seeded successfully!');
        $this->command->info('Admin login: admin / admin123');
        $this->command->info('User login: max / password');
    }
}