<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Person extends Model
{
    protected $table = 'persons';
    protected $fillable = ['name', 'is_active'];
    protected $casts = ['is_active' => 'boolean'];

    public function items()
    {
        return $this->hasMany(Item::class);
    }

    public function loanedItems()
    {
        return $this->hasMany(Item::class, 'loaned_to_person_id');
    }
}
