<?php

namespace App\Http\Controllers;

use App\Models\Follow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class FollowerApiController extends Controller
{
    public function update(Request $request, $id){
        $user = $request->user();
        $follow = Follow::where('follower_id', $user->id)->where('following_id', $id)->first();
        $followed = false;
        if($follow){
            $follow->delete();
        }else{
            Follow::create([
                'follower_id' => $user->id,
                'following_id' => $id
            ]);
            $followed = true;
        }

        Cache::forget("feed_ids_user_" . $user->id);
        Cache::forget("reels_ids_user_" . $user->id);

        return response()->json(['message' => $followed ? "Anda memfollow" : "Anda mengunfollow", 'success' => true, 'data' => $followed], 200);
    }
}
