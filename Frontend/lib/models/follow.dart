import 'package:sosmed/models/user.dart';

class Follow {
  final int id;
  final User user;

  Follow({required this.id, required this.user});
  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'],
      user: User.fromJson(json['user'])
    );
  }
}
