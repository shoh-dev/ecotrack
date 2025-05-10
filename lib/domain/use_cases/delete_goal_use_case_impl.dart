import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface
import 'package:ecotrack/domain/use_cases/delete_goal_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the DeleteGoalUseCase.
// This class contains the business logic for deleting an existing goal.
class DeleteGoalUseCaseImpl implements DeleteGoalUseCase {
  final GoalRepository _goalRepository; // Dependency on GoalRepository

  // Constructor: Inject the GoalRepository dependency.
  DeleteGoalUseCaseImpl(this._goalRepository);

  @override
  Future<bool> execute(String goalId) async {
    print('DeleteGoalUseCase: Executing for goal ID: $goalId'); // Debug log

    // Business logic:
    // 1. Basic validation: Ensure the goal ID is not empty.
    if (goalId.isEmpty) {
      print(
        'DeleteGoalUseCase: Error: Goal ID is empty. Cannot delete.',
      ); // Debug log
      // In a real app, you might throw a custom domain exception here.
      return false; // Indicate deletion failed due to invalid ID
    }

    try {
      // 2. Delete the goal using the GoalRepository.
      await _goalRepository.deleteGoal(goalId);

      print('DeleteGoalUseCase: Goal with ID $goalId deleted.'); // Debug log

      // 3. Potentially trigger other actions (e.g., update related data).
      // Since our GoalsViewModel is reactive, it will update automatically
      // when the GoalRepository stream emits after deletion.

      // Assuming deleteGoal completes without throwing indicates success for in-memory repo.
      return true; // Indicate deletion was successful
    } catch (e) {
      print(
        'DeleteGoalUseCase: Error deleting goal with ID $goalId: $e',
      ); // Log the error
      // Handle repository errors or other potential exceptions during deletion.
      // In a real app, you might wrap this in a custom domain exception.
      return false; // Indicate deletion failed
    }
  }
}
