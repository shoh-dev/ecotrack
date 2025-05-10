import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface
import 'package:ecotrack/domain/use_cases/update_goal_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the UpdateGoalUseCase.
// This class contains the business logic for updating an existing goal.
class UpdateGoalUseCaseImpl implements UpdateGoalUseCase {
  final GoalRepository _goalRepository; // Dependency on GoalRepository

  // Constructor: Inject the GoalRepository dependency.
  UpdateGoalUseCaseImpl(this._goalRepository);

  @override
  Future<Goal?> execute(Goal goal) async {
    print('UpdateGoalUseCase: Executing for goal ID: ${goal.id}'); // Debug log

    // Business logic:
    // 1. Basic validation: Ensure the goal has an ID.
    if (goal.id.isEmpty) {
      print(
        'UpdateGoalUseCase: Error: Goal ID is empty. Cannot update.',
      ); // Debug log
      throw ArgumentError('Goal ID cannot be empty for update.');
    }

    // 2. Save the goal using the GoalRepository.
    // Our current in-memory repo's saveGoal handles update if an ID exists.
    final updatedGoalId = await _goalRepository.saveGoal(goal);

    print(
      'UpdateGoalUseCase: Goal updated with ID: $updatedGoalId',
    ); // Debug log

    // 3. Potentially trigger other actions (e.g., recalculate progress if dates/target changed).
    // Since our GoalsViewModel is reactive, it will recalculate progress automatically
    // when the GoalRepository stream emits the updated goal after saveGoal.

    // 4. Fetch the updated goal from the repository to return it.
    // This ensures we return the latest state from the data source.
    final updatedGoal = await _goalRepository.getGoalById(updatedGoalId);

    print(
      'UpdateGoalUseCase: Returning updated goal (found: ${updatedGoal != null})',
    ); // Debug log
    return updatedGoal; // Return the updated goal or null if not found after saving (shouldn't happen with in-memory repo)
  }
}
