<?php

namespace App\Jobs;

use App\Models\PostVideo;
use FFMpeg\Format\Video\X264;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Queue\SerializesModels;
use ProtoneMedia\LaravelFFMpeg\Support\FFMpeg;

//install library ffmpeg "composer require pbmedia/laravel-ffmpeg" | "php artisan vendor:publish --provider="ProtoneMedia\LaravelFFMpeg\Support\ServiceProvider""
class VideoUploadProcess implements ShouldQueue
{
    use Queueable, SerializesModels, Dispatchable;
    protected $postVideoId;

    /**
     * Create a new job instance.
     */
    public function __construct($postVideoId)
    {
        $this->postVideoId = $postVideoId;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        $video = PostVideo::find($this->postVideoId);
        $rawVideo = $video->video_path;
        $hlsPath = "post/reels/hls_" . $video->id;
        $m3u8Name = "playlist.m3u8";
        $format = new X264('aac', 'libx264');
        $format->setAudioCodec('aac');
        FFMpeg::fromDisk('s3')
            ->open($rawVideo)
            ->exportForHLS()
            ->setSegmentLength(10)
            ->addFormat($format)
            ->toDisk('s3')
            ->save($hlsPath . '/' . $m3u8Name);
        $duration = FFMpeg::fromDisk('s3')
            ->open($rawVideo)
            ->getDurationInSeconds();
        $video->update([
            'video_path' => $hlsPath . '/' . $m3u8Name,
            'duration' => $duration
        ]);
    }
}
