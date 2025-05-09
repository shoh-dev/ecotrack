import 'package:flutter/material.dart';

// Placeholder screen for setting and tracking goals.
// It's a StatelessWidget as its state will be managed by a ViewModel.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // AppBar is optional here if using a main Scaffold with BottomNavigationBar
      // appBar: AppBar(
      //   title: const Text('Your Goals'),
      // ),
      body: Center(
        child: Text(
          'Goals Screen - Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
