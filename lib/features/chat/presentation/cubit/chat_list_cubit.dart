import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/features/chat/data/models/chat_tile_model.dart';
import 'package:neighbornet/features/chat/data/repositories/firebasefirestore.dart';
import 'chat_list_state.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ChatListCubit extends Cubit<ChatListState> {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final _database = database();
  StreamSubscription? _subscription;

  ChatListCubit({
    required this.firestore,
    required this.auth,
  }) : super(ChatListLoading());

  void loadUserChats() {
    final currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      emit(ChatListError("User not logged in"));
      return;
    }

    // Cancel previous stream if already active
    _subscription?.cancel();

    emit(ChatListLoading());

    _subscription = firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen((snapshot) async {
      List<ChatTileModel> chatList = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants']);
        final otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => '');

        if (otherUserId.isEmpty) continue;

        final userDoc = await firestore.collection('users').doc(otherUserId).get();
        if (!userDoc.exists) continue;
        final userData = userDoc.data()!;

        final lastMsg = await _database.getLastMessageContent(currentUserId, otherUserId);
        final lastMessageText = lastMsg;

        chatList.add(ChatTileModel(
          chatId: doc.id,
          otherUserId: otherUserId,
          otherUserName: userData['name'] ?? 'Unknown',
          otherUserImage: userData['photoUrl'],
          lastMessage: lastMessageText,
        ));
      }

      emit(ChatListLoaded(chatList));
    }, onError: (error) {
      emit(ChatListError("Stream error: $error"));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
