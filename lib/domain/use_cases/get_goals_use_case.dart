import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface

// Abstract interface defining the business logic for retrieving goals.
abstract class GetGoalsUseCase {
  // Executes the use case: retrieves a list of goals from the repository,
  // optionally filtered by status or type.
  Future<List<Goal>> execute({String? status, String? type});
}

// Example implementation (we will add this later in the domain layer)
/*
class GetGoalsUseCaseImpl implements GetGoalsUseCase {
  final GoalRepository goalRepository;

  GetGoalsUseCaseImpl(this.goalRepository);

  @override
  Future<List<Goal>> execute({String? status, String? type}) async {
    // Business logic:
    // 1. Retrieve goals from the GoalRepository based on criteria.
    final goals = await goalRepository.getGoals(status: status, type: type);

    // 2. Potentially perform additional domain-specific processing on the list
    // (e.g., sort, filter based on complex rules - omitted for brevity).

    print('GetGoalsUseCase executed: Retrieved ${goals.length} goals.'); // Placeholder action

    return goals;
  }
}
*/
