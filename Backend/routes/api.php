<?php

use App\Http\Controllers\AuthApiController;
use App\Http\Controllers\CommentApiController;
use App\Http\Controllers\FollowerApiController;
use App\Http\Controllers\LikeApiController;
use App\Http\Controllers\MessageApiController;
use App\Http\Controllers\PostApiController;
use App\Http\Controllers\UserApiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Broadcast;
use Illuminate\Support\Facades\Route;

Route::post('/login',[AuthApiController::class,'login'])->middleware('throttle:login');
Route::post('/register',[AuthApiController::class,'register'])->middleware('throttle:register');

Route::middleware(['auth:sanctum'])->group(function(){
    Route::apiResource('/post',PostApiController::class);
    Route::get('/reels',[PostApiController::class,'indexReels']);
    Route::apiResource('/reaction',LikeApiController::class)->middleware('throttle:interaction');
    Route::apiResource('/follow',FollowerApiController::class)->middleware('throttle:interaction');
    Route::apiResource('/comment',CommentApiController::class)->middleware('throttle:interaction');
    Route::apiResource('/message',MessageApiController::class)->middleware('throttle:message');
    Route::apiResource('/user',UserApiController::class);
    Route::get('/user/post/{id}',[UserApiController::class,'postUser']);
    Route::post('/logout',[AuthApiController::class,'logout']);
});

Broadcast::routes(['middleware' => ['auth:sanctum']]);