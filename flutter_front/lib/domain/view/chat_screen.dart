import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  final int myId;
  final String myName;
  final int roomId;
  final String roomName;

  const ChatScreen({
    super.key,
    required this.myId,
    required this.myName,
    required this.roomId,
    required this.roomName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().init(widget.roomId);
    });
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatController>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.roomName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: ctrl.messages.length,
              itemBuilder: (context, index) {
                final msg = ctrl.messages[index];
                final isMe = msg.senderId == widget.myId;
                final timeStr = _formatTime(msg.timestamp);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isMe)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(msg.senderName, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ),
                      Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isMe && timeStr.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.content,
                              style: TextStyle(color: isMe ? Colors.white : Colors.black),
                            ),
                          ),
                          if (!isMe && timeStr.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(timeStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(hintText: "메시지 입력..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      ctrl.sendMessage(widget.roomId, widget.myId, widget.myName, _textController.text);
                      _textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}