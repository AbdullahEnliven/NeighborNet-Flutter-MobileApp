import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/features/home/presentation/widgets/post_card.dart';
import 'package:neighbornet/features/user_profile/cubit/user_cubit.dart';
import 'package:neighbornet/features/user_profile/cubit/user_state.dart';
import '../widgets/app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> postOptions = [
    {'icon': Icons.help_outline, 'label': 'Ask for Help'},
    {'icon': Icons.card_giftcard, 'label': 'Giveaway Item'},
    {'icon': Icons.warning_amber, 'label': 'Alert'},
    {'icon': Icons.announcement, 'label': 'Announcement'},
    {'icon': Icons.volunteer_activism, 'label': 'Need Volunteers'},
  ];

  String selectedFilter = 'All';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const UserInfoBar(),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to NeighborNet 👋",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Stay informed. Stay involved. Stay neighborly!",
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
      
            Text("Filter Posts", style: textTheme.titleLarge),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: postOptions.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = index == 0
                      ? 'All'
                      : postOptions[index - 1]['label'];
                  final isSelected = selectedFilter == label;
                  return ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.black : null,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (_) => setState(() => selectedFilter = label),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UserLoaded) {
                  final userAddress = state.user.address.toLowerCase();
      
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
      
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No posts yet.'));
                      }
      
                      final allPosts = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data;
                      }).toList();
      
                      // Filter posts by neighborhood
                      final filteredByArea = allPosts.where((post) {
                        final postAddress =
                            post['address']?.toString().toLowerCase() ?? '';
                        return postAddress.contains(userAddress);
                      }).toList();
      
                      // Filter by selected post type
                      final filteredPosts = selectedFilter == 'All'
                          ? filteredByArea
                          : filteredByArea
                                .where(
                                  (post) =>
                                      post['postType'] == selectedFilter,
                                )
                                .toList();
      
                      if (filteredPosts.isEmpty) {
                        return const Center(
                          child: Text("No posts for your neighborhood."),
                        );
                      }
      
                      return ListView.builder(
                        itemCount: filteredPosts.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(0),
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) =>
                            PostCard(post: filteredPosts[index]),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text("Failed to load user info."),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
