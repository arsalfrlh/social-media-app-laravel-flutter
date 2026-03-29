import 'dart:async';
import 'dart:convert';
import 'package:sosmed/services/api_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ReverbService {
  final _apiService = ApiService();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  String? socketId;
  bool _isConnecting = false;

  Function(Map<String, dynamic>)? onMessage;
  Function(Map<String, dynamic>)? onPresenceSync;
  Function(Map<String, dynamic>)? onUserJoined;
  Function(Map<String, dynamic>)? onUserLeft;

  int? _currentChatRoomId;

  void connect(int chatRoomId) {
    if (_isConnecting) return;

    disconnect();
    _isConnecting = true;
    _currentChatRoomId = chatRoomId;
    final wsUrl ="ws://10.0.2.2:8080/app/fwu5zzprindi0hlvtl42?protocol=7&client=flutter&version=1.0";
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    _subscription = _channel!.stream.listen(
      (event) async {
        final data = jsonDecode(event);

        if (data['event'] == "pusher:connection_established") {
          final socketData = jsonDecode(data['data']);
          socketId = socketData['socket_id'];
          await _subscribe(chatRoomId);
        }

        if (data['event'] == 'pusher:ping') {
          _channel?.sink.add(jsonEncode({
            "event": "pusher:pong",
            "data": {}
          }));
        }

        if (data['event'] == 'pusher_internal:subscription_succeeded') {
          print("BERHASIL SUBSCRIBE");
          final presenceData = jsonDecode(data['data']);
          final members = presenceData['presence']['hash'];
          onPresenceSync?.call(members);
        }

        if (data['event'] == "pusher_internal:member_added") {
          final member = jsonDecode(data['data']);
          onUserJoined?.call(member);
        }

        if (data['event'] == "pusher_internal:member_removed") {
          final member = jsonDecode(data['data']);
          onUserLeft?.call(member);
        }

        if (data['event'] == "chatUpdate") {
          final payload = jsonDecode(data['data']);
          onMessage?.call(payload);
        }
      },

      onDone: () {
        print("WebSocket Closed");
        _isConnecting = false;
        _reconnect();
      },

      onError: (error) {
        print("WebSocket Error $error");
        _isConnecting = false;
        _reconnect();
      },
    );
  }

  Future<void> _subscribe(int chatRoomId) async {
    final response = await _apiService.authBroadcast(socketId, "presence-chat-room-$chatRoomId");
    _channel?.sink.add(jsonEncode({
      "event": "pusher:subscribe",
      "data": {
        "channel": "presence-chat-room-$chatRoomId",
        "auth": response['auth'],
        "channel_data": response['channel_data']
      }
    }));
  }

  void _reconnect() {
    if (_currentChatRoomId != null) {
      print("Reconnecting...");
      Future.delayed(Duration(seconds: 2), () {
        connect(_currentChatRoomId!);
      });
    }
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    socketId = null;
    _isConnecting = false;
    print("Disconnected");
  }
}