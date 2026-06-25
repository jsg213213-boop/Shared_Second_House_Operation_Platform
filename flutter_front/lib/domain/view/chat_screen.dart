import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../shshare_house/Shared_Second_House_Operation_Platform/flutter_front/lib/domain/controller/chat_controller.dart';

class ChatScreen extends StatefulWidget { // StatefulWidget으로 변경
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
    // 화면이 다 그려진 후 채팅방 연결/구독 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().init(widget.roomId);
    });
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Text(msg.senderName, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                        ],
                      ),
                    ),
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
                      // 변경된 sendMessage 호출 방식
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