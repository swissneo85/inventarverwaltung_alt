<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Person extends Model
{
    protected $table = 'persons';
    protected $fillable = ['name'];

    public function items()
    {
        return $this->hasMany(Item::class);
    }
}
