import 'package:sosmed/models/user.dart';

class Message {
  final int id;
  final String message;
  final String? image;
  final DateTime? createAt;
  final bool isMe;
  final User user;

  Message({required this.id, required this.message, this.image, this.createAt, required this.isMe, required this.user});
  factory Message.fromJson(Map<String, dynamic> json){
    return Message(
      id: json['id'],
      message: json['message'],
      image: json['image'],
      createAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      isMe: json['is_me'] ?? false,
      user: User.fromJson(json['user'])
    );
  }
}
