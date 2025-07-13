import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to NeighborNet')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.push('/login');
          },
          child: const Text('Get Started'),
        ),
      ),
    );
  }
}
