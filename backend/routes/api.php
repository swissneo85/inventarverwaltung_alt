<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\BoxController;
use App\Http\Controllers\Api\ItemController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\LoginLogController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\ImageController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Auth Routes (öffentlich)
Route::post('/login', [AuthController::class, 'login']);

// Geschützte Routes
Route::middleware('auth:sanctum')->group(function () {
    
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/refresh', [AuthController::class, 'refresh']);
    
    // Profil
    Route::put('/profile', [UserController::class, 'updateProfile']);
    
    // Dashboard
    Route::get('/dashboard/stats', [DashboardController::class, 'stats']);
    Route::get('/dashboard/recent', [DashboardController::class, 'recentItems']);
    Route::get('/dashboard/inbox', [DashboardController::class, 'inbox']);
    Route::get('/dashboard/warranties', [DashboardController::class, 'warranties']);
    Route::get('/dashboard/categories', [DashboardController::class, 'categoryDistribution']);
    Route::get('/dashboard/rooms', [DashboardController::class, 'roomDistribution']);
    
    // Suche
    Route::get('/search', [SearchController::class, 'search']);
    Route::get('/search/quick', [SearchController::class, 'quick']);
    
    // QR-Code Scan
    Route::post('/scan', [ItemController::class, 'scanQrCode']);
    
    // Inbox
    Route::get('/inbox/items', [ItemController::class, 'inbox']);
    Route::get('/inbox/boxes', [BoxController::class, 'inbox']);
    
    // Räume
    Route::apiResource('rooms', RoomController::class);
    Route::get('/rooms/{id}/items', [RoomController::class, 'items']);
    Route::get('/rooms/{id}/boxes', [RoomController::class, 'boxes']);
    
    // Boxen
    Route::apiResource('boxes', BoxController::class);
    Route::post('/boxes/{id}/assign-room', [BoxController::class, 'assignToRoom']);
    Route::post('/boxes/{id}/move-to-inbox', [BoxController::class, 'moveToInbox']);
    Route::post('/boxes/{id}/qr-code', [BoxController::class, 'generateQrCode']);
    Route::get('/boxes/{id}/items', [BoxController::class, 'items']);
    
    // Items
    Route::apiResource('items', ItemController::class);
    Route::post('/items/{id}/assign-room', [ItemController::class, 'assignToRoom']);
    Route::post('/items/{id}/assign-box', [ItemController::class, 'assignToBox']);
    Route::post('/items/{id}/move-to-inbox', [ItemController::class, 'moveToInbox']);
    Route::post('/items/{id}/qr-code', [ItemController::class, 'generateQrCode']);
    Route::get('/items/{id}/images', fn(Request $r, $id) => app(ImageController::class)->index('items', $id));
    Route::post('/items/{id}/images', fn(Request $r, $id) => app(ImageController::class)->store($r, 'items', $id));
    Route::post('/items/{id}/images/reorder', fn(Request $r, $id) => app(ImageController::class)->reorder($r, 'items', $id));

    // Boxen Images
    Route::get('/boxes/{id}/images', fn(Request $r, $id) => app(ImageController::class)->index('boxes', $id));
    Route::post('/boxes/{id}/images', fn(Request $r, $id) => app(ImageController::class)->store($r, 'boxes', $id));
    Route::post('/boxes/{id}/images/reorder', fn(Request $r, $id) => app(ImageController::class)->reorder($r, 'boxes', $id));

    // Bilder löschen
    Route::delete('/images/{imageId}', [ImageController::class, 'destroy']);
    
    // Kategorien
    Route::apiResource('categories', CategoryController::class);
    Route::get('/categories/{id}/items', [CategoryController::class, 'items']);
    Route::get('/categories/{id}/users', [CategoryController::class, 'users']);
    Route::get('/categories/tree', [CategoryController::class, 'index']);
    
    // Benutzer (Admin)
    Route::middleware('role:admin')->group(function () {
        Route::apiResource('users', UserController::class);
        Route::get('/users/{id}/categories', [UserController::class, 'categories']);
        
        // Login-Protokoll
        Route::get('/logs/login', [LoginLogController::class, 'index']);
        Route::get('/logs/login/failed', [LoginLogController::class, 'failed']);
        Route::get('/logs/login/stats', [LoginLogController::class, 'stats']);
    });
});