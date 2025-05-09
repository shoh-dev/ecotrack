import 'dart:async'; // Import async for StreamSubscription
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import GoalRepository interface (for stream)
// We no longer need GetGoalsUseCase here as we get goals directly from the stream.
// import 'package:ecotrack/domain/use_cases/get_goals_use_case.dart';
// We might also need CreateGoalUseCase here later if we add goal creation to this ViewModel.
// import 'package:ecotrack/domain/use_cases/create_goal_use_case.dart';

// GoalsViewModel manages the state and presentation logic for the GoalsScreen (Goals View).
// It now reacts to changes in the GoalRepository stream.
class GoalsViewModel extends ChangeNotifier {
  // Dependencies:
  // We no longer need GetGoalsUseCase as we subscribe to the repository stream directly.
  // final GetGoalsUseCase _getGoalsUseCase;
  final GoalRepository
  _goalRepository; // New dependency to subscribe to its stream
  // Potentially dependency on CreateGoalUseCase if goal creation is handled here.
  // final CreateGoalUseCase _createGoalUseCase;

  // State properties for the Goals View:
  List<Goal> _goals = []; // Holds the list of goals
  // _isLoading starts as false by default. It will be set to true if an error occurs
  // during stream processing, but the initial state will be handled by the UI
  // checking if _goals is empty.
  bool _isLoading = false;
  String? _errorMessage; // Holds an error message if data fetching fails

  // Stream subscription to goals.
  StreamSubscription<List<Goal>>? _goalsSubscription;

  // Constructor: Use Provider to inject dependencies.
  GoalsViewModel(this._goalRepository /*, this._createGoalUseCase*/) {
    print(
      'GoalsViewModel: Initializing. Subscribing to goals stream.',
    ); // Debug log
    // Subscribe to the goal stream immediately when the ViewModel is created.
    _subscribeToGoals(_goalRepository);
    // Removed: _isLoading = true;
    // The UI will handle the initial empty state display.
  }

  // Getters to expose the state to the View:
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to subscribe to the GoalRepository stream.
  void _subscribeToGoals(GoalRepository goalRepository) {
    // Cancel any existing subscription before creating a new one.
    _goalsSubscription?.cancel();

    // Subscribe to the stream. The listener will be called whenever goals change.
    _goalsSubscription = goalRepository.watchGoals().listen(
      (goals) {
        // When goals change, update the ViewModel's state.
        print(
          'GoalsViewModel: Goals stream updated. Updating goals list...',
        ); // Debug log
        _goals = goals; // Update the list of goals
        print(
          'GoalsViewModel: Received ${goals.length} goals. Setting _isLoading = false.',
        ); // Debug log
        _isLoading =
            false; // Data is loaded after the first emission, set loading to false
        _errorMessage = null; // Clear any previous errors
        print('GoalsViewModel: Calling notifyListeners().'); // Debug log
        notifyListeners(); // Notify listeners with the new data
      },
      onError: (error) {
        // Handle errors from the stream.
        print(
          'GoalsViewModel: Stream error: $error. Setting _isLoading = false.',
        ); // Debug log
        _goals = []; // Clear goals on error
        _isLoading = false; // Set loading to false on error
        _errorMessage = 'Error in goals stream: ${error.toString()}';
        print('GoalsViewModel: Calling notifyListeners().'); // Debug log
        notifyListeners();
        print('GoalsViewModel: Stream error: $error'); // Log the error
      },
      onDone: () {
        // Handle stream completion (less common for repositories that live long).
        print(
          'GoalsViewModel: Goals stream closed. Setting _isLoading = false.',
        ); // Debug log
        _isLoading = false; // Set loading to false if stream completes
        print('GoalsViewModel: Calling notifyListeners().'); // Debug log
        notifyListeners();
      },
    );
  }

  // Remove the old fetchGoals method.
  // @override
  // Future<void> fetchGoals() async {
  //   // This method is no longer needed as the stream subscription
  //   // triggers updates automatically.
  // }

  // Remember to dispose of resources by cancelling the subscription.
  @override
  void dispose() {
    // Cancel the stream subscription to prevent memory leaks.
    _goalsSubscription?.cancel();
    print('GoalsViewModel: Goals stream subscription cancelled.'); // Debug log
    super.dispose();
  }
}
