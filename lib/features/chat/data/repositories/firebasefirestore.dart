import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neighbornet/features/chat/data/models/chat_model.dart';
import 'package:neighbornet/features/chat/data/models/message_model.dart';
import 'package:neighbornet/features/pushnotification/send_notfication.dart';
import 'package:neighbornet/features/user_profile/domain/models/user_profile_model.dart';

// ignore: camel_case_types
class database {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference<UserProfile>? _usercollection;
  late CollectionReference<Chat> _chatcollection;

  database() {
    setupcollectionref();
  }

  void setupcollectionref() {
    _usercollection = _firestore
        .collection('users')
        .withConverter<UserProfile>(
          fromFirestore: (snapshots, _) =>
              UserProfile.fromMap(snapshots.data()!),
          toFirestore: (userprofile, _) => userprofile.toMap(),
        );
    _chatcollection = FirebaseFirestore.instance
        .collection('chats')
        .withConverter<Chat>(
          fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
          toFirestore: (chat, _) => chat.toJson(),
        );
  }
  Future<void> deletePost(String postId) async {
  await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
}

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _usercollection?.doc(uid).update(data);
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await _usercollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile>> getUserProfiles() {
    return _usercollection!
        .where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  Future<bool> checkuserid(String uid1, String uid2) async {
    // ignore: non_constant_identifier_names
    String Chatid = Generatedchatid(uid1: uid1, uid2: uid2);
    final result = await _chatcollection.doc(Chatid).get();

    return result.exists;
  }

  // ignore: non_constant_identifier_names
  String Generatedchatid({required String uid1, required String uid2}) {
    List uids = [uid1, uid2];
    uids.sort();
    // ignore: non_constant_identifier_names
    String Chatid = uids.fold('', (id, uid) => "$id$uid");
    return Chatid;
  }

  Future<void> createnewchat(String uid1, String uid2) async {
    String chatid = Generatedchatid(uid1: uid1, uid2: uid2);
    final docref = _chatcollection.doc(chatid);
    final chat = Chat(id: chatid, participants: [uid1, uid2], messages: [], lastMessageTime: Timestamp.now());
    await docref.set(chat);
  }

  Future<void> sendchatmsg(String uid1, String uid2, Message message) async {
    String chatid = Generatedchatid(uid1: uid1, uid2: uid2);
    final docref = _chatcollection.doc(chatid);
    await docref.update({
      "messages": FieldValue.arrayUnion([message.toJson()]),
      'lastMessageTime': message.sentAt
    });
  }

  Stream<DocumentSnapshot<Chat>> getchatdata(String uid1, String uid2) {
    String chatid = Generatedchatid(uid1: uid1, uid2: uid2);
    return _chatcollection.doc(chatid).snapshots();
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _usercollection?.doc(uid).get();
    return doc?.data();
  }

  String generateMessageId(String senderID, String receiverID) {
    Timestamp timestamp = Timestamp.now();
    return '$senderID-$receiverID-${timestamp.seconds}-${timestamp.nanoseconds}';
  }

  void setUserOnline(String userId) {
    _firestore.collection('users').doc(userId).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  void setUserOffline(String userId) {
    _firestore.collection('users').doc(userId).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<Message?> getLastMessage(String uid1, String uid2) async {
    try {
      final chatId = Generatedchatid(uid1: uid1, uid2: uid2);
      final chatDocRef = _chatcollection.doc(chatId);
      final chatSnapshot = await chatDocRef.get();
      if (chatSnapshot.exists) {
        final chat = chatSnapshot.data();
        final messages = chat?.messages;
        if (messages != null && messages.isNotEmpty) {
          final lastMessage = messages.reduce(
            (curr, next) => (curr.sentAt != null && next.sentAt != null)
                ? curr.sentAt!.compareTo(next.sentAt!) > 0
                      ? curr
                      : next
                : curr.sentAt != null
                ? curr
                : next,
          );
          return lastMessage;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      null;
      return null;
    }
  }

  Future<int> getUnreadMessageCount(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final chatId = Generatedchatid(uid1: currentUserId, uid2: otherUserId);

      final chatDocRef = _chatcollection.doc(chatId);
      final chatSnapshot = await chatDocRef.get();
      if (chatSnapshot.exists) {
        final chat = chatSnapshot.data();
        final unreadMessages =
            chat?.messages
                ?.where(
                  (message) =>
                      message.read == false && message.senderID == otherUserId,
                )
                .length ??
            0;

        return unreadMessages;
      } else {
        return 0;
      }
    } catch (e) {
      return 0;
    }
  }

  Future<void> markMessageAsRead(
    String currentUserId,
    String otherUserId,
  ) async {
    try {
      final chatId = Generatedchatid(uid1: currentUserId, uid2: otherUserId);
      final chatDocRef = _chatcollection.doc(chatId);
      final chatSnapshot = await chatDocRef.get();
      if (chatSnapshot.exists) {
        final chat = chatSnapshot.data();
        final messages = chat?.messages;
        if (messages != null) {
          for (var message in messages) {
            if (message.senderID == otherUserId && message.read == false) {
              message.read = true;
            }
          }
          final updatedMessages = messages
              .map((message) => message.toJson())
              .toList();
          await chatDocRef.update({'messages': updatedMessages});
        }
      }
    } catch (e) {
      null;
    }
  }

  Future<String> getLastMessageContent(
    String currentUserId,
    String otherUserId,
  ) async {
    var lastMessage = await getLastMessage(currentUserId, otherUserId);
    if (lastMessage != null) {
      if (lastMessage.messageType == MessageType.Image) {
        return 'Image';
      } else {
        return lastMessage.content ?? 'No messages';
      }
    }
    return 'No messages';
  }

  Future<String?> getFcmTokenByUid(String uid) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        String? fcmToken = userSnapshot.data()?['fcmToken'];
        return fcmToken;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void onMessageSent(
    String receiverId,
    String messageText,
    String title,
  ) async {
    final token = await getFcmTokenByUid(receiverId);
    String? receiverToken = token;
    if (receiverToken != null) {
      await SendNotification.sendPushNotification(
        fcmToken: receiverToken,
        title: title,
        message: messageText,
      );
    }
  }

  Future<List<String>> fetchMessageIds(String chatId) async {
    List<String> messageIds = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        messageIds = querySnapshot.docs.map((doc) => doc.id).toList();
      }
    } catch (e) {
      null;
    }

    return messageIds;
  }
}
