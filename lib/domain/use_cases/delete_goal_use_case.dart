import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface

// Abstract interface defining the business logic for deleting an existing goal.
abstract class DeleteGoalUseCase {
  // Executes the use case: deletes a goal from the repository by its ID.
  // Returns true if deletion was successful, false otherwise.
  Future<bool> execute(String goalId);
}

// Example implementation (we will add this later in the domain layer)
/*
class DeleteGoalUseCaseImpl implements DeleteGoalUseCase {
  final GoalRepository goalRepository;

  DeleteGoalUseCaseImpl(this.goalRepository);

  @override
  Future<bool> execute(String goalId) async {
    // Business logic:
    // 1. Validate the goal ID (ensure it's not empty).
    if (goalId.isEmpty) {
       print('DeleteGoalUseCase: Error: Goal ID is empty. Cannot delete.'); // Debug log
       return false; // Or throw an error
    }

    // 2. Delete the goal using the GoalRepository.
    await goalRepository.deleteGoal(goalId);

    print('DeleteGoalUseCase executed for goal ID: $goalId.'); // Placeholder action

    // 3. Potentially trigger other actions (e.g., update related data).
    // Since our GoalsViewModel is reactive, it will update automatically
    // when the GoalRepository stream emits after deletion.

    // In a real repo, you might check if deletion actually occurred.
    // For our in-memory repo, deleteGoal doesn't return success status,
    // so we'll assume true if no error was thrown.
    return true;
  }
}
*/
