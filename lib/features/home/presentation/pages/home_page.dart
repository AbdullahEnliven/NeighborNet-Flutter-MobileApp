import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/features/chat/data/repositories/firebasefirestore.dart';
import 'package:neighbornet/features/chat/presentation/pages/chatlistscreen.dart';
import 'package:neighbornet/features/home/presentation/pages/home_screen.dart';
import 'package:neighbornet/features/home/presentation/pages/mypost.dart';
import 'package:neighbornet/features/home/presentation/pages/profile_page.dart';
import '../cubit/nav_bar_cubit.dart';

import '../widgets/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser;
  final List<Widget> _screens = const [
    HomeScreen(),
    ChatListScreen(),

    Center(child: Text('Add Post')),
    MyPostsPage(),
    ProfileTabPage(),
  ];
  final _database = database();
  bool _isOnline = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (user != null) {
      _database.setUserOnline(user!.uid);
    }
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (user == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _setUserOnline();

        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _setUserOffline();

        break;
    }
  }

  void _setUserOnline() {
    if (!_isOnline) {
      _database.setUserOnline(user!.uid);
      _isOnline = true;
    }
  }

  void _setUserOffline() {
    if (_isOnline) {
      _database.setUserOffline(user!.uid);
      _isOnline = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setUserOffline();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BottomNavCubit(),
      child: BlocBuilder<BottomNavCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            body: _screens[currentIndex],
            bottomNavigationBar: const CustomBottomNavBar(),
          );
        },
      ),
    );
  }
}
