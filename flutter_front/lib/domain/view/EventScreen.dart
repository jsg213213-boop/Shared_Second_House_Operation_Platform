import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_front/core/storage/secure_storage.dart';
import 'EventDetailScreen.dart';
import 'WriteEventScreen.dart' show EventRegisterScreen;

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final Color classicBlue = const Color(0xFFF7323F);
  List<dynamic> events = [];
  final _storage = SecureStorage.instance;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    String? token = await _storage.getAccessToken();
    if (token == null) return;

    final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';
    String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';
    if (!baseUrl.contains(':8080')) baseUrl = '$baseUrl:8080';

    final String finalUrl = '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}api/events';

    final response = await http.get(
      Uri.parse(finalUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        events = jsonDecode(utf8.decode(response.bodyBytes));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('진행 중인 행사', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EventRegisterScreen()),
          ).then((_) => fetchEvents());
        },
        backgroundColor: const Color(0xFF2D6A4F),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: events.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) => _buildEventCard(events[index]),
      ),
    );
  }

  Widget _buildEventCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(item['title'] ?? '제목 없음',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('장소: ${item['location'] ?? '미정'}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            Text('일시: ${item['startDate']?.toString().substring(0, 10) ?? ''}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
        trailing: const Icon(CupertinoIcons.chevron_forward, size: 16, color: Colors.grey),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(eventData: item),
            ),
          );
          if (result == true) fetchEvents();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.calendar, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('현재 진행 중인 행사가 없습니다.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}