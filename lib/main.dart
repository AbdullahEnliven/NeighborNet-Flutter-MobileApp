import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:neighbornet/core/services/core/theme_cubit.dart';
import 'package:neighbornet/features/auth/cubits/phone_auth_cubit.dart';
import 'package:neighbornet/features/chat/presentation/cubit/chat_list_cubit.dart';
import 'package:neighbornet/features/post/data/datasources/post_remote_datasource.dart';
import 'package:neighbornet/features/pushnotification/push_notification.dart';
import 'features/post/data/repositories/post_repository_impl.dart';
import 'features/post/domain/usecases/submit_post.dart';
import 'features/post/presentation/cubit/post_form_cubit.dart';
import 'features/user_profile/cubit/user_cubit.dart';
import 'features/user_profile/data/user_profiel_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final pushNotificationService = pushnotification();
  pushNotificationService.init();

  final message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
    Future.delayed(const Duration(seconds: 1), () {
      //nevegatorkey.currentState!.pushNamed("homepage", arguments: message);
    });
  }
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PostRepositoryImpl>(
          create: (_) => PostRepositoryImpl(
            FirebaseFirestore.instance,
            FirebaseStorage.instance,
            PostRemoteDataSourceImpl(),
          ),
        ),
        RepositoryProvider<SubmitPostUseCase>(
          create: (context) =>
              SubmitPostUseCase(context.read<PostRepositoryImpl>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PhoneAuthCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => UserCubit(userRepo)), // ✅ Only once
          BlocProvider(
            create: (_) => ChatListCubit(
              firestore: FirebaseFirestore.instance,
              auth: FirebaseAuth.instance,
            ),
          ),
          BlocProvider(
            create: (context) =>
                PostFormCubit(context.read<SubmitPostUseCase>()),
          ),
        ],

        child: const MyApp(),
      ),
    ),
  );
}

Future bgnotification(RemoteMessage message) async {
  if (message.notification != null) {}
}

final userRepo = UserProfileRepository();
