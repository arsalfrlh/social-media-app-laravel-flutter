class PostVideo {
  final int id;
  final String videoPath;
  final String thumbnailPath;
  final int duration;

  PostVideo({required this.id, required this.videoPath, required this.thumbnailPath, required this.duration});
  factory PostVideo.fromJson(Map<String, dynamic> json){
    return PostVideo(
      id: json['id'],
      videoPath: json['video_path'],
      thumbnailPath: json['thumbnail_path'],
      duration: json['duration']
    );
  }
}
