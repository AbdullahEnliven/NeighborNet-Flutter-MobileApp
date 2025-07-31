import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neighbornet/features/pushnotification/push_notification.dart';

import '../user_profile/cubit/user_cubit.dart';
import '../user_profile/cubit/user_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    pushnotification.requestpermissions();
    storeFCMToken();
    _handleStartup();
  }

  Future<void> storeFCMToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await userDoc.update({'fcmToken': fcmToken});
    }
  }

  void _handleStartup() async {
    final user = FirebaseAuth.instance.currentUser;
    await Future.delayed(const Duration(seconds: 2));
    if (user != null) {
      context.read<UserCubit>().loadUser();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            // ✅ Only navigate when user data is loaded
            context.go('/home');
          } else if (state is UserError) {
            context.go('/auth');
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/splash.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const Align(
            alignment: Alignment.bottomCenter,
            child: LinearProgressIndicator(
              color: Colors.green,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
