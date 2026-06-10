<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Str;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class BaseApiController extends Controller
{
    /**
     * Erfolg-Antwort
     */
    protected function success($data = null, string $message = 'Erfolgreich', int $code = 200)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
        ], $code);
    }

    /**
     * Fehler-Antwort
     */
    protected function error(string $message = 'Fehler', int $code = 400, $errors = null)
    {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ], $code);
    }

    /**
     * QR-Code generieren und zurückgeben
     */
    protected function generateQrCode(string $url): string
    {
        $qrCode = QrCode::format('png')
            ->size(300)
            ->margin(2)
            ->generate($url);
        
        return 'data:image/png;base64,' . base64_encode($qrCode);
    }
}