import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity

// Abstract interface defining the contract for Goal data operations.
// Implementations will be in the data layer (e.g., LocalDatabaseGoalRepository).
abstract class GoalRepository {
  // Saves a new goal or updates an existing one. Returns the saved goal's ID.
  Future<String> saveGoal(Goal goal);

  // Gets a goal by its unique ID.
  Future<Goal?> getGoalById(String goalId);

  // Gets a list of goals, optionally filtered by status or type.
  Future<List<Goal>> getGoals({String? status, String? type});

  // Deletes a specific goal by its ID.
  Future<void> deleteGoal(String goalId);

  // --- Reactive Method ---
  // Returns a stream that emits the current list of goals whenever it changes.
  Stream<List<Goal>> watchGoals();
  // --- End Reactive Method ---

  // Remember to add a dispose method to close streams/resources in implementations.
  void dispose();
}
