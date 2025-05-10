import 'package:ecotrack/domain/entities/user_profile.dart'; // Import the UserProfile entity
import 'package:ecotrack/domain/repositories/user_profile_repository.dart'; // Import the UserProfileRepository interface

// Abstract interface defining the business logic for saving or updating the user's profile.
abstract class SaveUserProfileUseCase {
  // Executes the use case: saves or updates the user profile in the repository.
  // Returns the saved UserProfile entity.
  Future<UserProfile> execute(UserProfile profile);
}

// Example implementation (we will add this later in the domain layer)
/*
class SaveUserProfileUseCaseImpl implements SaveUserProfileUseCase {
  final UserProfileRepository userProfileRepository;

  SaveUserProfileUseCaseImpl(this.userProfileRepository);

  @override
  Future<UserProfile> execute(UserProfile profile) async {
    print('SaveUserProfileUseCase: Executing...'); // Placeholder

    // Business logic:
    // 1. Validate the profile data (e.g., ensure name is not empty).
    // 2. Save the profile using the UserProfileRepository.
    final savedProfile = await userProfileRepository.saveUserProfile(profile);

    print('SaveUserProfileUseCase: Profile saved with ID: ${savedProfile.id}'); // Placeholder action

    // 3. Potentially trigger other actions (e.g., update settings in app state).

    return savedProfile; // Return the saved profile
  }
}
*/
