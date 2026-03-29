<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Follow extends Model
{
    protected $table = "follows";
    protected $fillable = ['follower_id','following_id'];

    function follower(){
        return $this->belongsTo(User::class,'follower_id');
    }

    function user(){
        return $this->belongsTo(User::class,'following_id');
    }
}
