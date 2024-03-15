<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class HealthCheck extends Controller
{
    public function api(): object
    {
        return response()->json(['status' => true]);
    }

    public function database(): object
    {
        try {
            DB::connection()->getPdo();
            return response()->json(['status' => true]);

        } catch (\Exception $e) {
            return response()->json([
                'status'  => false,
                'message' => 'Connect to database failed - Check connection params.',
                'error'   => $e
            ]);
        }
    }

}
