import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the ActivityRepository interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the FootprintRepository interface
import 'package:ecotrack/domain/use_cases/log_activity_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the LogActivityUseCase.
// This class contains the business logic for logging an activity.
class LogActivityUseCaseImpl implements LogActivityUseCase {
  final ActivityRepository activityRepository;
  // We might need FootprintRepository here if logging an activity
  // immediately triggers a footprint recalculation or update.
  // For this basic implementation, we'll just save the activity.
  // final FootprintRepository footprintRepository;

  LogActivityUseCaseImpl(
    this.activityRepository /*, this.footprintRepository*/,
  );

  @override
  Future<void> execute(Activity activity) async {
    // Business logic:
    // 1. Validate the activity data (e.g., check for negative values - omitted for brevity).
    // 2. Save the activity using the ActivityRepository.
    await activityRepository.saveActivity(activity);

    // 3. Potentially trigger a footprint recalculation or update based on the new activity.
    // This is where you'd call methods on the FootprintRepository or another service.
    // For now, we'll just print a confirmation.
    print('LogActivityUseCase executed: Activity saved.');

    // In a real app, you might also:
    // - Check if the activity contributes to a goal.
    // - Trigger notifications.
  }
}
