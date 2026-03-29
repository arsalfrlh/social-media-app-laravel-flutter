import 'package:sosmed/models/user.dart';

class Comment {
  final int id;
  final String message;
  final User user;
  final DateTime? createAt;

  Comment({required this.id, required this.message, required this.user, this.createAt});
  factory Comment.fromJson(Map<String, dynamic> json){
    return Comment(
      id: json['id'],
      message: json['message'],
      user: User.fromJson(json['user']),
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null
    );
  }
}
