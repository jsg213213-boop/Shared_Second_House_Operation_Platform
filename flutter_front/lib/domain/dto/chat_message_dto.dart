class ChatMessageDto {
  final int? chatRoomId;
  final int senderId;
  final String senderName;
  final String content;    // 화면에 보여줄 메시지 내용
  final String? timestamp;

  ChatMessageDto({
    this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.timestamp,
  });

  factory ChatMessageDto.fromJson(Map<String, dynamic> json) {
    return ChatMessageDto(
      chatRoomId: (json['chatRoomId'] as num?)?.toInt(),
      senderId: (json['senderId'] as num?)?.toInt() ?? 0,
      senderName: json['senderName'] ?? '익명',
      // 백엔드의 'message' 필드를 'content'로 매핑
      content: json['message'] ?? json['content'] ?? '',
      timestamp: json['timestamp'],
    );
  }
}
