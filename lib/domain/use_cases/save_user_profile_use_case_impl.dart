import 'package:ecotrack/domain/entities/user_profile.dart'; // Import the UserProfile entity
import 'package:ecotrack/domain/repositories/user_profile_repository.dart'; // Import the UserProfileRepository interface
import 'package:ecotrack/domain/use_cases/save_user_profile_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the SaveUserProfileUseCase.
// This class contains the business logic for saving or updating the user's profile.
class SaveUserProfileUseCaseImpl implements SaveUserProfileUseCase {
  final UserProfileRepository
  _userProfileRepository; // Dependency on UserProfileRepository

  // Constructor: Inject the UserProfileRepository dependency.
  SaveUserProfileUseCaseImpl(this._userProfileRepository);

  @override
  Future<UserProfile> execute(UserProfile profile) async {
    print('SaveUserProfileUseCase: Executing...'); // Debug log

    // Business logic:
    // 1. Validate the profile data (e.g., ensure name is not empty).
    if (profile.name.isEmpty) {
      print(
        'SaveUserProfileUseCase: Error: Profile name is empty. Cannot save.',
      ); // Debug log
      // In a real app, you might throw a custom domain exception here.
      throw ArgumentError('Profile name cannot be empty.');
    }

    // 2. Save the profile using the UserProfileRepository.
    final savedProfile = await _userProfileRepository.saveUserProfile(profile);

    print(
      'SaveUserProfileUseCase: Profile saved with ID: ${savedProfile.id}',
    ); // Debug log

    // 3. Potentially trigger other actions (e.g., update settings in app state).
    // Since the ProfileViewModel will likely watch the repository, it will update automatically.

    return savedProfile; // Return the saved profile
  }
}
