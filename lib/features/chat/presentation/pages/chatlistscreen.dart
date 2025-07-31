import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/features/chat/data/repositories/firebasefirestore.dart';
import 'package:neighbornet/features/chat/presentation/messaging_page.dart';
import 'package:neighbornet/features/chat/presentation/widgets/chatlistshimmer.dart';
import 'package:shimmer/shimmer.dart';
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
            return ChatListShimmer();

            //  const Center(child: CircularProgressIndicator());
          } else if (state is ChatListLoaded) {
            if (state.chatList.isEmpty) {
              return const Center(child: Text("No chats yet"));
            }
            return ListView.builder(
              itemCount: state.chatList.length,
              itemBuilder: (context, index) {
                final chat = state.chatList[index];

                return ListTile(
                  leading: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: chat.otherUserImage ?? '',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          width: 48,
                          height: 48,
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
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
