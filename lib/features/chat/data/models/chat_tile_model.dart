class ChatTileModel {
  final String chatId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;
  final String? lastMessage;

  ChatTileModel({
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
    this.lastMessage,
  });
}
