<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Http\Request;

class UserCategoryPermissionController extends BaseApiController
{
    public function index($userId)
    {
        if (!auth()->user()->isAdmin()) {
            return $this->error('Keine Berechtigung', 403);
        }
        $user = User::with('categoryPermissions')->findOrFail($userId);
        return $this->success($user->categoryPermissions);
    }

    public function update(Request $request, $userId)
    {
        if (!auth()->user()->isAdmin()) {
            return $this->error('Keine Berechtigung', 403);
        }
        $user = User::findOrFail($userId);

        $user->categoryPermissions()->sync($request->input('category_ids', []));

        $user->load('categoryPermissions');
        return $this->success($user->categoryPermissions, 'Berechtigungen aktualisiert');
    }
}
