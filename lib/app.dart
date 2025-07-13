import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neighbornet/core/services/core/theme_cubit.dart';
import 'package:neighbornet/core/services/core/theme_state.dart';
import 'package:neighbornet/router/app_router.dart';
import 'core/constants/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'NeighborNet',
          theme: AppTheme.lightTheme,   // Provide your light theme here
          darkTheme: AppTheme.darkTheme,
          themeMode: state.themeMode,   // Dynamically switches theme based on cubit state
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
