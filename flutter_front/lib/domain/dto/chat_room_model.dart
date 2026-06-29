class ChatRoomCreateRequest {
  final String roomName;
  final List<int> userIds;

  ChatRoomCreateRequest({required this.roomName, required this.userIds});

  Map<String, dynamic> toJson() => {
    'roomName': roomName,
    'userIds': userIds,
  };
}
