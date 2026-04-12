<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Diese Routes sind für die Frontend-Anwendung.
| Die Vue.js App wird über / ausgeliefert.
|
*/

// SPA Fallback - alle Routes gehen zur Vue App
Route::get('/{any}', function () {
    return view('app');
})->where('any', '.*');