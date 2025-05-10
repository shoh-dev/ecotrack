import 'package:ecotrack/domain/entities/user_profile.dart'; // Import the UserProfile entity
import 'package:ecotrack/domain/repositories/user_profile_repository.dart'; // Import the UserProfileRepository interface
import 'package:ecotrack/domain/use_cases/get_user_profile_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the GetUserProfileUseCase.
// This class contains the business logic for retrieving the user's profile.
class GetUserProfileUseCaseImpl implements GetUserProfileUseCase {
  final UserProfileRepository
  _userProfileRepository; // Dependency on UserProfileRepository

  // Constructor: Inject the UserProfileRepository dependency.
  GetUserProfileUseCaseImpl(this._userProfileRepository);

  @override
  Future<UserProfile?> execute() async {
    print('GetUserProfileUseCase: Executing...'); // Debug log

    // Business logic:
    // 1. Retrieve the user profile from the UserProfileRepository.
    final profile = await _userProfileRepository.getUserProfile();

    print(
      'GetUserProfileUseCase: Found profile: ${profile != null}',
    ); // Debug log

    // 2. Potentially perform additional domain-specific processing (none needed here currently).

    return profile; // Return the found profile or null
  }
}
