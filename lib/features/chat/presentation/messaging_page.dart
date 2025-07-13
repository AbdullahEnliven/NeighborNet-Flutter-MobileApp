import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:neighbornet/features/chat/data/models/chat_model.dart';
import 'package:neighbornet/features/chat/data/models/message_model.dart';
import 'package:neighbornet/features/chat/data/repositories/firebasefirestore.dart';
import 'package:neighbornet/features/chat/data/repositories/storageservice.dart';

// ... [imports remain unchanged]

class MessagingPage extends StatefulWidget {
  final String chatuserid;
  final String chatusername;
  final String chatuserphoto;

  const MessagingPage({
    super.key,
    this.chatuserid = '',
    this.chatusername = '',
    this.chatuserphoto = '',
  });

  @override
  State<MessagingPage> createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  ChatUser? currentUser, otheruser;
  final user = FirebaseAuth.instance.currentUser;
  final database _databaseService = database();
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    currentUser = ChatUser(id: user!.uid, firstName: user!.displayName);
    otheruser = ChatUser(
      id: widget.chatuserid,
      firstName: widget.chatusername,
      profileImage: widget.chatuserphoto,
    );
    _databaseService.markMessageAsRead(currentUser!.id, otheruser!.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: ()async { 
        _databaseService.markMessageAsRead(currentUser!.id, otheruser!.id);
        return true;
       },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.chatusername, style: theme.appBarTheme.titleTextStyle),
              const SizedBox(height: 5),
              lastSeenWidget(),
            ],
          ),
          actions: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.chatuserphoto),
            ),
            const SizedBox(width: 10),
          ],
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        body: _buildChatUI(),
      ),
    );
  }

  Widget _buildChatUI() {
    return StreamBuilder(
      stream: _databaseService.getchatdata(currentUser!.id, otheruser!.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];

        if (chat != null && chat.messages != null) {
          messages = _generateMessages(chat.messages!);
        }

        final theme = Theme.of(context);

        return DashChat(
          messageOptions: MessageOptions(
            containerColor: theme.colorScheme.surface,
            showOtherUsersAvatar: true,
            showTime: true,
            textColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
          ),
          inputOptions: InputOptions(
            alwaysShowSend: true,
            trailing: [_mediaMessageButton()],
            sendButtonBuilder: (send) {
              return IconButton(onPressed: send, icon: const Icon(Icons.send));
            },
            inputDecoration: InputDecoration(
              hintText: "Type a message...",
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
              ),
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyMedium,
            ),
          ),
          currentUser: currentUser!,
          onSend: _sendMessage,
          messages: messages,
        );
      },
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
          read: false
        );
        await _databaseService.sendchatmsg(
          currentUser!.id,
          otheruser!.id,
          message,
        );
        _databaseService.onMessageSent(
          otheruser!.id,
          'Image',
          currentUser!.firstName!,
        );
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
        read: false
      );
      await _databaseService.sendchatmsg(
        currentUser!.id,
        otheruser!.id,
        message,
      );
      _databaseService.onMessageSent(
        otheruser!.id,
        chatMessage.text,
        currentUser!.firstName!,
      );
    }
  }

  List<ChatMessage> _generateMessages(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((e) {
      if (e.messageType == MessageType.Image) {
        return ChatMessage(
          user: e.senderID == currentUser!.id ? currentUser! : otheruser!,
          createdAt: e.sentAt!.toDate(),
          medias: [
            ChatMedia(url: e.content!, fileName: '', type: MediaType.image),
          ],
        );
      } else {
        return ChatMessage(
          user: e.senderID == currentUser!.id ? currentUser! : otheruser!,
          text: e.content!,
          createdAt: e.sentAt!.toDate(),
        );
      }
    }).toList();

    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: _pickImage,
      icon: Icon(
        Icons.image,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      ),
    );
  }

  void _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      String chatid = _databaseService.Generatedchatid(
        uid1: currentUser!.id,
        uid2: otheruser!.id,
      );
      String? downloadURL = await _storageService.uploadimg(
        file: File(pickedImage.path),
        Chatid: chatid,
      );
      if (downloadURL != null) {
        ChatMessage chatMessage = ChatMessage(
          user: currentUser!,
          createdAt: DateTime.now(),
          medias: [
            ChatMedia(url: downloadURL, fileName: '', type: MediaType.image),
          ],
        );
        _sendMessage(chatMessage);
      }
    }
  }

  Widget lastSeenWidget() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.chatuserid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var userProfile = snapshot.data;
          bool isOnline = userProfile!['isOnline'];
          Timestamp lastSeen = userProfile['lastSeen'];

          String lastSeenMessage;
          if (isOnline) {
            lastSeenMessage = 'Online';
          } else {
            DateTime lastSeenDateTime = lastSeen.toDate();
            DateTime now = DateTime.now();
            String formattedTime = DateFormat('HH:mm').format(lastSeenDateTime);

            if (now.difference(lastSeenDateTime).inDays == 0) {
              lastSeenMessage = 'Last seen today at $formattedTime';
            } else if (now.difference(lastSeenDateTime).inDays == 1) {
              lastSeenMessage = 'Last seen yesterday at $formattedTime';
            } else {
              String formattedDate = DateFormat('yMd').format(lastSeenDateTime);
              lastSeenMessage = 'Last seen on $formattedDate at $formattedTime';
            }
          }

          return Text(
            lastSeenMessage,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          );
        }
        return const SizedBox(
          height: 14,
          width: 14,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        );
      },
    );
  }
}
