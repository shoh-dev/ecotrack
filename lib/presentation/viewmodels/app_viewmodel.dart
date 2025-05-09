import 'package:flutter/foundation.dart';

// AppViewModel manages app-wide state, including the current navigation index.
class AppViewModel extends ChangeNotifier {
  // Placeholder property for app status (from previous step)
  String _appStatus = 'Initializing';
  String get appStatus => _appStatus;

  void updateStatus(String newStatus) {
    _appStatus = newStatus;
    notifyListeners();
  }

  // --- Navigation State ---
  // Holds the index of the currently selected screen in the BottomNavigationBar.
  int _currentScreenIndex = 0;

  int get currentScreenIndex => _currentScreenIndex;

  // Method to update the selected screen index.
  void updateScreenIndex(int newIndex) {
    if (newIndex != _currentScreenIndex) {
      _currentScreenIndex = newIndex;
      // Notify listeners so widgets watching this ViewModel (like our main navigation widget) rebuild.
      notifyListeners();
    }
  }
  // --- End Navigation State ---

  // Remember to dispose of resources if needed, though not necessary for this simple example.
  @override
  void dispose() {
    // Clean up resources if any, like StreamSubscriptions or AnimationControllers
    super.dispose();
  }
}
