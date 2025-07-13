import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/core/services/core/theme_cubit.dart';
import 'package:neighbornet/core/services/core/theme_state.dart';
import 'package:neighbornet/features/home/presentation/pages/edit_profile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  void _inviteNeighbors() {
    const inviteMessage =
        "👋 Hey! Join me on NeighborNet to connect with neighbors and stay updated!\n\n"
        "👉 Download the app: https://example.com/app-link";
    SharePlus.instance.share(ShareParams(text: inviteMessage));
  }

  void _logout() async {
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
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Logged Out")));
        context.go('/auth'); // Adjust according to your app's router
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person, color: theme.iconTheme.color),
            title: Text('Edit Profile', style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          SwitchListTile(
            title: Text(
              'Enable Notifications',
              style: theme.textTheme.bodyMedium,
            ),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() {
                _notificationsEnabled = val;
              });
            },
            secondary: Icon(Icons.notifications, color: theme.iconTheme.color),
            activeColor: theme.colorScheme.primary, // <- Fix for white thumb
            activeTrackColor: theme.colorScheme.primary.withOpacity(
              0.4,
            ), // Track color
          ),
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) {
              final isDarkMode = state.themeMode == ThemeMode.dark;

              return SwitchListTile(
                title: Text('Dark Mode', style: theme.textTheme.bodyMedium),
                value: isDarkMode,
                onChanged: (val) {
                  context.read<ThemeCubit>().toggleTheme(val);
                },
                secondary: Icon(Icons.dark_mode, color: theme.iconTheme.color),
                activeColor: theme.colorScheme.primary,
                activeTrackColor: theme.colorScheme.primary.withOpacity(0.4),
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.group_add, color: theme.iconTheme.color),
            title: Text('Invite Neighbors', style: theme.textTheme.bodyMedium),
            onTap: _inviteNeighbors,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: theme.dividerColor),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: theme.iconTheme.color),
            title: Text('Logout', style: theme.textTheme.bodyMedium),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
