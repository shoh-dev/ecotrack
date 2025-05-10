import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/use_cases/get_goal_by_id_use_case.dart'; // Import GetGoalById Use Case interface
import 'package:ecotrack/domain/use_cases/update_goal_use_case.dart'; // Import UpdateGoalUseCase interface
import 'package:ecotrack/domain/use_cases/delete_goal_use_case.dart'; // Import DeleteGoalUseCase interface

// GoalDetailsViewModel manages the state and logic for the GoalDetailsScreen.
// It fetches, holds, and can update/delete the details of a single goal.
class GoalDetailsViewModel extends ChangeNotifier {
  // Dependencies:
  final GetGoalByIdUseCase _getGoalByIdUseCase;
  final UpdateGoalUseCase _updateGoalUseCase;
  final DeleteGoalUseCase
  _deleteGoalUseCase; // New dependency for deleting goals

  // State properties for the Goal Details View:
  Goal? _goal; // Holds the details of the fetched goal
  bool _isLoading = false; // Indicates if the goal is currently being loaded
  String? _errorMessage; // Holds an error message if fetching fails

  // State for Updating:
  bool _isUpdating = false; // Indicates if the goal is currently being updated
  String? _updateMessage; // Provides feedback after updating (success/error)
  String? _updateErrorMessage; // Holds an error message if updating fails

  // --- New State for Deleting ---
  bool _isDeleting = false; // Indicates if the goal is currently being deleted
  String? _deleteMessage; // Provides feedback after deleting (success/error)
  String? _deleteErrorMessage; // Holds an error message if deleting fails
  // --- End New State for Deleting ---

  // Constructor: Use Provider to inject dependencies.
  GoalDetailsViewModel(
    this._getGoalByIdUseCase,
    this._updateGoalUseCase,
    this._deleteGoalUseCase,
  );

  // Getters to expose the state to the View:
  Goal? get goal => _goal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getters for Updating State:
  bool get isUpdating => _isUpdating;
  String? get updateMessage => _updateMessage;
  String? get updateErrorMessage => _updateErrorMessage;

  // --- Getters for Deleting State ---
  bool get isDeleting => _isDeleting;
  String? get deleteMessage => _deleteMessage;
  String? get deleteErrorMessage => _deleteErrorMessage;
  // --- End Getters for Deleting State ---

  // Method to fetch the goal details by ID. Called by the GoalDetailsScreen.
  Future<void> fetchGoalDetails(String goalId) async {
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    // Don't clear update/delete messages here, as they relate to separate actions.
    notifyListeners(); // Notify listeners to show loading indicator

    try {
      // Call the Use Case to get the goal by its ID.
      final fetchedGoal = await _getGoalByIdUseCase.execute(goalId);

      _goal = fetchedGoal; // Update the goal state
      _isLoading = false; // Set loading state to false
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

  // Method to update goal.
  Future<void> updateGoal({
    required String id, // ID is required for update
    required String name,
    required String description,
    required String type,
    required String targetUnit,
    required double targetValue,
    required DateTime startDate,
    required DateTime endDate,
    required String status,
    Map<String, dynamic>? details,
  }) async {
    if (id.isEmpty) {
      print(
        'GoalDetailsViewModel: Cannot update goal with empty ID.',
      ); // Debug log
      _updateErrorMessage = 'Cannot update goal with empty ID.';
      notifyListeners();
      return;
    }

    _isUpdating = true; // Set updating state to true
    _updateMessage = null; // Clear previous messages before starting
    _updateErrorMessage = null; // Clear previous errors before starting
    notifyListeners(); // Notify listeners to show updating indicator

    try {
      // Create an updated Goal entity from the provided data.
      final updatedGoal = Goal(
        id: id,
        name: name,
        description: description,
        type: type,
        targetUnit: targetUnit,
        targetValue: targetValue,
        startDate: startDate,
        endDate: endDate,
        status: status,
        details: details,
      );

      // Call the Use Case to execute the goal update business logic.
      final resultGoal = await _updateGoalUseCase.execute(updatedGoal);

      _isUpdating = false; // Set updating state to false

      if (resultGoal != null) {
        _goal =
            resultGoal; // Update the goal in state with the result from the Use Case
        _updateMessage = 'Goal updated successfully!'; // Set success message
      } else {
        // This case might occur if the repository's update logic fails to return the goal.
        _updateErrorMessage =
            'Goal updated, but failed to retrieve updated details.';
      }

      // Note: We will call notifyListeners after clearing the message in the View.
    } catch (e) {
      // Handle errors during updating
      _isUpdating = false; // Set updating state to false
      _updateMessage = null; // Clear success message
      _updateErrorMessage =
          'Failed to update goal: ${e.toString()}'; // Set error message
      print('Error updating goal: $e'); // Log the error
    } finally {
      // Ensure listeners are notified after state update, even on error.
      notifyListeners();
    }
  }

  // --- New Method to Delete Goal ---
  Future<bool> deleteGoal(String goalId) async {
    if (goalId.isEmpty) {
      print(
        'GoalDetailsViewModel: Cannot delete goal with empty ID.',
      ); // Debug log
      _deleteErrorMessage = 'Cannot delete goal with empty ID.';
      notifyListeners();
      return false;
    }

    _isDeleting = true; // Set deleting state to true
    _deleteMessage = null; // Clear previous messages before starting
    _deleteErrorMessage = null; // Clear previous errors before starting
    notifyListeners(); // Notify listeners to show deleting indicator

    try {
      // Call the Use Case to execute the goal deletion business logic.
      final success = await _deleteGoalUseCase.execute(goalId);

      _isDeleting = false; // Set deleting state to false

      if (success) {
        _goal = null; // Clear the goal from state after successful deletion
        _deleteMessage = 'Goal deleted successfully!'; // Set success message
        // Note: We will call notifyListeners after clearing the message in the View.
      } else {
        _deleteErrorMessage = 'Failed to delete goal.'; // Set error message
      }
      return success;
    } catch (e) {
      // Handle errors during deletion
      _isDeleting = false; // Set deleting state to false
      _deleteMessage = null; // Clear success message
      _deleteErrorMessage =
          'Failed to delete goal: ${e.toString()}'; // Set error message
      print('Error deleting goal: $e'); // Log the error
      return false;
    } finally {
      // Ensure listeners are notified after state update, even on error.
      notifyListeners();
    }
  }
  // --- End New Method to Delete Goal ---

  // Methods to clear update/delete messages (called from the View after handling)
  void clearUpdateMessage() {
    _updateMessage = null;
    notifyListeners();
  }

  void clearUpdateErrorMessage() {
    _updateErrorMessage = null;
    notifyListeners();
  }

  void clearDeleteMessage() {
    _deleteMessage = null;
    notifyListeners();
  }

  void clearDeleteErrorMessage() {
    _deleteErrorMessage = null;
    notifyListeners();
  }

  // Remember to dispose of resources if needed.
  @override
  void dispose() {
    // Clean up resources if any (e.g., stream subscriptions if we made this reactive).
    super.dispose();
  }
}
