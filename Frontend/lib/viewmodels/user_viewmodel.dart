import 'package:flutter/material.dart';
import 'package:sosmed/models/user.dart';
import 'package:sosmed/services/api_service.dart';

class UserViewmodel extends ChangeNotifier {
  final _apiService = ApiService();
  User? mainUser;
  User? user;
  bool isLoading = false;
  String? message;

  Future<void> currentUser(String page) async {
    isLoading = true;
    notifyListeners();
    mainUser = await _apiService.currentUser(page: page); //page = "post" / "reels"
    isLoading = false;
    notifyListeners();
  }

  Future<void> showUser(int userId, String page) async {
    isLoading = true;
    notifyListeners();
    mainUser = await _apiService.currentUser();
    user = await _apiService.showUser(userId: userId, page: page);
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateUser(int userId, String name, String email, String bio, String? profilePath)async{
    isLoading = true;
    message = null;
    notifyListeners();
    final response = await _apiService.updateUser(userId, name, email, bio, profilePath);
    message = response['message'];
    isLoading = false;
    notifyListeners();
    return(response['success'] as bool);
  }

  Future<void> logout()async{
    await _apiService.logout();
  }

  void onFollowed(bool followed){
    user?.followed = followed;
    if(followed){
      user?.followersCount += 1;
    }else{
      user?.followersCount += -1;
    }
    notifyListeners();
  }
}
