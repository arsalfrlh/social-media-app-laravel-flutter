import 'package:sosmed/models/follow.dart';
import 'package:sosmed/models/post.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String? bio;
  final String? profile;
  final DateTime? createAt;
  final DateTime? updateAt;
  bool followed;
  int followersCount;
  int followingCount;
  List<Follow> followList;
  List<Post> postList;

  User({required this.id, required this.name, required this.email, this.bio, this.profile, this.createAt, this.updateAt, required this.followed, required this.followersCount, required this.followingCount, required this.followList, required this.postList});
  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      bio: json['bio'],
      profile: json['profile'],
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updateAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      followed: json['followed'] ?? false,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      followList: json['following'] != null ? (json['following'] as List).map((item) => Follow.fromJson(item)).toList() : [],
      postList: json['post'] != null ? (json['post'] as List).map((item) => Post.fromJson(item)).toList() : []
    );
  }
}
