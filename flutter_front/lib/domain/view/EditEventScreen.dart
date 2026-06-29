import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_front/core/storage/secure_storage.dart';

class EditEventScreen extends StatefulWidget {
  final Map<String, dynamic> eventData;

  const EditEventScreen({super.key, required this.eventData});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final Color classicBlue = const Color(0xFFF7323F);
  final _storage = SecureStorage.instance;

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _locationController;
  late TextEditingController _maxParticipantsController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.eventData['title']?.toString() ?? '');
    _contentController = TextEditingController(text: widget.eventData['content']?.toString() ?? '');
    _locationController = TextEditingController(text: widget.eventData['location']?.toString() ?? '');
    _maxParticipantsController = TextEditingController(text: widget.eventData['maxParticipants']?.toString() ?? '');
    if (widget.eventData['startDate'] != null) {
      _startDate = DateTime.tryParse(widget.eventData['startDate'].toString());
    }
    if (widget.eventData['endDate'] != null) {
      _endDate = DateTime.tryParse(widget.eventData['endDate'].toString());
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitUpdate() async {
    final id = widget.eventData['id'];
    String? token = await _storage.getAccessToken();
    if (token == null) return;

    final String rawBaseUrl = dotenv.env['BASE_URL'] ?? '10.0.2.2';
    String baseUrl = rawBaseUrl.startsWith('http') ? rawBaseUrl : 'http://$rawBaseUrl';
    if (!baseUrl.contains(':8080')) baseUrl = '$baseUrl:8080';

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/events/$id'),
        headers: {
          "Content-Type": "application/json; charset=UTF-8",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "title": _titleController.text.trim(),
          "content": _contentController.text.trim(),
          "location": _locationController.text.trim(),
          "maxParticipants": int.tryParse(_maxParticipantsController.text) ?? 0,
          "startDate": _startDate?.toIso8601String(),
          "endDate": _endDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('수정되었습니다.')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("통신 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('행사 수정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _submitUpdate,
            child: Text('저장', style: TextStyle(color: classicBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextField(_titleController, '행사 제목'),
            const SizedBox(height: 16),
            _buildTextField(_locationController, '행사 장소'),
            const SizedBox(height: 16),
            _buildTextField(_maxParticipantsController, '모집 인원 (숫자)', isNumber: true),
            const SizedBox(height: 16),
            _buildDatePicker('시작일', _startDate, () => _pickDate(true)),
            const SizedBox(height: 16),
            _buildDatePicker('종료일', _endDate, () => _pickDate(false)),
            const SizedBox(height: 16),
            _buildTextField(_contentController, '상세 내용', maxLines: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          date == null ? '$label 선택' : '$label: ${date.toString().split(' ')[0]}',
          style: TextStyle(
            fontSize: 16,
            color: date == null ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, bool isNumber = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: classicBlue), borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}