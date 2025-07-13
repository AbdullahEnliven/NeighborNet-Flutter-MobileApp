import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:neighbornet/features/home/presentation/pages/edit_profile.dart';
import 'package:neighbornet/features/home/presentation/pages/settings.dart';
import 'package:neighbornet/features/user_profile/cubit/user_cubit.dart';
import 'package:neighbornet/features/user_profile/cubit/user_state.dart';

class UserInfoBar extends StatelessWidget {
  const UserInfoBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          final bool isUserLoaded = state is UserLoaded;
          final String userName = isUserLoaded ? state.user.name : '';
          final String? photoUrl = isUserLoaded ? state.user.photoUrl : null;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context).cardColor,
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: photoUrl,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (_, __, ___) =>
                                    const Icon(Icons.error, size: 20),
                              ),
                            )
                          : const Icon(Icons.person, size: 20),
                    ),

                    const SizedBox(width: 10),
                    if (isUserLoaded)
                      Text(
                        'Hello, $userName',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsPage(),
                          ), // Replace with your settings screen
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
