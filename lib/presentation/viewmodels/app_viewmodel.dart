import 'package:flutter/foundation.dart';

// AppViewModel manages app-wide state, including the current navigation index
// and tracking onboarding status.
class AppViewModel extends ChangeNotifier {
  // Placeholder property for app status
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

  // --- Onboarding State ---
  // Indicates if the user has completed the onboarding process.
  // This state will be persisted later (e.g., in SharedPreferences).
  bool _isOnboardingComplete = false;

  bool get isOnboardingComplete => _isOnboardingComplete;

  // Method to mark onboarding as complete.
  // This should also trigger persistence of the onboarding status.
  void completeOnboarding() {
    _isOnboardingComplete = true;
    print('AppViewModel: Onboarding marked as complete.'); // Debug log
    // TODO: Persist onboarding status (e.g., using SharedPreferences)
    notifyListeners(); // Notify listeners that onboarding status has changed
  }

  // Method to check initial onboarding status on app start (will use persistence later).
  // For now, it defaults to false.
  Future<void> checkOnboardingStatus() async {
    // TODO: Load onboarding status from persistent storage (e.g., SharedPreferences)
    // For now, we'll keep it false initially for demonstration.
    _isOnboardingComplete = false; // Default to false for new users
    // If status was loaded as true, set _isOnboardingComplete = true;
    notifyListeners(); // Notify listeners after checking status
  }
  // --- End Onboarding State ---

  // Remember to dispose of resources if needed.
  @override
  void dispose() {
    // Clean up resources if any, like StreamSubscriptions or AnimationControllers
    super.dispose();
  }
}
