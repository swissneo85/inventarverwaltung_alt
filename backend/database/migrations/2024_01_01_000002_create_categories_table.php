<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->foreignId('parent_id')->nullable()->constrained('categories')->onDelete('set null');
            $table->boolean('active')->default(true);
            $table->timestamps();
            
            $table->index('parent_id');
            $table->index('active');
        });

        // Benutzer-Kategorie-Zuordnung (Rechte)
        Schema::create('user_categories', function (Blueprint $table) {
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            $table->primary(['user_id', 'category_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_categories');
        Schema::dropIfExists('categories');
    }
};