import 'dart:async'; // Import async for StreamSubscription
import 'package:ecotrack/domain/entities/activity.dart';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import GoalRepository interface (for stream)
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import ActivityRepository interface (for stream)
import 'package:ecotrack/domain/use_cases/calculate_goal_progress_use_case.dart'; // Import CalculateGoalProgressUseCase

// We no longer need GetGoalsUseCase here as we get goals directly from the stream.
// import 'package:ecotrack/domain/use_cases/get_goals_use_case.dart';
// We might also need CreateGoalUseCase here later if we add goal creation to this ViewModel.
// import 'package:ecotrack/domain/use_cases/create_goal_use_case.dart';

// GoalsViewModel manages the state and presentation logic for the GoalsScreen (Goals View).
// It now reacts to changes in both GoalRepository and ActivityRepository streams.
class GoalsViewModel extends ChangeNotifier {
  // Dependencies:
  final GoalRepository _goalRepository; // Dependency to subscribe to its stream
  final ActivityRepository
  _activityRepository; // New dependency to subscribe to its stream
  final CalculateGoalProgressUseCase
  _calculateGoalProgressUseCase; // Dependency to calculate progress
  // Potentially dependency on CreateGoalUseCase if goal creation is handled here.
  // final CreateGoalUseCase _createGoalUseCase;

  // State properties for the Goals View:
  List<Goal> _goals = []; // Holds the list of goals
  // We'll store progress separately, perhaps in a Map keyed by goal ID.
  final Map<String, double> _goalProgress =
      {}; // Holds progress for each goal (Goal ID -> progress percentage)

  // _isLoading starts as false by default. It will be set to true if an error occurs
  // during stream processing, but the initial state will be handled by the UI
  // checking if _goals is empty.
  bool _isLoading = false;
  String? _errorMessage; // Holds an error message if data fetching fails

  // Stream subscriptions.
  StreamSubscription<List<Goal>>? _goalsSubscription;
  StreamSubscription<List<Activity>>?
  _activitiesSubscription; // New subscription

  // Constructor: Use Provider to inject dependencies.
  GoalsViewModel(
    this._goalRepository,
    this._activityRepository, // Inject ActivityRepository
    this._calculateGoalProgressUseCase,
    /*this._createGoalUseCase*/
  ) {
    print(
      'GoalsViewModel: Initializing. Subscribing to goals and activities streams.',
    ); // Debug log
    // Subscribe to both streams immediately when the ViewModel is created.
    _subscribeToGoals(_goalRepository);
    _subscribeToActivities(_activityRepository); // New subscription call
  }

  // Getters to expose the state to the View:
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter to expose goal progress.
  double getGoalProgress(String goalId) => _goalProgress[goalId] ?? 0.0;

  // Method to subscribe to the GoalRepository stream.
  void _subscribeToGoals(GoalRepository goalRepository) {
    // Cancel any existing subscription before creating a new one.
    _goalsSubscription?.cancel();

    // Subscribe to the stream. The listener will be called whenever goals change.
    _goalsSubscription = goalRepository.watchGoals().listen(
      (goals) async {
        // Make the listener async because we'll call an async Use Case
        print(
          'GoalsViewModel (Goals Stream): Received ${goals.length} goals.',
        ); // Debug log

        // When goals change, update the ViewModel's state.
        print(
          'GoalsViewModel (Goals Stream): Goals list updated. Recalculating progress for all goals...',
        ); // Debug log
        _goals = goals; // Update the list of goals

        // Clear previous progress before calculating for the new list.
        _goalProgress.clear();

        // Calculate progress for each goal in the updated list based on *current* activity data.
        await _calculateProgressForAllGoals(); // Call helper method

        print(
          'GoalsViewModel (Goals Stream): Finished processing goals. Setting _isLoading = false.',
        ); // Debug log
        _isLoading =
            false; // Data is loaded after the first emission, set loading to false
        _errorMessage = null; // Clear any previous errors
        print(
          'GoalsViewModel (Goals Stream): Calling notifyListeners().',
        ); // Debug log
        notifyListeners(); // Notify listeners with the new data and calculated progress
      },
      onError: (error) {
        // Handle errors from the stream.
        print(
          'GoalsViewModel (Goals Stream): Stream error: $error. Setting _isLoading = false.',
        ); // Debug log
        _goals = []; // Clear goals on error
        _goalProgress.clear(); // Clear progress on error
        _isLoading = false; // Set loading to false on error
        _errorMessage = 'Error in goals stream: ${error.toString()}';
        print(
          'GoalsViewModel (Goals Stream): Calling notifyListeners().',
        ); // Debug log
        notifyListeners();
        print(
          'GoalsViewModel (Goals Stream): Stream error: $error',
        ); // Log the error
      },
      onDone: () {
        // Handle stream completion (less common for repositories that live long).
        print(
          'GoalsViewModel (Goals Stream): Goals stream closed. Setting _isLoading = false.',
        ); // Debug log
        _isLoading = false; // Set loading to false if stream completes
        print(
          'GoalsViewModel (Goals Stream): Calling notifyListeners().',
        ); // Debug log
        notifyListeners();
      },
    );
  }

  // Method to subscribe to the ActivityRepository stream.
  void _subscribeToActivities(ActivityRepository activityRepository) {
    // Cancel any existing subscription before creating a new one.
    _activitiesSubscription?.cancel();

    // Subscribe to the stream. The listener will be called whenever activities change.
    _activitiesSubscription = activityRepository.watchActivities().listen(
      (activities) async {
        // Make the listener async
        // When activities change, recalculate progress for all *current* goals.
        print(
          'GoalsViewModel (Activities Stream): Activities stream updated. Recalculating progress for all goals...',
        ); // Debug log

        // We don't need the 'activities' list here directly, as the Use Case will fetch them.
        // We just need to know that activities have changed and recalculate progress for existing goals.

        // Recalculate progress for each goal in the current list based on *new* activity data.
        await _calculateProgressForAllGoals(); // Call helper method

        // Note: We don't set _isLoading = false here, as the Goals Stream listener
        // is responsible for the primary data loading state. This listener just
        // triggers a recalculation and update.

        print(
          'GoalsViewModel (Activities Stream): Finished recalculating progress. Calling notifyListeners().',
        ); // Debug log
        notifyListeners(); // Notify listeners with the updated progress
      },
      onError: (error) {
        // Handle errors from the stream.
        print(
          'GoalsViewModel (Activities Stream): Stream error: ${error.toString()}',
        ); // Debug log
        // We might want to set an error message specific to progress calculation issues if needed.
      },
      onDone: () {
        // Handle stream completion.
        print(
          'GoalsViewModel (Activities Stream): Activity stream closed.',
        ); // Debug log
      },
    );
  }

  // Helper method to calculate progress for all goals.
  Future<void> _calculateProgressForAllGoals() async {
    // Calculate progress for each goal in the current list.
    // We don't clear _goalProgress here, as we might want to retain old progress
    // if a goal is removed from the list (though our current repo doesn't do that).
    // Let's clear it for simplicity for now.
    // _goalProgress.clear(); // Clearing is done in the Goals Stream listener

    // Recalculate progress for each goal currently in _goals.
    for (final goal in _goals) {
      try {
        final progress = await _calculateGoalProgressUseCase.execute(goal);
        _goalProgress[goal.id] = progress;
        print(
          'GoalsViewModel: Calculated progress for goal "${goal.name}": ${progress.toStringAsFixed(2)}%',
        ); // Debug log
      } catch (e) {
        print(
          'GoalsViewModel: Error calculating progress for goal "${goal.name}": $e',
        ); // Log calculation error
        _goalProgress[goal.id] = 0.0; // Set progress to 0 on error
      }
    }
  }

  // Remove the old fetchGoals method.
  // @override
  // Future<void> fetchGoals() async {
  //   // This method is no longer needed as the stream subscription
  //   // triggers updates automatically.
  // }

  // Remember to dispose of resources by cancelling both subscriptions.
  @override
  void dispose() {
    // Cancel both stream subscriptions to prevent memory leaks.
    _goalsSubscription?.cancel();
    _activitiesSubscription?.cancel(); // Cancel the new subscription
    print('GoalsViewModel: Both stream subscriptions cancelled.'); // Debug log
    super.dispose();
  }
}
