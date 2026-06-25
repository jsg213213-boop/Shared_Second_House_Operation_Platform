import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../dto/chat_message_dto.dart';
import 'dart:convert';
import 'dart:io' show Platform;

class ChatController extends ChangeNotifier {
  StompClient? _client;
  final List<ChatMessageDto> _messages = [];
  List<ChatMessageDto> get messages => _messages;

  final String _serverAddress = '10.100.201.245:8080';

  ChatController();

  void init(int roomId) {
    String url = (Platform.isAndroid && !Platform.isIOS)
        ? 'ws://10.0.2.2:8080/ws-chat'
        : 'ws://$_serverAddress/ws-chat';

    _client = StompClient(config: StompConfig(
      url: url,
      onConnect: (_) {
        print("✅ 연결 성공: $url");
        _client?.subscribe(
            destination: '/topic/dm/room/$roomId',
            callback: (frame) {
              final Map<String, dynamic> data = jsonDecode(frame.body!);
              // 데이터 파싱 후 리스트 추가
              _messages.add(ChatMessageDto.fromJson(data));
              notifyListeners();
            }
        );
      },
    ));
    _client?.activate();
  }

  void sendMessage(int roomId, int myId, String myName, String text) {
    if (_client == null || !_client!.isActive) return;

    _client?.send(
        destination: '/app/dm/chat/send',
        body: jsonEncode({
          'chatRoomId': roomId,
          'senderId': myId,
          'senderName': myName, // 서버로 전송
          'message': text,      // 서버 DTO의 'message' 필드와 일치
        })
    );
  }

  @override
  void dispose() {
    _client?.deactivate();
    super.dispose();
  }
}