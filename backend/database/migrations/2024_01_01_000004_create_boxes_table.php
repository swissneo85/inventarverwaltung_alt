<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('boxes', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->foreignId('room_id')->nullable()->constrained('rooms')->onDelete('set null');
            $table->boolean('is_in_inbox')->default(false);
            $table->string('location_detail')->nullable();
            $table->string('box_type')->nullable()->comment('Kiste, Schublade, Regal, Schrankfach, etc.');
            $table->string('qr_token', 64)->nullable()->unique();
            $table->string('nfc_code')->nullable()->unique();
            $table->string('image')->nullable();
            $table->integer('sort_order')->default(0);
            $table->timestamps();
            
            $table->index('room_id');
            $table->index('is_in_inbox');
            $table->index('qr_token');
            $table->index('sort_order');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('boxes');
    }
};