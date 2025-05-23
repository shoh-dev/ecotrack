import 'dart:async'; // Import async for StreamController
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the abstract repository interface
import 'package:uuid/uuid.dart'; // We'll use this for generating unique IDs

// In-memory implementation of the GoalRepository interface.
// Data is stored in a simple list in memory.
class GoalRepositoryImpl implements GoalRepository {
  // Use a static list to simulate data persistence across different instances
  // (though data is still lost on app restart).
  static final List<Goal> _goals = [];

  // StreamController to manage the stream of goal lists.
  // The stream will emit the current list whenever it changes.
  final _goalsController =
      StreamController<
        List<Goal>
      >.broadcast(); // Use .broadcast for multiple listeners

  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // Note: You should have added the uuid package earlier.

  @override
  Future<String> saveGoal(Goal goal) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 100));

    // If the goal has an ID, try to update it. Otherwise, add as new.
    if (goal.id.isNotEmpty) {
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        // Update existing goal
        _goals[index] = goal;
        print(
          'GoalRepositoryImpl: Updated goal with ID: ${goal.id}',
        ); // For demonstration

        // Add the updated list of goals to the stream.
        _goalsController.sink.add(_goals.toList()); // Add a copy to the stream

        return goal.id;
      }
    }

    // Add as a new goal
    final goalToSave = Goal(
      id: _uuid.v4(), // Generate a new UUID
      name: goal.name,
      description: goal.description,
      type: goal.type,
      targetUnit: goal.targetUnit,
      targetValue: goal.targetValue,
      startDate: goal.startDate,
      endDate: goal.endDate,
      status: goal.status,
      details: goal.details,
    );

    _goals.add(goalToSave);
    print(
      'GoalRepositoryImpl: Saved new goal with ID: ${goalToSave.id}',
    ); // For demonstration

    // Add the updated list of goals to the stream.
    _goalsController.sink.add(_goals.toList()); // Add a copy to the stream

    return goalToSave.id; // Return the ID of the saved goal
  }

  @override
  Future<Goal?> getGoalById(String goalId) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 50));

    print(
      'GoalRepositoryImpl: Getting goal by ID: $goalId',
    ); // For demonstration
    try {
      return _goals.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      // Return null if not found
      print(
        'GoalRepositoryImpl: Goal with ID $goalId not found.',
      ); // For demonstration
      return null;
    }
  }

  @override
  Future<List<Goal>> getGoals({String? status, String? type}) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 100));

    print(
      'GoalRepositoryImpl: Getting goals (status: $status, type: $type)',
    ); // For demonstration

    Iterable<Goal> filteredGoals = _goals;

    if (status != null) {
      filteredGoals = filteredGoals.where((goal) => goal.status == status);
    }
    if (type != null) {
      filteredGoals = filteredGoals.where((goal) => goal.type == type);
    }

    final result = filteredGoals.toList();
    print(
      'GoalRepositoryImpl: Retrieved ${result.length} goals.',
    ); // For demonstration
    return result;
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 50));

    // Remove the goal with the given ID
    final initialLength = _goals.length;
    _goals.removeWhere((goal) => goal.id == goalId);
    if (_goals.length < initialLength) {
      print(
        'GoalRepositoryImpl: Deleted goal with ID: $goalId',
      ); // For demonstration
      // Add the updated list of goals to the stream after deletion.
      _goalsController.sink.add(_goals.toList()); // Add a copy to the stream
    } else {
      print(
        'GoalRepositoryImpl: Goal with ID $goalId not found for deletion.',
      ); // For demonstration
    }
  }

  @override
  Stream<List<Goal>> watchGoals() {
    // Return the stream from the controller.
    // We also add the current list immediately when someone starts listening.
    // This ensures the listener gets the initial data.
    if (_goals.isNotEmpty) {
      _goalsController.sink.add(_goals.toList());
    } else {
      _goalsController.sink.add([]); // Emit empty list if no goals
    }
    return _goalsController.stream;
  }

  @override
  void dispose() {
    // Close the stream controller when the repository is no longer needed.
    // This prevents memory leaks.
    _goalsController.close();
    print(
      'GoalRepositoryImpl: StreamController disposed.',
    ); // For demonstration
  }
}
