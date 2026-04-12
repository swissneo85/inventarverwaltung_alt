<?php

namespace App\Http\Controllers\Api;

use App\Models\LoginLog;
use Illuminate\Http\Request;

class LoginLogController extends BaseApiController
{
    /**
     * Login-Protokoll auflisten (Admin)
     */
    public function index(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return $this->error('Keine Berechtigung', 403);
        }

        $query = LoginLog::with('user:id,name,username')
            ->orderBy('login_at', 'desc');

        // Filter
        if ($request->has('success')) {
            $query->where('success', $request->boolean('success'));
        }

        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        if ($request->has('ip_address')) {
            $query->where('ip_address', $request->ip_address);
        }

        if ($request->has('days')) {
            $query->where('login_at', '>=', now()->subDays($request->days));
        }

        $logs = $query->paginate($request->get('per_page', 100));

        return $this->success($logs);
    }

    /**
     * Fehlgeschlagene Logins (Admin)
     */
    public function failed(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return $this->error('Keine Berechtigung', 403);
        }

        $query = LoginLog::failed()
            ->orderBy('login_at', 'desc');

        if ($request->has('days')) {
            $query->where('login_at', '>=', now()->subDays($request->days));
        }

        $logs = $query->paginate($request->get('per_page', 100));

        return $this->success($logs);
    }

    /**
     * Statistiken (Admin)
     */
    public function stats(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return $this->error('Keine Berechtigung', 403);
        }

        $days = $request->get('days', 30);

        $stats = [
            'total_logins' => LoginLog::successful()->where('login_at', '>=', now()->subDays($days))->count(),
            'failed_logins' => LoginLog::failed()->where('login_at', '>=', now()->subDays($days))->count(),
            'unique_users' => LoginLog::successful()
                ->where('login_at', '>=', now()->subDays($days))
                ->distinct('user_id')
                ->count('user_id'),
            'unique_ips' => LoginLog::where('login_at', '>=', now()->subDays($days))
                ->distinct('ip_address')
                ->count('ip_address'),
            'suspicious_ips' => LoginLog::failed()
                ->where('login_at', '>=', now()->subDays($days))
                ->selectRaw('ip_address, COUNT(*) as attempts')
                ->groupBy('ip_address')
                ->having('attempts', '>=', 5)
                ->get(),
        ];

        return $this->success($stats);
    }
}