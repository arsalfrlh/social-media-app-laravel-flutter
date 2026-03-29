import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sosmed/models/comment.dart';
import 'package:sosmed/models/post.dart';
import 'package:sosmed/models/user.dart';
import 'package:sosmed/services/api_service.dart';
import 'package:sosmed/services/video_service.dart';
import 'package:video_player/video_player.dart';

class PostViewmodel extends ChangeNotifier {
  final _apiService = ApiService();
  final _videoService = VideoService();
  bool isLoading = false;
  String? message;
  List<Post> postList = [];
  User? currentUser;
  Post? currentPost;
  bool isPlaying = false;
  bool isInitialize = false;
  final _pageController = PageController();

  VideoPlayerController? get controller => _videoService.controller;
  PageController get pageController => _pageController;

  Future<void> fetchPost() async {
    isLoading = true;
    notifyListeners();
    postList = await _apiService.getAllPost();
    currentUser = await _apiService.currentUser();
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchReels() async {
    isLoading = true;
    notifyListeners();
    currentUser = await _apiService.currentUser();
    postList = await _apiService.getAllReels();
    if(postList.isNotEmpty){
      // await playReels(postList[0]);
      await playReels(postList.first);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> showPost(int postId)async{
    currentPost = null;
    isLoading = true;
    notifyListeners();
    currentPost = await _apiService.showPost(postId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> showAllPostUser(int userId, String page, int selectedPage)async{
    isLoading = true;
    notifyListeners();
    currentUser = await _apiService.currentUser();
    postList = await _apiService.showAllPostUser(userId, page);
    if(page == "reels"){
      await playReels(postList[selectedPage]);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadPost(String caption, String type, List<String> imagePath, String? videoPath, String? thumbnailPath)async{
    isLoading = true;
    message = null;
    notifyListeners();
    final response = await _apiService.uploadPost(caption, type, imagePath, videoPath, thumbnailPath);
    isLoading = false;
    message = response['message'];
    notifyListeners();
    return(response['success'] as bool);
  }

  void onReaction(bool liked, int index){
    postList[index].liked = liked;
    if(liked){
      postList[index].likeCount = postList[index].likeCount + 1;
    }else{
      postList[index].likeCount = postList[index].likeCount - 1;
    }
    notifyListeners();
  }
  
  void onFollowed(bool followed, User user){
    for (var p in postList) {
      if (p.user?.id == user.id) {
        p.user?.followed = followed;
      }
    }
    notifyListeners();
  }

  void onComment(Comment comment){
    currentPost?.comment?.add(comment);
    final index = postList.indexWhere((p) => p.id == currentPost?.id);
    if(index != -1){
      postList[index].commentCount = postList[index].commentCount + 1;
      postList[index].comment?.add(comment);
    }
    notifyListeners();
  }

  Future<void> playReels(Post postReels)async{
    _videoService.controller?.removeListener(videoListener);
    _videoService.controller?.dispose();
    isPlaying = false;
    isInitialize = false;
    currentPost = postReels;
    notifyListeners();
    await _videoService.initVideo(postReels.postVideo!.videoPath);
    isPlaying = _videoService.controller?.value.isPlaying ?? false;
    isInitialize = _videoService.controller?.value.isInitialized ?? false;
    _videoService.controller?.addListener(videoListener);
    notifyListeners();
  }

  void videoListener(){
    isPlaying = _videoService.controller?.value.isPlaying ?? false;
    isInitialize = _videoService.controller?.value.isInitialized ?? false;
    notifyListeners();
  }

  void pauseVideo() {
    _videoService.pause();
  }

  void resumeVideo() {
    _videoService.play();
  }

  @override
  void dispose() {
    _videoService.controller?.removeListener(videoListener);
    _videoService.controller?.dispose();
    pageController.dispose();
    super.dispose();
  }
}
