<?php

namespace Database\Seeders;

use App\Models\Room;
use Illuminate\Database\Seeder;

class RoomSeeder extends Seeder
{
    public function run(): void
    {
        if (Room::count() > 0) {
            $this->command->info('Räume bereits vorhanden — übersprungen.');
            return;
        }

        $rooms = [
            'Wohnzimmer',
            'Esszimmer',
            'Küche',
            'Büro',
            'Gang EG',
            'Gästewc',
            'Bad EG',
            'Durchgang Elternschlafzimmer',
            'Elternschlafzimmer',
            'Keller West',
            'Waschküche',
            'Gang zu Waschküche',
            'Abstellraum',
            'Gang UG',
            'Bad UG',
            'Keller Ost',
            'Ben',
            'Zimmer UG Mitte',
            'Vanessa',
            'Estrich',
            'Garage',
            'Aussenbereich',
        ];

        foreach ($rooms as $name) {
            Room::create(['name' => $name]);
        }

        $this->command->info(count($rooms) . ' Räume eingefügt.');
    }
}
