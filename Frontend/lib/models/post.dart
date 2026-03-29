import 'package:sosmed/models/comment.dart';
import 'package:sosmed/models/post_image.dart';
import 'package:sosmed/models/post_video.dart';
import 'package:sosmed/models/user.dart';

class Post {
  final int id;
  final String caption;
  final String type;
  int likeCount;
  int commentCount;
  bool liked;
  final DateTime? createAt;
  final User? user;
  final PostVideo? postVideo;
  final List<PostImage>? postImage;
  List<Comment>? comment;

  Post(
      {required this.id,
      required this.caption,
      required this.type,
      required this.commentCount,
      required this.likeCount,
      required this.liked,
      this.createAt,
      this.user,
      this.postVideo,
      this.postImage,
      required this.comment});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      caption: json['caption'],
      type: json['type'],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      liked: json['liked'] ?? false,
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      postVideo: json['post_video'] != null ? PostVideo.fromJson(json['post_video']) : null,
      postImage: json['post_image'] != null ? (json['post_image'] as List).map((item) => PostImage.fromJson(item)).toList() : null,
      comment: json['comment'] != null ? (json['comment'] as List).map((item) => Comment.fromJson(item)).toList() : null
    );
  }
}
