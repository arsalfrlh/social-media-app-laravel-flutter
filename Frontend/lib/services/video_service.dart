import 'package:video_player/video_player.dart';

class VideoService {
  VideoPlayerController? _controller;

  Future<void> initVideo(String videoPath)async{
    _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse("http://10.0.2.2:9000/laravel/$videoPath"));
    await _controller?.initialize();
    _controller?.setLooping(true);
    _controller?.play();
  }

  VideoPlayerController? get controller => _controller;

  void play(){
    _controller?.play();
  }

  void pause(){
    _controller?.pause();
  }
}