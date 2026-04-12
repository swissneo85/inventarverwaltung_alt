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

// API Health Check
Route::get('/health', function () {
    return response()->json(['status' => 'ok', 'timestamp' => now()]);
});

// SPA Fallback - alle Routes gehen zur Vue App
Route::get('/{any}', function () {
    return view('app');
})->where('any', '.*');