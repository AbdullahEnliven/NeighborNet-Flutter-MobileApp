import 'package:neighbornet/features/chat/data/models/chat_tile_model.dart';

abstract class ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatTileModel> chatList;
  ChatListLoaded(this.chatList);
}

class ChatListError extends ChatListState {
  final String message;
  ChatListError(this.message);
}
