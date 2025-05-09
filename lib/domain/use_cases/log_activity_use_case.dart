import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the ActivityRepository interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the FootprintRepository interface

// Abstract interface defining the business logic for logging an activity.
// Use cases orchestrate interactions between repositories.
// Implementations will be in the domain layer itself.
abstract class LogActivityUseCase {
  // Executes the use case: logs an activity and potentially triggers a footprint recalculation.
  Future<void> execute(Activity activity);
}

// Example implementation (we will add this later in the domain layer)
/*
class LogActivityUseCaseImpl implements LogActivityUseCase {
  final ActivityRepository activityRepository;
  final FootprintRepository footprintRepository; // Might need this for recalculation

  LogActivityUseCaseImpl(this.activityRepository, this.footprintRepository);

  @override
  Future<void> execute(Activity activity) async {
    // 1. Save the activity using the repository
    await activityRepository.saveActivity(activity);

    // 2. Potentially trigger a footprint recalculation or mark for recalculation
    // This would involve interacting with FootprintRepository or another service
    // For now, we just save the activity.
    print('Activity logged: ${activity.type}'); // Placeholder action
  }
}
*/
