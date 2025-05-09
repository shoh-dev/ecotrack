import 'package:flutter/material.dart';

// Placeholder screen for sustainable living resources.
// It's a StatelessWidget as its state will be managed by a ViewModel.
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      // AppBar is optional here if using a main Scaffold with BottomNavigationBar
      // appBar: AppBar(
      //   title: const Text('Sustainable Resources'),
      // ),
      body: Center(
        child: Text(
          'Resources Screen - Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
