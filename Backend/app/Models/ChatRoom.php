<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ChatRoom extends Model
{
    protected $table = 'chat_rooms';
    protected $fillable = ['sender_id','receiver_id'];
}
