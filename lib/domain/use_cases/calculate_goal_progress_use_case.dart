import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the ActivityRepository interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the FootprintRepository interface (for implementation dependency hint)

// Abstract interface defining the business logic for calculating progress towards a goal.
abstract class CalculateGoalProgressUseCase {
  // Executes the use case: calculates the current progress for a given goal
  // based on relevant activities and potentially historical footprint data.
  // Returns a value representing the progress (e.g., a double representing percentage or accumulated value).
  Future<double> execute(Goal goal);
}

// Example implementation (we will add this later in the domain layer)
/*
class CalculateGoalProgressUseCaseImpl implements CalculateGoalProgressUseCase {
  final ActivityRepository activityRepository;
  // New dependency for FootprintReduction goals
  final FootprintRepository footprintRepository;


  CalculateGoalProgressUseCaseImpl(this.activityRepository, this.footprintRepository);

  @override
  Future<double> execute(Goal goal) async {
    // Business logic:
    // ... (logic will be expanded in the implementation step)
    return 0.0; // Placeholder
  }
}
*/
