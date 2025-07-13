import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_model.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;
  Timestamp? lastMessageTime;
  Chat({required this.id, required this.participants, required this.messages, required this.lastMessageTime});

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    participants = List<String>.from(json['participants']);
    messages = List.from(
      json['messages'],
    ).map((m) => Message.fromJson(m)).toList();
    lastMessageTime = json['lastMessageTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participants'] = participants;
    data['messages'] = messages?.map((m) => m.toJson()).toList() ?? [];
    data['lastMessageTime'] = lastMessageTime;
    return data;
  }
}
