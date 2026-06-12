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

    const ROLE_ADMIN = 'admin';
    const ROLE_EDITOR = 'editor';
    const ROLE_VIEWER = 'viewer';

    public function isAdmin(): bool
    {
        return $this->role === self::ROLE_ADMIN;
    }

    public function isEditor(): bool
    {
        return in_array($this->role, [self::ROLE_ADMIN, self::ROLE_EDITOR]);
    }

    public function canEdit(): bool
    {
        return $this->isEditor();
    }

    public function canDelete(): bool
    {
        return $this->isAdmin();
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

    // Stub für Stufe 2: kategorie-basierte Berechtigungen
    public function categoryPermissions()
    {
        return $this->hasMany(\App\Models\UserCategoryPermission::class);
    }
}