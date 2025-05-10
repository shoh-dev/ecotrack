import 'package:ecotrack/domain/entities/user_profile.dart'; // Import the UserProfile entity

// Abstract interface defining the contract for User Profile data operations.
// Implementations will be in the data layer (e.g., LocalUserProfileRepository).
abstract class UserProfileRepository {
  // Gets the current user's profile.
  // Since there's likely only one user profile per device in this app,
  // we don't need an ID for retrieval in this basic version.
  Future<UserProfile?> getUserProfile();

  // Saves or updates the current user's profile.
  // If a profile with the same ID exists, it should be updated.
  // Returns the saved UserProfile entity.
  Future<UserProfile> saveUserProfile(UserProfile profile);

  // Potentially a method to watch the user profile for changes (reactive).
  // Stream<UserProfile?> watchUserProfile();

  // Remember to add a dispose method to close streams/resources in implementations.
  void dispose();
}
