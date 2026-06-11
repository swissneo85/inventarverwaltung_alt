<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        if (Category::count() > 0) {
            $this->command->info('Kategorien bereits vorhanden — übersprungen.');
            return;
        }

        $categories = [
            'Elektronik',
            'Garten',
            'Haushalt',
            'Spielzeug',
            'Werkzeug',
        ];

        foreach ($categories as $name) {
            Category::create(['name' => $name]);
        }

        $this->command->info(count($categories) . ' Kategorien eingefügt.');
    }
}
