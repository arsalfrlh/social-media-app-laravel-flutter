import 'package:flutter/material.dart';
import 'package:sosmed/models/comment.dart';
import 'package:sosmed/services/api_service.dart';

class ReactionViewmodel extends ChangeNotifier {
  final apiService = ApiService();
  bool isLoading = false;
  String? message;

  Future<bool?> postReaction(int postId)async{
    final response = await apiService.reactPost(postId);
    return response['data'];
  }

  Future<bool?> followingUser(int userId)async{
    final response = await apiService.following(userId);
    return response['data'];
  }

  Future<Comment?> postComment(int postId, String message)async{
    final response = await apiService.sendComment(postId, message);
    if(response['success'] == true){
      return Comment.fromJson(response['data']);
    }
  }
}
