<?php

namespace App\Http\Controllers\Api;

use App\Models\Person;
use Illuminate\Http\Request;

class PersonController extends BaseApiController
{
    public function index()
    {
        return $this->success(Person::orderBy('name')->get());
    }

    public function store(Request $request)
    {
        $request->validate(['name' => 'required|string|max:255']);
        $person = Person::create($request->only('name'));
        return $this->success($person, 'Person erstellt', 201);
    }

    public function show($id)
    {
        $person = Person::find($id);
        if (!$person) {
            return $this->error('Person nicht gefunden', 404);
        }
        return $this->success($person);
    }

    public function update(Request $request, $id)
    {
        $person = Person::find($id);
        if (!$person) {
            return $this->error('Person nicht gefunden', 404);
        }
        $request->validate(['name' => 'required|string|max:255']);
        $person->update($request->only('name'));
        return $this->success($person, 'Person aktualisiert');
    }

    public function destroy($id)
    {
        $person = Person::find($id);
        if (!$person) {
            return $this->error('Person nicht gefunden', 404);
        }
        $person->delete();
        return $this->success(null, 'Person gelöscht');
    }
}
