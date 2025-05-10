import 'dart:async'; // Import async for StreamSubscription
import 'package:ecotrack/domain/entities/activity.dart';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import GoalRepository interface (for stream)
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import ActivityRepository interface (for stream)
import 'package:ecotrack/domain/use_cases/calculate_goal_progress_use_case.dart'; // Import CalculateGoalProgressUseCase

// GoalsViewModel manages the state and presentation logic for the GoalsScreen (Goals View).
// It now reacts to changes in both GoalRepository and ActivityRepository streams.
class GoalsViewModel extends ChangeNotifier {
  // Dependencies:
  final GoalRepository _goalRepository; // Dependency to subscribe to its stream
  final ActivityRepository
  _activityRepository; // Dependency to subscribe to its stream
  final CalculateGoalProgressUseCase
  _calculateGoalProgressUseCase; // Dependency to calculate progress

  // State properties for the Goals View:
  List<Goal> _goals = []; // Holds the list of goals
  final Map<String, double> _goalProgress =
      {}; // Holds progress for each goal (Goal ID -> progress percentage)

  bool _isLoading = false;
  String? _errorMessage; // Holds an error message if data fetching fails

  // Stream subscriptions.
  StreamSubscription<List<Goal>>? _goalsSubscription;
  StreamSubscription<List<Activity>>? _activitiesSubscription;

  // Constructor: Use Provider to inject dependencies.
  GoalsViewModel(
    this._goalRepository,
    this._activityRepository,
    this._calculateGoalProgressUseCase,
  ) {
    print(
      'GoalsViewModel: Initializing. Subscribing to goals and activities streams.',
    ); // Debug log
    // Subscribe to both streams immediately when the ViewModel is created.
    _subscribeToGoals(_goalRepository);
    _subscribeToActivities(_activityRepository);
  }

  // Getters to expose the state to the View:
  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Getter to expose goal progress.
  double getGoalProgress(String goalId) => _goalProgress[goalId] ?? 0.0;

  // Method to subscribe to the GoalRepository stream.
  void _subscribeToGoals(GoalRepository goalRepository) {
    _goalsSubscription?.cancel();
    _goalsSubscription = goalRepository.watchGoals().listen(
      (goals) async {
        // Make the listener async because we'll call an async Use Case
        print(
          'GoalsViewModel (Goals Stream): Received ${goals.length} goals.',
        ); // Debug log

        _goals = goals; // Update the list of goals
        _goalProgress
            .clear(); // Clear previous progress before calculating for the new list.

        print(
          'GoalsViewModel (Goals Stream): Recalculating progress for all goals...',
        ); // Debug log
        await _calculateProgressForAllGoals(); // Call helper method
        print(
          'GoalsViewModel (Goals Stream): Finished recalculating progress.',
        ); // Debug log

        print(
          'GoalsViewModel (Goals Stream): Finished processing goals. Setting _isLoading = false.',
        ); // Debug log
        _isLoading = false;
        _errorMessage = null;
        print(
          'GoalsViewModel (Goals Stream): Calling notifyListeners().',
        ); // Debug log
        notifyListeners();
      },
      onError: (error) {
        print(
          'GoalsViewModel (Goals Stream): Stream error: $error. Setting _isLoading = false.',
        ); // Debug log
        _goals = [];
        _goalProgress.clear();
        _isLoading = false;
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
        print(
          'GoalsViewModel (Goals Stream): Goals stream closed. Setting _isLoading = false.',
        ); // Debug log
        _isLoading = false;
        print(
          'GoalsViewModel (Goals Stream): Calling notifyListeners().',
        ); // Debug log
        notifyListeners();
      },
    );
  }

  // Method to subscribe to the ActivityRepository stream.
  void _subscribeToActivities(ActivityRepository activityRepository) {
    _activitiesSubscription?.cancel();
    _activitiesSubscription = activityRepository.watchActivities().listen(
      (activities) async {
        // Make the listener async
        // --- New Debug Log ---
        print(
          'GoalsViewModel (Activities Stream): Received ${activities.length} activities.',
        ); // Debug log
        // --- End New Debug Log ---

        // When activities change, recalculate progress for all *current* goals.
        print(
          'GoalsViewModel (Activities Stream): Activities stream updated. Recalculating progress for all goals...',
        ); // Debug log

        // We don't need the 'activities' list here directly, as the Use Case will fetch them.
        // We just need to know that activities have changed and recalculate progress for existing goals.

        // --- New Debug Log ---
        print(
          'GoalsViewModel (Activities Stream): Calling _calculateProgressForAllGoals()...',
        ); // Debug log
        // --- End New Debug Log ---
        await _calculateProgressForAllGoals(); // Call helper method
        // --- New Debug Log ---
        print(
          'GoalsViewModel (Activities Stream): _calculateProgressForAllGoals() finished.',
        ); // Debug log
        // --- End New Debug Log ---

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
    // Recalculate progress for each goal currently in _goals.
    for (final goal in _goals) {
      try {
        // --- New Debug Log ---
        print(
          'GoalsViewModel: Calculating progress for goal "${goal.name}" (ID: ${goal.id})...',
        ); // Debug log
        // --- End New Debug Log ---
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

  // Remember to dispose of resources by cancelling both subscriptions.
  @override
  void dispose() {
    _goalsSubscription?.cancel();
    _activitiesSubscription?.cancel();
    print('GoalsViewModel: Both stream subscriptions cancelled.'); // Debug log
    super.dispose();
  }
}
