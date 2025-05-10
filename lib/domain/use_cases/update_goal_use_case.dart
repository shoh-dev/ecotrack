import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface

// Abstract interface defining the business logic for updating an existing goal.
abstract class UpdateGoalUseCase {
  // Executes the use case: updates an existing goal in the repository.
  // Returns the updated Goal entity or null if update failed (e.g., goal not found).
  Future<Goal?> execute(Goal goal);
}

// Example implementation (we will add this later in the domain layer)
/*
class UpdateGoalUseCaseImpl implements UpdateGoalUseCase {
  final GoalRepository goalRepository;

  UpdateGoalUseCaseImpl(this.goalRepository);

  @override
  Future<Goal?> execute(Goal goal) async {
    // Business logic:
    // 1. Validate the goal data (e.g., ensure ID is not empty, check dates).
    // 2. Save the goal using the GoalRepository (repository handles update if ID exists).
    // Note: Our current in-memory repo's saveGoal handles update if ID exists.
    final goalId = await goalRepository.saveGoal(goal);

    print('UpdateGoalUseCase executed for goal ID: ${goal.id}. Result ID: $goalId'); // Placeholder action

    // 3. Potentially trigger other actions (e.g., recalculate progress if dates/target changed).
    // Since our GoalsViewModel is reactive, it will recalculate progress automatically
    // when the GoalRepository stream emits the updated goal.

    // Fetch the updated goal to return it
    return goalRepository.getGoalById(goalId); // Assuming getGoalById is available
  }
}
*/
