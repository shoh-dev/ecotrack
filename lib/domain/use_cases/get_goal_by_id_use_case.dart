import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the GoalRepository interface

// Abstract interface defining the business logic for retrieving a single goal by its ID.
abstract class GetGoalByIdUseCase {
  // Executes the use case: retrieves a goal from the repository by its ID.
  // Returns the Goal entity or null if not found.
  Future<Goal?> execute(String goalId);
}

// Example implementation (we will add this later in the domain layer)
/*
class GetGoalByIdUseCaseImpl implements GetGoalByIdUseCase {
  final GoalRepository goalRepository;

  GetGoalByIdUseCaseImpl(this.goalRepository);

  @override
  Future<Goal?> execute(String goalId) async {
    // Business logic:
    // 1. Retrieve the goal from the GoalRepository by its ID.
    final goal = await goalRepository.getGoalById(goalId);

    print('GetGoalByIdUseCase executed for ID: $goalId. Found: ${goal != null}'); // Placeholder action

    // 2. Potentially perform additional domain-specific processing on the goal.

    return goal; // Return the found goal or null
  }
}
*/
