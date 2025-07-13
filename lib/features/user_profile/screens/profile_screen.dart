import 'package:flutter/material.dart';
import '../widgets/profile_form.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppBar(title: const Text("Complete Profile")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ProfileForm(),
      ),
    );
  }
}