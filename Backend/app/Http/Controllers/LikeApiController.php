<?php

namespace App\Http\Controllers;

use App\Models\Like;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class LikeApiController extends Controller
{
    public function update(Request $request, $id){
        $user = $request->user();
        $liked = false;
        $like = Like::where('user_id', $user->id)->where('post_id', $id)->first();
        if($like){
            $like->delete();
        }else{
            Like::create([
                'user_id' => $user->id,
                'post_id' => $id
            ]);
            $liked = true;
        }

        Cache::forget("feed_ids_user_" . $user->id);
        Cache::forget("reels_ids_user_" . $user->id);

        return response()->json(['message' => $liked ? "Anda Menyukai Postingan" : "Anda menghapus suka dari postingan", 'success' => true, 'data' => $liked]);
    }
}
