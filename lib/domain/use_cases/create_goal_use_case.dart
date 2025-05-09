import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface

// Abstract interface defining the business logic for creating a new goal.
abstract class CreateGoalUseCase {
  // Executes the use case: creates a new goal using the repository.
  // Returns the ID of the newly created goal.
  Future<String> execute(Goal goal);
}

// Example implementation (we will add this later in the domain layer)
/*
class CreateGoalUseCaseImpl implements CreateGoalUseCase {
  final GoalRepository goalRepository;

  CreateGoalUseCaseImpl(this.goalRepository);

  @override
  Future<String> execute(Goal goal) async {
    // Business logic:
    // 1. Validate the goal data (e.g., check dates, target value - omitted for brevity).
    // 2. Save the goal using the GoalRepository.
    final goalId = await goalRepository.saveGoal(goal);

    print('CreateGoalUseCase executed: Goal created with ID: $goalId'); // Placeholder action

    // 3. Potentially trigger other actions (e.g., set up notifications, initial progress tracking).

    return goalId; // Return the ID of the created goal
  }
}
*/
