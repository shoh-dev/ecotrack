import 'package:flutter/material.dart';

// Placeholder screen for user profile and settings.
// It's a StatelessWidget as its state will be managed by a ViewModel.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // AppBar is optional here if using a main Scaffold with BottomNavigationBar
      // appBar: AppBar(
      //   title: const Text('Your Profile'),
      // ),
      body: Center(
        child: Text(
          'Profile Screen - Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
