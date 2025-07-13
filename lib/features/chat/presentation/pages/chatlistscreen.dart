import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/features/chat/data/repositories/firebasefirestore.dart';
import 'package:neighbornet/features/chat/presentation/messaging_page.dart';
import '../cubit/chat_list_cubit.dart';
import '../cubit/chat_list_state.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _database = database();
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    context.read<ChatListCubit>().loadUserChats();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Chats')),
      body: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatListLoaded) {
            if (state.chatList.isEmpty) {
              return const Center(child: Text("No chats yet"));
            }
            return ListView.builder(
              itemCount: state.chatList.length,
              itemBuilder: (context, index) {
                final chat = state.chatList[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: chat.otherUserImage != null
                        ? NetworkImage(chat.otherUserImage!)
                        : null,
                    child: chat.otherUserImage == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(chat.otherUserName),
                  subtitle: Text(chat.lastMessage ?? ''),
                  trailing: FutureBuilder<int>(
                    future: _database.getUnreadMessageCount(
                      user!.uid,
                      chat.otherUserId,
                    ),
                    builder: (context, snapshot) {
                      int unreadCount = snapshot.data ?? 0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Text(
                          //   chat.lastMessageTime == null
                          //       ? ''
                          //       : DateFormat.jm().format(
                          //           chat.lastMessageTime!.toDate(),
                          //         ),
                          //   style: const TextStyle(fontSize: 12),
                          // ),
                          if (unreadCount > 0)
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.red,
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MessagingPage(
                          chatuserid: chat.otherUserId,
                          chatusername: chat.otherUserName,
                          chatuserphoto: chat.otherUserImage ?? '',
                        ),
                      ),
                    );
                  
                  },
                );
              },
            );
          } else if (state is ChatListError) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
