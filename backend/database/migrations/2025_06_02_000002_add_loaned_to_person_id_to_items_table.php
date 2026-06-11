<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->foreignId('loaned_to_person_id')
                ->nullable()
                ->after('person_id')
                ->constrained('persons')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('items', function (Blueprint $table) {
            $table->dropForeignIdFor(\App\Models\Person::class, 'loaned_to_person_id');
            $table->dropColumn('loaned_to_person_id');
        });
    }
};
