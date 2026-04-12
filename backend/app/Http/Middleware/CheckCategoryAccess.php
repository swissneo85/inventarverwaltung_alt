<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckCategoryAccess
{
    /**
     * Prüft ob der Benutzer Zugriff auf eine Kategorie hat
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        // Admin hat immer Zugriff
        if ($user->isAdmin()) {
            return $next($request);
        }

        // Kategorie-ID aus dem Request holen
        $categoryId = $request->route('category') ?? $request->input('category_id');

        if (!$categoryId) {
            return $next($request);
        }

        // Prüfen ob Benutzer Zugriff auf diese Kategorie hat
        if (!$user->hasAccessToCategory($categoryId)) {
            return response()->json([
                'success' => false,
                'message' => 'Kein Zugriff auf diese Kategorie',
            ], 403);
        }

        return $next($request);
    }
}