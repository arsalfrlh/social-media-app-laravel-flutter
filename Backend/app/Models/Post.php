<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Post extends Model
{
    protected $table = "posts";
    protected $fillable = ['user_id','caption','type'];

    function user(){
        return $this->belongsTo(User::class,'user_id');
    }

    function postImage(){
        return $this->hasMany(PostImage::class,'post_id');
    }

    function postVideo(){
        return $this->hasOne(PostVideo::class,'post_id');
    }

    function likedBy(){
        return $this->belongsToMany(User::class,'likes','post_id','user_id');
    }

    function like(){
        return $this->hasMany(Like::class,'post_id');
    }

    function comment(){
        return $this->hasMany(Comment::class,'post_id');
    }
}
