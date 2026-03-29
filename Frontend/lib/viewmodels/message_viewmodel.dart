import 'package:flutter/material.dart';
import 'package:sosmed/models/message.dart';
import 'package:sosmed/models/user.dart';
import 'package:sosmed/services/api_service.dart';
import 'package:sosmed/services/reverb_service.dart';

class MessageViewmodel extends ChangeNotifier {
  final _apiService = ApiService();
  final _reverbService = ReverbService();
  List<Message> messageList = [];
  List<User> userList = [];
  bool isLoading = false;
  User? currentUser;
  List<int> onlineUserId = [];

  Future<void> fetchChat() async {
    isLoading = true;
    userList = [];
    currentUser = null;
    notifyListeners();
    userList = await _apiService.getAllChat();
    currentUser = await _apiService.currentUser();
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMessage(int receiverId) async {
    isLoading = true;
    messageList = [];
    notifyListeners();
    // currentUser = await _apiService.currentUser();
    final response = await _apiService.getAllMessage(receiverId);
    _reverbService.disconnect();
    _reverbService.connect(response['chat_room_id']);
    _reverbService.onMessage = (data) => _handleMessage(data);
    _reverbService.onPresenceSync = (member) => _handleMemberOnline(member);
    _reverbService.onUserJoined = (member) => _handleUserJoin(member);
    _reverbService.onUserLeft = (member) => _handleUserLeft(member);
    messageList = (response['data'] as List).map((item) => Message.fromJson(item)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(int receiverId, String message, String? imagePath)async{
    isLoading = true;
    notifyListeners();
    await _apiService.sendMessage(receiverId, message, imagePath);
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateMessage(int messageId, String message, String? imagePath)async{
    isLoading = true;
    notifyListeners();
    await _apiService.updateMessage(messageId, message, imagePath);
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMessage(int messageId)async{
    await _apiService.deleteMessage(messageId);
  }

  void _handleMessage(Map<String, dynamic> data){
    final message = Message.fromJson(data['message']);
    final action = data['action'];
 
    if(action == "create"){
      messageList.add(message);
    }else if(action == "update"){
      final index = messageList.indexWhere((m) => m.id == message.id);
      if(index > -1){
        messageList[index] = message;
      }
    }else if(action == "delete"){
      final index = messageList.indexWhere((m) => m.id == message.id);
      if(index > -1){
        messageList.removeAt(index);
      }
    }
    notifyListeners();
  }

  void _handleMemberOnline(Map<String, dynamic> member){
    onlineUserId = member.values.map<int>((user) => user['id'] as int).toList();
    notifyListeners();
  }

  void _handleUserJoin(Map<String, dynamic> member){
    final userId = int.parse("${member['user_id']}");
    if(!onlineUserId.contains(userId)){
      onlineUserId.add(userId);
      notifyListeners();
    }
  }

  void _handleUserLeft(Map<String, dynamic> member){
    final userId = int.parse(member['user_id']);
    onlineUserId.remove(userId);
    notifyListeners();
  }

  bool isOnlineUserId(int userId){
    return onlineUserId.contains(userId);
  }

  @override
  void dispose() {
    _reverbService.disconnect();
    super.dispose();
  }
}
