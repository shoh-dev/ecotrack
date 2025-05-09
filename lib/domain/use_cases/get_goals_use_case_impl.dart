import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface
import 'package:ecotrack/domain/use_cases/get_goals_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the GetGoalsUseCase.
// This class contains the business logic for retrieving goals.
class GetGoalsUseCaseImpl implements GetGoalsUseCase {
  final GoalRepository _goalRepository; // Dependency on GoalRepository

  // Constructor: Inject the GoalRepository dependency.
  GetGoalsUseCaseImpl(this._goalRepository);

  @override
  Future<List<Goal>> execute({String? status, String? type}) async {
    // Business logic:
    // 1. Retrieve goals from the GoalRepository based on criteria.
    final goals = await _goalRepository.getGoals(status: status, type: type);

    // 2. Potentially perform additional domain-specific processing on the list
    // (e.g., sort, filter based on complex rules - omitted for brevity).

    print(
      'GetGoalsUseCase executed: Retrieved ${goals.length} goals.',
    ); // For demonstration

    return goals;
  }
}
