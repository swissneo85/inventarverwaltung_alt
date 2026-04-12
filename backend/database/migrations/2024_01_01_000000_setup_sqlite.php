# SQLite Support for Laravel
# Single-container deployment

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // SQLite wird automatisch erstellt
        // Diese Migration ist für die Single-Container-Deployment-Option
    }

    public function down(): void
    {
        //
    }
};