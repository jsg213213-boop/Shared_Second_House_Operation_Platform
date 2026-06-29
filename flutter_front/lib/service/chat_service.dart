import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = "http://localhost:8080/api";

  Future<int> createRoom(String roomName, List<int> userIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dm/room'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'roomName': roomName, 'userIds': userIds}),
    );

    if (response.statusCode == 200) {
      return int.parse(response.body); // 생성된 roomId 반환
    } else {
      throw Exception('채팅방 생성 실패: ${response.statusCode}');
    }
  }
}
