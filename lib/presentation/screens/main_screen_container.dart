import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider

// Import the placeholder screens
import 'package:ecotrack/presentation/screens/home_screen.dart';
import 'package:ecotrack/presentation/screens/track_screen.dart';
import 'package:ecotrack/presentation/screens/goals_screen.dart';
import 'package:ecotrack/presentation/screens/resources_screen.dart';
import 'package:ecotrack/presentation/screens/profile_screen.dart';

// Import the AppViewModel
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';

// MainScreenContainer is a View component.
// It is a StatelessWidget that uses the AppViewModel to manage the current screen index.
class MainScreenContainer extends StatelessWidget {
  const MainScreenContainer({super.key});

  // Define the list of screens that will be displayed in the bottom navigation.
  // The order here corresponds to the index in the BottomNavigationBar.
  final List<Widget> _screens = const [
    HomeScreen(), // Index 0
    TrackScreen(), // Index 1
    GoalsScreen(), // Index 2
    ResourcesScreen(), // Index 3
    ProfileScreen(), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    // Watch the AppViewModel to get the current screen index.
    // This widget will rebuild when the index changes.
    final appViewModel = context.watch<AppViewModel>();
    final int currentIndex = appViewModel.currentScreenIndex;

    return Scaffold(
      // Display the screen corresponding to the current index from the ViewModel.
      body: IndexedStack(
        // Use IndexedStack to keep screens alive when switching
        index: currentIndex,
        children: _screens,
      ),

      // Define the BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        type:
            BottomNavigationBarType
                .fixed, // Use fixed type for more than 3 items
        backgroundColor:
            Theme.of(
              context,
            ).scaffoldBackgroundColor, // Match scaffold background
        selectedItemColor:
            Theme.of(
              context,
            ).primaryColor, // Selected item color from design system
        unselectedItemColor: Colors.grey[600], // Unselected item color
        currentIndex:
            currentIndex, // Set the current active index from the ViewModel
        onTap: (index) {
          // When a tab is tapped, call the updateScreenIndex method on the ViewModel.
          // Use context.read because we only need to call a method, not listen for changes here.
          context.read<AppViewModel>().updateScreenIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), // Placeholder icon
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.directions_car,
            ), // Placeholder icon for Transportation/Track
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border), // Placeholder icon for Goals
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book), // Placeholder icon for Resources
            label: 'Resources',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Placeholder icon for Profile
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
