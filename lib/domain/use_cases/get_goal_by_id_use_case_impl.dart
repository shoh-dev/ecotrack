import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface
import 'package:ecotrack/domain/use_cases/get_goal_by_id_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the GetGoalByIdUseCase.
// This class contains the business logic for retrieving a single goal by its ID.
class GetGoalByIdUseCaseImpl implements GetGoalByIdUseCase {
  final GoalRepository _goalRepository; // Dependency on GoalRepository

  // Constructor: Inject the GoalRepository dependency.
  GetGoalByIdUseCaseImpl(this._goalRepository);

  @override
  Future<Goal?> execute(String goalId) async {
    print('GetGoalByIdUseCase: Executing for goal ID: $goalId'); // Debug log

    // Business logic:
    // 1. Retrieve the goal from the GoalRepository by its ID.
    final goal = await _goalRepository.getGoalById(goalId);

    print(
      'GetGoalByIdUseCase: Found goal for ID $goalId: ${goal != null}',
    ); // Debug log

    // 2. Potentially perform additional domain-specific processing on the goal (none needed here currently).

    return goal; // Return the found goal or null
  }
}
