import 'package:firebase_auth/firebase_auth.dart';

class UserId {
  static String? get uid {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}