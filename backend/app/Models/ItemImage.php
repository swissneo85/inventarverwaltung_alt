<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class ItemImage extends Model
{
    protected $fillable = [
        'imageable_type',
        'imageable_id',
        'filename',
        'path',
        'mime_type',
        'size',
        'sort_order',
    ];

    protected $appends = ['url'];

    public function getUrlAttribute(): string
    {
        return Storage::disk('public')->url($this->path);
    }

    public function imageable()
    {
        return $this->morphTo();
    }

    protected static function booted(): void
    {
        static::deleting(function (ItemImage $image) {
            Storage::disk('public')->delete($image->path);
        });
    }
}
