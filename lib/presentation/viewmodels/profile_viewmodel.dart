import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/user_profile.dart'; // Import the UserProfile entity
import 'package:ecotrack/domain/use_cases/get_user_profile_use_case.dart'; // Import GetUserProfileUseCase interface
import 'package:ecotrack/domain/use_cases/save_user_profile_use_case.dart'; // Import SaveUserProfileUseCase interface

// ProfileViewModel manages the state and logic for the ProfileScreen.
// It fetches and holds the user profile and handles saving updates.
class ProfileViewModel extends ChangeNotifier {
  // Dependencies:
  final GetUserProfileUseCase _getUserProfileUseCase;
  final SaveUserProfileUseCase _saveUserProfileUseCase;

  // State properties for the Profile View:
  UserProfile? _userProfile; // Holds the user's profile data
  bool _isLoading = false; // Indicates if the profile is currently being loaded
  String?
  _errorMessage; // Holds an error message if fetching fails (only for actual errors, not 'not found')

  // --- New State for Additional Fields ---
  String? _preferredUnits; // State for preferred units
  int? _baselineYear; // State for baseline year
  // --- End New State for Additional Fields ---

  // State for Saving:
  bool _isSaving = false; // Indicates if the profile is currently being saved
  String? _saveMessage; // Provides feedback after saving (success/error)
  String? _saveErrorMessage; // Holds an error message if saving fails

  // Constructor: Use Provider to inject dependencies.
  ProfileViewModel(this._getUserProfileUseCase, this._saveUserProfileUseCase) {
    print('ProfileViewModel: Initialized.'); // Debug log
  }

  // Getters to expose the state to the View:
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- Getters for Additional Fields ---
  String? get preferredUnits => _preferredUnits;
  int? get baselineYear => _baselineYear;
  // --- End Getters for Additional Fields ---

  // Getters for Saving State:
  bool get isSaving => _isSaving;
  String? get saveMessage => _saveMessage;
  String? get saveErrorMessage => _saveErrorMessage;

  // Method to fetch the user profile. Called by the ProfileScreen.
  Future<void> fetchUserProfile() async {
    print('ProfileViewModel: fetchUserProfile called.'); // Debug log
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    // Don't clear save messages here.
    print(
      'ProfileViewModel: fetchUserProfile - Setting _isLoading = true. Calling notifyListeners().',
    ); // Debug log
    notifyListeners(); // Notify listeners to show loading indicator

    try {
      // Call the Use Case to get the user profile.
      final fetchedProfile = await _getUserProfileUseCase.execute();
      print(
        'ProfileViewModel: fetchUserProfile - Use Case executed. Fetched profile: ${fetchedProfile != null}',
      ); // Debug log

      _userProfile = fetchedProfile; // Update the profile state
      _isLoading = false; // Set loading state to false
      print(
        'ProfileViewModel: fetchUserProfile - Setting _isLoading = false.',
      ); // Debug log

      if (_userProfile == null) {
        // Profile not found is NOT an error state for the ViewModel's errorMessage.
        // The UI will check if _userProfile is null to show the create form.
        print(
          'ProfileViewModel: fetchUserProfile - Profile not found. Not setting error message.',
        ); // Debug log
        // --- New: Initialize new fields to null if profile not found ---
        _preferredUnits = null;
        _baselineYear = null;
        // --- End New ---
      } else {
        // --- New: Update new fields from fetched profile ---
        _preferredUnits = _userProfile!.preferredUnits;
        _baselineYear = _userProfile!.baselineYear;
        // --- End New ---
      }
      print(
        'ProfileViewModel: fetchUserProfile - Calling notifyListeners() after fetch.',
      ); // Debug log
      notifyListeners(); // Notify listeners with the fetched data or null state
    } catch (e) {
      // Handle actual errors during data fetching (e.g., database connection issue).
      print(
        'ProfileViewModel: fetchUserProfile - Error caught: $e',
      ); // Debug log
      _userProfile = null; // Clear profile on error
      _isLoading = false; // Set loading state to false
      _errorMessage =
          'Failed to load user profile: ${e.toString()}'; // Set error message for actual errors
      // --- New: Clear new fields on fetch error ---
      _preferredUnits = null;
      _baselineYear = null;
      // --- End New ---
      print(
        'ProfileViewModel: fetchUserProfile - Setting _isLoading = false and _errorMessage. Calling notifyListeners().',
      ); // Debug log
      notifyListeners(); // Notify listeners with the error state
      print('Error fetching user profile: $e'); // Log the error
    }
  }

  // Method to save or update the user profile. Called by the ProfileScreen.
  Future<void> saveUserProfile({
    // ID is optional here; the repository handles insert/update based on ID existence.
    String? id,
    required String name,
    String? email,
    String? location,
    DateTime? memberSince,
    Map<String, dynamic>? settings,
    // --- New Parameters ---
    String? preferredUnits,
    int? baselineYear,
    // --- End New Parameters ---
  }) async {
    print('ProfileViewModel: saveUserProfile called.'); // Debug log
    if (id != null && id.isEmpty) {
      print('ProfileViewModel: Cannot update goal with empty ID.'); // Debug log
      _saveErrorMessage = 'Cannot update goal with empty ID.';
      print(
        'ProfileViewModel: saveUserProfile - Setting _saveErrorMessage. Calling notifyListeners().',
      ); // Debug log
      notifyListeners();
      return;
    }

    _isSaving = true; // Set saving state to true
    _saveMessage = null; // Clear previous messages before starting
    _saveErrorMessage = null; // Clear previous errors before starting
    print(
      'ProfileViewModel: saveUserProfile - Setting _isSaving = true. Calling notifyListeners().',
    ); // Debug log
    notifyListeners(); // Notify listeners to show saving indicator

    try {
      // Create a UserProfile entity from the provided data.
      final profileToSave = UserProfile(
        id: id ?? '', // Use provided ID or empty string for new profile
        name: name,
        email: email,
        location: location,
        memberSince: memberSince,
        settings: settings,
        // --- New Fields ---
        preferredUnits: preferredUnits,
        baselineYear: baselineYear,
        // --- End New Fields ---
      );

      // Call the Use Case to execute the save business logic.
      final savedProfile = await _saveUserProfileUseCase.execute(profileToSave);
      print(
        'ProfileViewModel: saveUserProfile - Use Case executed. Saved profile ID: ${savedProfile.id}',
      ); // Debug log

      _isSaving = false; // Set saving state to false
      _userProfile =
          savedProfile; // Update the profile in state with the result from the Use Case
      _saveMessage = 'Profile saved successfully!'; // Set success message
      // --- New: Update new state variables from saved profile ---
      _preferredUnits = _userProfile!.preferredUnits;
      _baselineYear = _userProfile!.baselineYear;
      // --- End New ---
      print(
        'ProfileViewModel: saveUserProfile - Setting _isSaving = false and _saveMessage. Calling notifyListeners() (in finally).',
      ); // Debug log

      // Note: We will call notifyListeners after clearing the message in the View (in finally).
    } catch (e) {
      // Handle errors during saving
      print(
        'ProfileViewModel: saveUserProfile - Error caught: $e',
      ); // Debug log
      _isSaving = false; // Set saving state to false
      _saveMessage = null; // Clear success message
      _saveErrorMessage =
          'Failed to save profile: ${e.toString()}'; // Set error message
      print(
        'ProfileViewModel: saveUserProfile - Setting _isSaving = false and _saveErrorMessage. Calling notifyListeners() (in finally).',
      ); // Debug log
      print('Error saving profile: $e'); // Log the error
    } finally {
      // Ensure listeners are notified after state update, even on error.
      notifyListeners();
      print(
        'ProfileViewModel: saveUserProfile - finally block finished. notifyListeners called.',
      ); // Debug log
    }
  }

  // Methods to clear save messages (called from the View after handling)
  void clearSaveMessage() {
    print('ProfileViewModel: clearSaveMessage called.'); // Debug log
    _saveMessage = null;
    notifyListeners();
    print(
      'ProfileViewModel: clearSaveMessage - Calling notifyListeners().',
    ); // Debug log
  }

  void clearSaveErrorMessage() {
    print('ProfileViewModel: clearSaveErrorMessage called.'); // Debug log
    _saveErrorMessage = null;
    notifyListeners();
    print(
      'ProfileViewModel: clearSaveErrorMessage - Calling notifyListeners().',
    ); // Debug log
  }

  // Remember to dispose of resources if needed.
  @override
  void dispose() {
    print('ProfileViewModel: dispose called.'); // Debug log
    // Clean up resources if any (e.g., stream subscriptions if we made this reactive).
    super.dispose();
  }
}
