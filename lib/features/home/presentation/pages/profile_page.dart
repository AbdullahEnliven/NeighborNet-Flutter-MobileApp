import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbornet/features/home/presentation/pages/edit_profile.dart';
import 'package:neighbornet/features/home/presentation/pages/mypost.dart';
import 'package:neighbornet/features/home/presentation/pages/settings.dart';
import 'package:neighbornet/features/user_profile/cubit/user_cubit.dart';
import 'package:neighbornet/features/user_profile/cubit/user_state.dart';
import 'package:share_plus/share_plus.dart';

class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  void _editProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );
  }

  void _inviteNeighbors(BuildContext context) {
    final String appName = "NeighborNet";
    final String inviteMessage =
        "👋 Hey! I'm using $appName to connect with people in our neighborhood. "
        "Join me and stay updated with local alerts, giveaways, and announcements!\n\n"
        "👉 Download the app: https://example.com/app-link"; // Replace with actual link
    SharePlus.instance.share(ShareParams(text: inviteMessage));
  }

  void _openMyPosts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyPostsPage()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  void _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();

        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text("Logged Out")));

        // ignore: use_build_context_synchronously
        context.go('/auth'); // Adjust this to match your GoRouter route
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: ${e.toString()}")),
        );
      }
    }
  }

  String _extractMainAddress(String? location) {
    if (location == null || location.trim().isEmpty) return "No location set";
    final parts = location.split('-');
    return parts.length > 1 ? parts[1].trim() : location.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoaded) {
            final user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 80),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: theme.cardColor,
                          child:
                              user.photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.photoUrl,
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) =>
                                        const CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                    errorWidget: (_, __, ___) => Icon(
                                      Icons.error,
                                      size: 50,
                                      color: colorScheme.error,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  // ignore: deprecated_member_use
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                        ),

                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _editProfile(context),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: colorScheme.primary,
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // User Name
                  Text(
                    user.name,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Location
                  Text(
                    _extractMainAddress(user.address),
                    style: textTheme.bodySmall?.copyWith(
                      // ignore: deprecated_member_use
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  // Edit Profile Button
                  TextButton.icon(
                    onPressed: () => _editProfile(context),
                    icon: Icon(Icons.edit, color: colorScheme.primary),
                    label: Text(
                      "Edit Profile",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),

                  // ignore: deprecated_member_use
                  Divider(color: colorScheme.surfaceVariant),

                  _buildOption(
                    Icons.group_add,
                    "Invite Neighbors",
                    () => _inviteNeighbors(context),
                    theme,
                  ),
                  _buildOption(
                    Icons.post_add,
                    "My Posts",
                    () => _openMyPosts(context),
                    theme,
                  ),
                  _buildOption(
                    Icons.settings,
                    "Settings",
                    () => _openSettings(context),
                    theme,
                  ),
                  _buildOption(
                    Icons.logout,
                    "Logout",
                    () => _logout(context),
                    theme,
                    isLogout: true,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "App version 1.0.0",
                    style: textTheme.bodySmall?.copyWith(
                      // ignore: deprecated_member_use
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          // Show loading or error
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildOption(
    IconData icon,
    String title,
    VoidCallback onTap,
    ThemeData theme, {
    bool isLogout = false,
  }) {
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : theme.textTheme.bodyMedium?.color,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
