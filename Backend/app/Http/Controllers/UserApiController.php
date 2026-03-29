<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class UserApiController extends Controller
{
    public function index(Request $request){
        $page = $request->get('page');
        $data = $request->user()->load('following.user')->loadCount('following','followers');
        if($page == "reels"){
            $data->load(['post' => function($query){
                $query->with('postVideo')->withCount('like')->where('type','video');
            }]);
        }else{
            $data->load(['post' => function($query){
                $query->with('postImage')->withCount('like')->where('type','image');
            }]);
        }

        return response()->json($data, 200);
    }

    public function show(Request $request, $id){
        $user = $request->user();
        $page = $request->get('page');
        $data = User::withCount('following','followers')->withExists(['followers as followed' => function($query) use ($user){
            $query->where('follower_id', $user->id);
        }])->findOrFail($id);
        if($page == "reels"){
            $data->load(['post' => function($query){
                $query->with('postVideo')->withCount('like')->where('type','video');
            }]);
        }else{
            $data->load(['post' => function($query){
                $query->with('postImage')->withCount('like')->where('type','image');
            }]);
        }

        return response()->json(['message' => "Menampilkan data user", 'success' => true, 'data' => $data]);
    }

    public function update(Request $request, $id){
        $user = $request->user();
        if($request->email == $user->email){
            $validator = Validator::make($request->all(),[
                'name' => 'required',
                'email' => 'required|email',
                'bio' => 'nullable',
                'profile' => 'nullable|image|mimes:jpeg,jpg,png'
            ]);
        }else{
            $validator = Validator::make($request->all(),[
                'name' => 'required',
                'email' => 'required|email|unique:users',
                'bio' => 'nullable',
                'profile' => 'nullable|image|mimes:jpeg,jpg,png'
            ]);
        }

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        if($request->hasFile('profile')){
            if(!is_null($user->profile) && Storage::disk('s3')->exists($user->profile)){
                Storage::disk('s3')->delete($user->profile);
            }

            $profile = $request->file('profile');
            $nmprofile = 'profile_' . time() . '.' . $profile->getClientOriginalExtension();
            $profilePath = $profile->storeAs('profiles',$nmprofile,'s3');
        }else{
            $profilePath = $user->profile;
        }

        $data = User::where('id', $user->id)->findOrFail($id);
        $data->update([
            'name' => $request->name,
            'email' => $request->email,
            'bio' => $request->bio ?? $user->bio,
            'profile' => $profilePath
        ]);

        return response()->json(['message' => "Profile berhasil di update", 'success' => true, 'data' => $user], 200);
    }

    public function postUser(Request $request, $id){
        $user = $request->user();
        if($request->get('page') == 'reels'){
            $data = Post::with(['postVideo','user' => function($query) use ($user){
                $query->withExists(['followers as followed' => function($query) use ($user){
                    $query->where('follower_id', $user->id);
                }]);
            }])->withCount('like','comment')->withExists(['likedBy as liked' => function($query) use ($user){
                $query->where('likes.user_id', $user->id);
            }])->where('type','video')->where('user_id', $id)->get();
        }else{
            $data = Post::with(['postImage','user' => function($query) use ($user){
                $query->withExists(['followers as followed' => function($query) use ($user){
                    $query->where('follower_id', $user->id);
                }]);
            }])->withCount('like','comment')->withExists(['likedBy as liked' => function($query) use ($user){
                $query->where('likes.user_id', $user->id);
            }])->where('type','image')->where('user_id', $id)->get();
        }

        return response()->json(['message' => "Menampilkan Postingan User", 'success' => true, 'data' => $data], 200);
    }
}
