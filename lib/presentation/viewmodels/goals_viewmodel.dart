import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/use_cases/get_goals_use_case.dart'; // Import the Use Case interface
// We might also need CreateGoalUseCase here later if we add goal creation to this ViewModel.
// import 'package:ecotrack/domain/use_cases/create_goal_use_case.dart';

// GoalsViewModel manages the state and presentation logic for the GoalsScreen (Goals View).
class GoalsViewModel extends ChangeNotifier {
  // Dependency on the Use Case to fetch goals.
  final GetGoalsUseCase _getGoalsUseCase;
  // Potentially dependency on CreateGoalUseCase if goal creation is handled here.
  // final CreateGoalUseCase _createGoalUseCase;

  // State properties for the Goals View:
  List<Goal> _goals = []; // Holds the list of goals
  bool _isLoading = false; // Indicates if data is currently being loaded
  String? _errorMessage; // Holds an error message if data fetching fails

  // Constructor: Use Provider to inject the GetGoalsUseCase.
  GoalsViewModel(this._getGoalsUseCase /*, this._createGoalUseCase*/);

  // Getters to expose the state to the View:
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to fetch goals for the Goals screen.
  Future<void> fetchGoals() async {
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    notifyListeners(); // Notify listeners to show loading indicator

    try {
      // Call the Use Case to get the list of goals.
      // We can add filtering criteria here later (e.g., status: 'Active').
      final fetchedGoals = await _getGoalsUseCase.execute();

      _goals = fetchedGoals; // Update the list of goals
      _isLoading = false; // Set loading state to false
      notifyListeners(); // Notify listeners with the fetched data
    } catch (e) {
      // Handle errors during data fetching
      _goals = []; // Clear goals on error
      _isLoading = false; // Set loading state to false
      _errorMessage =
          'Failed to load goals: ${e.toString()}'; // Set error message
      notifyListeners(); // Notify listeners with the error state
      print('Error fetching goals: $e'); // Log the error
    }
  }

  // Potentially add methods for creating, updating, or deleting goals here later.
  // Future<void> createGoal(...) async { ... }

  // Remember to dispose of resources if needed.
  @override
  void dispose() {
    // Clean up resources if any
    super.dispose();
  }
}
