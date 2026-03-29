<?php

namespace App\Http\Controllers;

use App\Jobs\VideoUploadProcess;
use App\Models\Post;
use App\Models\PostImage;
use App\Models\PostVideo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;

// rm public/storage
class PostApiController extends Controller
{
    public function index(Request $request){
        $user = $request->user();
        $key = "feed_ids_user_" . $user->id;

        $ids = Cache::remember($key, 300, function () {
            return Post::where('type', 'image')->latest()->take(20)->pluck('id');
        });

        $data = Post::with(['postImage','user' => function($query) use ($user){
            $query->withExists(['followers as followed' => function($query) use ($user){
                $query->where('follower_id', $user->id);
            }]);
        }])->withCount('like','comment')->withExists(['likedBy as liked' => function($query) use ($user){
            $query->where('likes.user_id', $user->id);
        }])->where('type','image')->whereIn('id', $ids)->orderByRaw("FIELD(id, ".$ids->implode(',').")")->take(20)->get();

        return response()->json(['message' => "Menampilkan Postingan Beranda", 'success' => true, 'data' => $data], 200);
    }

    public function indexReels(Request $request){
        $user = $request->user();
        $key = "reels_ids_user_" . $user->id;

        $ids = Cache::remember($key, 300, function () {
            return Post::where('type', 'video')->latest()->take(20)->pluck('id');
        });

        $data = Post::with(['postVideo','user' => function($query) use ($user){
            $query->withExists(["followers as followed" => function($query) use ($user){
                $query->where('follower_id', $user->id);
            }]);
        }])->withCount('like','comment')->withExists(['likedBy as liked' => function($query) use ($user){
            $query->where('likes.user_id', $user->id);
        }])->where('type','video')->whereIn('id', $ids)->orderByRaw("FIELD(id, ".$ids->implode(',').")")->take(20)->get();

        return response()->json(['message' => "Menampilkan Postingan Feed", 'success' => true, 'data' => $data], 200);
    }

    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            'caption' => 'required',
            'type' => 'required',
            'image' => 'nullable',
            'image.*' => 'image|mimes:jpeg,jpg,png',
            'thumbnail' => 'nullable|image|mimes:jpeg,jpg,png',
            'video' => 'nullable|mimes:mp4'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $user = $request->user();
        $post = Post::create([
            'user_id' => $user->id,
            'caption' => $request->caption,
            'type' => $request->type
        ]);
        if($request->type == "video"){
            $thumbnail = $request->file('thumbnail');
            $nmthumbnail = 'thumbnails_' . time() . '.' . $thumbnail->getClientOriginalExtension();
            $thumbnailPath = $thumbnail->storeAs('post/reels/thumbnail',$nmthumbnail,'s3');

            $video = $request->file('video');
            $nmvideo = "reels_" . time() . '.' . $video->getClientOriginalExtension();
            $videoPath = $video->storeAs('post/reels/raw',$nmvideo,'s3');
            $postVideo = PostVideo::create([
                'post_id' => $post->id,
                'video_path' => $videoPath,
                'thumbnail_path' => $thumbnailPath,
                'duration' => 0
            ]);

            VideoUploadProcess::dispatch($postVideo->id);
        }else{
            foreach($request->file('image') as $index => $image){
                $nmimage = "images_" . ($index + 1) . time() . '.' . $image->getClientOriginalExtension();
                $imagePath = $image->storeAs('post/images',$nmimage,'s3');
                PostImage::create([
                    'post_id' => $post->id,
                    'image_path' => $imagePath,
                    'position' => ($index + 1)
                ]);
            }
        }

        Cache::forget("feed_ids_user_" . $user->id);
        Cache::forget("reels_ids_user_" . $user->id);

        return response()->json(['message' => 'Postingan berhasil diupload', 'success' => true], 201);
    }

    public function show(Request $request, $id){
        $user = $request->user();
        $data = Post::with(['comment.user','user' => function($query) use ($user){
            $query->withExists(['followers as followed' => function($query) use ($user){
                $query->where('follower_id', $user->id);
            }]);
        }])->withCount('like','comment')->withExists(['likedBy as liked' => function($query) use ($user){
            $query->where('likes.user_id', $user->id);
        }])->findOrFail($id);

        if($data->type == "image"){
            $data->load('postImage');
        }else{
            $data->load('postVideo');
        }

        return response()->json(['message' => "Menampilkan Postingan Beranda", 'success' => true, 'data' => $data], 200);
    }
}
