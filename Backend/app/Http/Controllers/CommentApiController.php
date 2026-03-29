<?php

namespace App\Http\Controllers;

use App\Models\Comment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;

class CommentApiController extends Controller
{
    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            'post_id' => 'required|numeric',
            'message' => 'required'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $user = $request->user();
        $data = Comment::create([
            'user_id' => $user->id,
            'post_id' => $request->post_id,
            'message' => $request->message
        ]);
        $data->load('user');

        Cache::forget("feed_ids_user_" . $user->id);
        Cache::forget("reels_ids_user_" . $user->id);

        return response()->json(['message' => "Anda memberikan komentat di postingan", 'success' => true, 'data' => $data], 201);
    }
}
