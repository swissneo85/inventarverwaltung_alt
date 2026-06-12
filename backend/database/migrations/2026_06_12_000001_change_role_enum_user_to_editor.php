<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Expand enum to include both old and new value
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'user', 'editor', 'viewer') NOT NULL DEFAULT 'viewer'");
        // Migrate existing 'user' records to 'editor'
        DB::statement("UPDATE users SET role = 'editor' WHERE role = 'user'");
        // Remove old 'user' value from enum
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'editor', 'viewer') NOT NULL DEFAULT 'viewer'");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'user', 'editor', 'viewer') NOT NULL DEFAULT 'user'");
        DB::statement("UPDATE users SET role = 'user' WHERE role = 'editor'");
        DB::statement("ALTER TABLE users MODIFY COLUMN role ENUM('admin', 'user', 'viewer') NOT NULL DEFAULT 'user'");
    }
};
