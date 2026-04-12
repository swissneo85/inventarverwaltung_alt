<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'username',
        'email',
        'password',
        'role',
        'active',
        'last_login_at',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
        'active' => 'boolean',
        'last_login_at' => 'datetime',
    ];

    // Rollen: admin, user, viewer
    const ROLE_ADMIN = 'admin';
    const ROLE_USER = 'user';
    const ROLE_VIEWER = 'viewer';

    public function isAdmin(): bool
    {
        return $this->role === self::ROLE_ADMIN;
    }

    public function categories()
    {
        return $this->belongsToMany(Category::class, 'user_categories');
    }

    public function hasAccessToCategory(int $categoryId): bool
    {
        if ($this->isAdmin()) {
            return true;
        }
        return $this->categories()->where('category_id', $categoryId)->exists();
    }

    public function loginLogs()
    {
        return $this->hasMany(LoginLog::class);
    }
}