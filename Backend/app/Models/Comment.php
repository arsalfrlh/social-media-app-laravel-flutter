<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    protected $table = "comments";
    protected $fillable = ['user_id','post_id','message'];

    function user(){
        return $this->belongsTo(User::class,'user_id');
    }
}
