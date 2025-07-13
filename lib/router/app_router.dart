import 'package:go_router/go_router.dart';
import 'package:neighbornet/features/auth/screens/phone_auth.dart';
import 'package:neighbornet/features/home/presentation/pages/home_page.dart';
import 'package:neighbornet/features/splashscreen/splashscreen.dart';
import 'package:neighbornet/features/user_profile/screens/profile_screen.dart';


class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/',builder: (context,state)=> SplashScreen()),
      GoRoute(path: '/userprofile', builder: (context, state) => ProfileScreen()),
      GoRoute(path: '/auth', builder: (context, state) => PhoneAuthScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomePage()
      ),

      // Add more routes here (e.g., /login, /home)
    ],
  );
}
