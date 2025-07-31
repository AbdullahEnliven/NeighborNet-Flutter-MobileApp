import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import '../cubit/nav_bar_cubit.dart';
import '../../../post/presentation/widgets/post_options.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavCubit, int>(
      builder: (context, currentIndex) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        return ConvexAppBar(
          style: TabStyle.fixedCircle,
          backgroundColor: colorScheme.surface,
          color: isDark ? Colors.grey[500] : Colors.grey[700],
          activeColor: colorScheme.primary,
          items: const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.message, title: 'Chats'),
            TabItem(icon: Icons.add, title: ''),
            TabItem(icon: Icons.feed, title: 'Posts'),
            TabItem(icon: Icons.person, title: 'Profile'),
          ],
          initialActiveIndex: currentIndex,
          onTap: (index) {
            if (index == 2) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                backgroundColor: theme.scaffoldBackgroundColor,
                builder: (_) => const PostOptionsSheet(),
              );
            } else {
              context.read<BottomNavCubit>().changeTab(index);
            }
          },
        );
      },
    );
  }
}
