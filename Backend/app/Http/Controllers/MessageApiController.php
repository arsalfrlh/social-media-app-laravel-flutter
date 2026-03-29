<?php

namespace App\Http\Controllers;

use App\Events\ChatUpdated;
use App\Models\ChatRoom;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class MessageApiController extends Controller
{
    public function index(Request $request){
        $user = $request->user();
        $data = User::where('id','!=',$user->id)->where(function($query) use ($user){
            $query->whereRelation('followers','follower_id',$user->id)->orWhereRelation('following','following_id',$user->id);
        })->get();

        return response()->json(['message' => "Menampilkan chat anda", 'success' => true, 'data' => $data], 200);
    }

    public function show(Request $request, $id){
        $senderId = $request->user()->id;
        $receiverId = $id;
        $chatRoom = ChatRoom::where(function($query) use ($senderId, $receiverId){
            $query->where('sender_id', $senderId)->where('receiver_id',$receiverId)->orWhere('sender_id',$receiverId)->where('receiver_id',$senderId);
        })->first();
        if(!$chatRoom){
            $chatRoom = ChatRoom::create([
                'sender_id' => $senderId,
                'receiver_id' => $receiverId
            ]);
        }

        $data = Message::with('user')->withExists(['user as is_me' => function($query) use ($senderId){
            $query->where('id',$senderId);
        }])->where('chat_room_id', $chatRoom->id)->get();

        return response()->json(['message' => "Menampilkan Pesan percakapan", 'success' => true, 'data' => $data, 'chat_room_id' => $chatRoom->id], 200);
    }

    public function store(Request $request){
        $validator = Validator::make($request->all(),[
            'receiver_id' => 'required|numeric',
            'message' => 'required',
            'image' => 'nullable|image|mimes:jpeg,jpg,png'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $senderId = $request->user()->id;
        $receiverId = $request->receiver_id;
        $chatRoom = ChatRoom::where(function($query) use ($senderId, $receiverId){
            $query->where('sender_id', $senderId)->where('receiver_id',$receiverId)->orWhere('sender_id',$receiverId)->where('receiver_id',$senderId);
        })->first();
        if(!$chatRoom){
            $chatRoom = ChatRoom::create([
                'sender_id' => $senderId,
                'receiver_id' => $receiverId
            ]);
        }

        if($request->hasFile('image')){
            $image = $request->file('image');
            $nmimage = "images_" . time() . '.' . $image->getClientOriginalExtension();
            $imagePath = $image->storeAs('chat/room_' . $chatRoom->id, $nmimage, 's3');
        }else{
            $imagePath = null;
        }

        $data = Message::create([
            'chat_room_id' => $chatRoom->id,
            'user_id' => $senderId,
            'message' => $request->message,
            'image' => $imagePath
        ]);
        $data->load('user')->loadExists(['user as is_me' => function($query) use ($senderId){
            $query->where('id',$senderId);
        }]);

        broadcast(new ChatUpdated($data,$chatRoom->id,'create'));
        return response()->json(['message' => "Pesan berhasil dikirim", 'success' => true, 'data' => $data], 201);
    }

    public function update(Request $request, $id){
        $validator = Validator::make($request->all(),[
            'message' => 'required',
            'image' => 'nullable|image|mimes:jpeg,jpg,png'
        ]);

        if($validator->fails()){
            return response()->json(['message' => $validator->errors()->all(), 'success' => false], 422);
        }

        $user = $request->user();
        $data = Message::with('user')->withExists(['user as is_me' => function($query) use ($user){
            $query->where('id', $user->id);
        }])->where('user_id', $user->id)->findOrFail($id);
        
        if($request->hasFile('image')){
            if(!is_null($data->image) && Storage::disk('s3')->exists($data->image)){
                Storage::disk('s3')->delete($data->image);
            }

            $image = $request->file('image');
            $nmimage = "images_" . time() . '.' . $image->getClientOriginalExtension();
            $imagePath = $image->storeAs('chat/room_' . $data->chat_room_id, $nmimage, 's3');
        }else{
            $imagePath = $data->image;
        }

        $data->update([
            'message' => $request->message,
            'image' => $imagePath
        ]);
        broadcast(new ChatUpdated($data,$data->chat_room_id,'update'));
        return response()->json(['message' => "Pesan berhasil diupdate", 'success' => true, 'data' => $data], 200);
    }

    public function destroy(Request $request, $id){
        $user = $request->user();
        $message = Message::with('user')->withExists(['user as is_me' => function($query) use ($user){
            $query->where('id', $user->id);
        }])->where('user_id', $user->id)->findOrFail($id);
        if(!is_null($message->image) && Storage::disk('s3')->exists($message->image)){
            Storage::disk('s3')->delete($message->image);
        }
        $data = $message->toArray();
        $chatRoomId = $message->chat_room_id;
        $message->delete();
        broadcast(new ChatUpdated($data,$chatRoomId,'delete'));
        return response()->json(['message' => "Pesan telah anda hapus", 'success' => true, 'data' => $message]);
    }
}
