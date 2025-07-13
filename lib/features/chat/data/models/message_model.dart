import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: constant_identifier_names
enum MessageType { Text, Image }

class Message {
  String? senderID;
  String? content;
  MessageType? messageType;
  Timestamp? sentAt;
  bool? read;

  Message({
    required this.senderID,
    required this.content,
    required this.messageType,
    required this.sentAt,
    required this.read,
  });

  Message.fromJson(Map<String, dynamic> json) {
    senderID = json['senderID'];
    content = json['content'];
    sentAt = json['sentAt'];
    messageType = MessageType.values.byName(json['messageType']);
    read = json['read'] ?? false; 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderID'] = senderID;
    data['content'] = content;
    data['sentAt'] = sentAt;
    data['messageType'] = messageType!.name;
    data['read'] = read ?? false; 
    return data;
  }
}