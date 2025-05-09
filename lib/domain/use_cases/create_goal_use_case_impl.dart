import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface
import 'package:ecotrack/domain/use_cases/create_goal_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the CreateGoalUseCase.
// This class contains the business logic for creating a new goal.
class CreateGoalUseCaseImpl implements CreateGoalUseCase {
  final GoalRepository _goalRepository; // Dependency on GoalRepository

  // Constructor: Inject the GoalRepository dependency.
  CreateGoalUseCaseImpl(this._goalRepository);

  @override
  Future<String> execute(Goal goal) async {
    // Business logic:
    // 1. Validate the goal data (e.g., check dates, target value - omitted for brevity).
    // 2. Save the goal using the GoalRepository.
    final goalId = await _goalRepository.saveGoal(goal);

    print(
      'CreateGoalUseCase executed: Goal created with ID: $goalId',
    ); // For demonstration

    // 3. Potentially trigger other actions (e.g., set up notifications, initial progress tracking).

    return goalId; // Return the ID of the created goal
  }
}
