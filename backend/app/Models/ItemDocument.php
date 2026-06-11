<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ItemDocument extends Model
{
    protected $fillable = ['item_id', 'type', 'name', 'file_path', 'mime_type', 'file_size'];

    const TYPES = [
        'quittung'  => 'Quittung',
        'anleitung' => 'Bedienungsanleitung',
        'garantie'  => 'Garantieschein',
        'foto'      => 'Foto (Typenschild/SN)',
        'sonstiges' => 'Sonstiges',
    ];

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}
