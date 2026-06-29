import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../dto/chat_message_dto.dart';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class ChatController extends ChangeNotifier {
  StompClient? _client;
  final List<ChatMessageDto> _messages = [];
  List<ChatMessageDto> get messages => _messages;

  final String _serverAddress = '10.100.201.245:8080';

  ChatController();

  String get _baseUrl => Platform.isAndroid
      ? 'http://10.0.2.2:8080'
      : 'http://$_serverAddress';

  Future<void> _loadPreviousMessages(int roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/dm/room/$roomId/messages'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        _messages.clear();
        for (var item in data) {
          _messages.add(ChatMessageDto(
            chatRoomId: item['chatRoomId'],
            senderId: item['senderId'] ?? 0,
            senderName: item['senderName'] ?? '익명',
            content: item['message'] ?? '',
            timestamp: item['createdDate'],
          ));
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint("이전 메시지 불러오기 실패: $e");
    }
  }

  void init(int roomId) {
    String url = Platform.isAndroid
        ? 'ws://10.0.2.2:8080/ws-guest-chat'
        : 'ws://$_serverAddress/ws-guest-chat';

    _client = StompClient(config: StompConfig(
      url: url,
      onConnect: (_) async {
        print("✅ 연결 성공: $url");

        await _loadPreviousMessages(roomId);

        _client?.subscribe(
            destination: '/topic/dm/room/$roomId',
            callback: (frame) {
              final Map<String, dynamic> data = jsonDecode(frame.body!);
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
          'message': text,
        })
    );
  }

  @override
  void dispose() {
    _client?.deactivate();
    super.dispose();
  }
}