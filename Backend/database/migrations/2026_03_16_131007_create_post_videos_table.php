<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('post_videos', function (Blueprint $table) {
            $table->integer('id')->primary()->autoIncrement();
            $table->integer('post_id');
            $table->string('video_path');
            $table->string('thumbnail_path');
            $table->integer('duration')->default(0);
            $table->timestamps();

            $table->foreign('post_id')->on('posts')->references('id')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('post_videos');
    }
};
