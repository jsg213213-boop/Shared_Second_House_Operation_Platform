import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_front/core/storage/secure_storage.dart';
import 'EditEventScreen.dart';

class EventDetailScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EventDetailScreen({super.key, required this.eventData});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final Color classicBlue = const Color(0xFFF7323F);
  final _storage = SecureStorage.instance;

  Future<void> _deleteEvent(BuildContext context) async {
    final id = widget.eventData['id'];
    String? token = await _storage.getAccessToken();
    if (token == null) return;

    final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';
    String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';
    if (!baseUrl.contains(':8080')) baseUrl = '$baseUrl:8080';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제 확인'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await http.delete(
      Uri.parse('$baseUrl/api/events/$id'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('삭제되었습니다.')));
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.eventData['title']?.toString() ?? '제목 없음';
    final content = widget.eventData['content']?.toString() ?? '상세 내용 없음';
    final location = widget.eventData['location']?.toString() ?? '장소 미정';
    final startDate = widget.eventData['startDate']?.toString().split('T')[0] ?? '일시 미정';
    final endDate = widget.eventData['endDate']?.toString().split('T')[0] ?? '미정';
    final maxParticipants = widget.eventData['maxParticipants']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('행사 상세 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditEventScreen(eventData: widget.eventData),
                ),
              );
              if (result == true) Navigator.pop(context, true);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteEvent(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildInfoBox(location, startDate, endDate, maxParticipants),
            const SizedBox(height: 24),
            const Text('상세 내용', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(String location, String startDate, String endDate, String max) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _infoRow(CupertinoIcons.placemark, '장소', location),
          const Divider(height: 20),
          _infoRow(CupertinoIcons.calendar, '시작일', startDate),
          const Divider(height: 20),
          _infoRow(CupertinoIcons.calendar_today, '종료일', endDate),
          const Divider(height: 20),
          _infoRow(CupertinoIcons.person_2, '모집 정원', '$max 명'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: classicBlue),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}