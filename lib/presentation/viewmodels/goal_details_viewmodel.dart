import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/use_cases/get_goal_by_id_use_case.dart'; // Import the Use Case interface
// We might also need Use Cases for editing/deleting the goal later.
// import 'package:ecotrack/domain/use_cases/update_goal_use_case.dart';
// import 'package:ecotrack/domain/use_cases/delete_goal_use_case.dart';

// GoalDetailsViewModel manages the state and logic for the GoalDetailsScreen.
// It fetches and holds the details of a single goal.
class GoalDetailsViewModel extends ChangeNotifier {
  // Dependency on the Use Case to get a goal by its ID.
  final GetGoalByIdUseCase _getGoalByIdUseCase;
  // Potentially dependencies for updating/deleting the goal.
  // final UpdateGoalUseCase _updateGoalUseCase;
  // final DeleteGoalUseCase _deleteGoalUseCase;

  // State properties for the Goal Details View:
  Goal? _goal; // Holds the details of the fetched goal
  bool _isLoading = false; // Indicates if the goal is currently being loaded
  String? _errorMessage; // Holds an error message if fetching fails

  // Constructor: Use Provider to inject the GetGoalByIdUseCase.
  GoalDetailsViewModel(
    this._getGoalByIdUseCase /*, this._updateGoalUseCase, this._deleteGoalUseCase*/,
  );

  // Getters to expose the state to the View:
  Goal? get goal => _goal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to fetch the goal details by ID. Called by the GoalDetailsScreen.
  Future<void> fetchGoalDetails(String goalId) async {
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    notifyListeners(); // Notify listeners to show loading indicator

    try {
      // Call the Use Case to get the goal by its ID.
      final fetchedGoal = await _getGoalByIdUseCase.execute(goalId);

      _goal = fetchedGoal; // Update the goal state
      _isLoading = false; // Set loading state to false
      // If goal is null, _errorMessage could be set here too, or the UI handles null _goal.
      if (_goal == null) {
        _errorMessage = 'Goal not found.';
      }
      notifyListeners(); // Notify listeners with the fetched data or null state
    } catch (e) {
      // Handle errors during data fetching
      _goal = null; // Clear goal on error
      _isLoading = false; // Set loading state to false
      _errorMessage =
          'Failed to load goal details: ${e.toString()}'; // Set error message
      notifyListeners(); // Notify listeners with the error state
      print('Error fetching goal details: $e'); // Log the error
    }
  }

  // Potentially add methods for updating or deleting the goal here later.
  // Future<void> updateGoal(...) async { ... }
  // Future<void> deleteGoal(...) async { ... }

  // Remember to dispose of resources if needed.
  @override
  void dispose() {
    // Clean up resources if any (e.g., stream subscriptions if we made this reactive).
    super.dispose();
  }
}
