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
        Schema::create('follows', function (Blueprint $table) {
            $table->integer('id')->primary()->autoIncrement();
            $table->integer('follower_id');
            $table->integer('following_id');
            $table->timestamps();

            $table->foreign('follower_id')->on('users')->references('id')->onDelete('cascade')->onUpdate('cascade');
            $table->foreign('following_id')->on('users')->references('id')->onDelete('cascade')->onUpdate('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('follows');
    }
};
