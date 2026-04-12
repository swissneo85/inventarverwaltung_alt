<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('login_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('username')->index();
            $table->string('ip_address', 45)->index();
            $table->text('user_agent')->nullable();
            $table->boolean('success')->default(false);
            $table->string('failure_reason')->nullable();
            $table->timestamp('login_at');
            
            $table->index(['ip_address', 'success']);
            $table->index('login_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('login_logs');
    }
};