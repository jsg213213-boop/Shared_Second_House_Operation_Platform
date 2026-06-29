import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatService {
  StompClient? _stompClient;
  bool _isConnected = false;

  // ⚙️ [테스트 환경 스위치] 실물 기기 테스트 시 아래 주석을 바꾸세요!
  static const String _ipAddress = '10.0.2.2:8080';       // ① 에뮬레이터용
// static const String _ipAddress = '10.100.201.245:8080'; // ② 실물 스마트폰 및 리액트 연동 테스트 시

  final String _wsUrl = 'ws://$_ipAddress/ws-chat'; // 백엔드와 맞춘 경로

  void connectWebSocket({
    required int roomId,
    required Function(Map<String, dynamic>) onMessageReceived,
  }) {
    _stompClient = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: (frame) {
          _isConnected = true;
          print('✅ 연결 성공');
          // 특정 채팅방 구독
          _stompClient?.subscribe(
            destination: '/topic/chat/room/$roomId',
            callback: (frame) => onMessageReceived(jsonDecode(frame.body!)),
          );
        },
      ),
    );
    _stompClient?.activate();
  }

  void sendMessage(int roomId, int senderId, String senderName, String content) {
    _stompClient?.send(
      destination: '/app/chat/send', // 백엔드 매핑 경로
      body: jsonEncode({
        'chatRoomId': roomId,
        'senderId': senderId,
        'senderName': senderName,
        'content': content,
      }),
    );
  }

  void disconnect() {
    _stompClient?.deactivate();
  }
}