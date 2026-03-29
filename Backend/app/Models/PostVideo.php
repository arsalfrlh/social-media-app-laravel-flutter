<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PostVideo extends Model
{
    protected $table = "post_videos";
    protected $fillable = ['post_id','video_path','thumbnail_path','duration'];
}
