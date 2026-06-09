<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('items', function (Blueprint $table) {
            $table->id();
            
            // Allgemein
            $table->string('name');
            $table->text('description')->nullable();
            $table->foreignId('category_id')->nullable()->constrained('categories')->onDelete('set null');
            $table->foreignId('subcategory_id')->nullable()->constrained('categories')->onDelete('set null');
            $table->string('brand')->nullable();
            $table->string('model')->nullable();
            $table->string('serial_number')->nullable();
            $table->string('article_number')->nullable();
            $table->string('ean')->nullable();
            $table->string('inventory_number')->nullable();
            
            // Zuordnung (nur eins darf gesetzt sein)
            $table->foreignId('room_id')->nullable()->constrained('rooms')->onDelete('set null');
            $table->foreignId('box_id')->nullable()->constrained('boxes')->onDelete('set null');
            $table->boolean('is_in_inbox')->default(false);
            
            // Menge / Zustand
            $table->decimal('quantity', 10, 2)->default(1);
            $table->string('unit')->nullable();
            $table->string('condition')->nullable()->comment('Neu, Gut, Okay, Defekt, etc.');
            $table->string('status')->nullable()->comment('Verfügbar, Verliehen, Defekt, etc.');
            $table->text('notes')->nullable();
            
            // Kaufdaten
            $table->date('purchased_at')->nullable();
            $table->date('warranty_until')->nullable();
            $table->decimal('purchase_price', 10, 2)->nullable();
            $table->string('currency', 3)->default('CHF');
            $table->string('purchase_location')->nullable();
            $table->string('dealer')->nullable();
            $table->string('order_number')->nullable();
            $table->boolean('invoice_present')->default(false);
            $table->string('invoice_file')->nullable();
            
            // Technisch / Medien
            $table->string('image')->nullable();
            $table->string('qr_token', 64)->nullable()->unique();
            
            $table->timestamps();
            
            // Indexes
            $table->index('category_id');
            $table->index('room_id');
            $table->index('box_id');
            $table->index('is_in_inbox');
            $table->index('qr_token');
            $table->index('serial_number');
            $table->index('ean');
            $table->index('inventory_number');
            $table->index('warranty_until');
            $table->index('purchased_at');
        });
        
        // Fulltext nur für MySQL (nicht SQLite)
        if (DB::getDriverName() !== 'sqlite') {
            Schema::table('items', function (Blueprint $table) {
                $table->fullText(['name', 'description', 'brand', 'model', 'serial_number']);
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('items');
    }
};
