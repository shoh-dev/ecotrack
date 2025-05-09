import 'dart:async'; // Import async for StreamSubscription
import 'package:ecotrack/domain/entities/activity.dart';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart'; // Import GetFootprintHistory Use Case interface
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case.dart'; // Import CalculateFootprint Use Case interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import FootprintRepository interface
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import ActivityRepository interface (for stream)

// DashboardViewModel manages the state and presentation logic for the HomeScreen (Dashboard View).
// It now reacts to changes in the ActivityRepository stream.
class DashboardViewModel extends ChangeNotifier {
  // Dependencies:
  final GetFootprintHistoryUseCase
  _getFootprintHistoryUseCase; // Still useful for history view later
  final CalculateFootprintUseCase
  _calculateFootprintUseCase; // Used to calculate footprint on activity change
  final FootprintRepository
  _footprintRepository; // Used to save the calculated footprint
  final ActivityRepository
  _activityRepository; // New dependency to subscribe to its stream

  // State properties for the Dashboard View:
  FootprintEntry? _latestFootprint; // Holds the most recent footprint data
  bool _isLoading =
      false; // Indicates if data is currently being loaded/calculated
  String?
  _errorMessage; // Holds an error message if data fetching/calculation fails

  // Stream subscription to activities.
  StreamSubscription<List<Activity>>? _activitiesSubscription;

  // Constructor: Use Provider to inject dependencies.
  DashboardViewModel(
    this._getFootprintHistoryUseCase,
    this._calculateFootprintUseCase,
    this._footprintRepository,
    this._activityRepository, // Inject ActivityRepository
  ) {
    // Subscribe to the activity stream immediately when the ViewModel is created.
    _subscribeToActivities(_activityRepository);
  }

  // Getters to expose the state to the View:
  FootprintEntry? get latestFootprint => _latestFootprint;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to subscribe to the ActivityRepository stream.
  void _subscribeToActivities(ActivityRepository activityRepository) {
    // Cancel any existing subscription before creating a new one.
    _activitiesSubscription?.cancel();

    // Subscribe to the stream. The listener will be called whenever activities change.
    _activitiesSubscription = activityRepository.watchActivities().listen(
      (activities) async {
        // When activities change, trigger the footprint calculation and update.
        print(
          'DashboardViewModel: Activities stream updated. Recalculating footprint...',
        ); // Debug log
        await _recalculateAndSaveFootprint();
      },
      onError: (error) {
        // Handle errors from the stream.
        _latestFootprint = null;
        _isLoading = false;
        _errorMessage = 'Error in activity stream: ${error.toString()}';
        notifyListeners();
        print('DashboardViewModel: Stream error: $error'); // Log the error
      },
      onDone: () {
        // Handle stream completion (less common for repositories that live long).
        print('DashboardViewModel: Activity stream closed.'); // Debug log
      },
    );
  }

  // Private method to perform the calculation and saving logic.
  // This was previously inside fetchDashboardData().
  Future<void> _recalculateAndSaveFootprint() async {
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    notifyListeners(); // Notify listeners to show loading indicator

    try {
      // 1. Trigger the footprint calculation using the Use Case.
      final calculatedFootprint = await _calculateFootprintUseCase.execute();
      print('DashboardViewModel: Calculation complete.'); // For demonstration

      // 2. Save the newly calculated footprint entry using the repository.
      await _footprintRepository.saveFootprintEntry(calculatedFootprint);
      print('DashboardViewModel: Footprint entry saved.'); // For demonstration

      // 3. Fetch the latest footprint entry (which should now be the one we just saved).
      _latestFootprint = await _footprintRepository.getLatestFootprintEntry();
      print('DashboardViewModel: Fetched latest entry.'); // For demonstration

      _isLoading = false; // Set loading state to false
      notifyListeners(); // Notify listeners with the fetched data or empty state
    } catch (e) {
      // Handle errors during data fetching or calculation
      _latestFootprint = null; // Clear data on error
      _isLoading = false; // Set loading state to false
      _errorMessage =
          'Failed to load/calculate footprint data: ${e.toString()}'; // Set error message
      notifyListeners(); // Notify listeners with the error state
      print(
        'Error in DashboardViewModel._recalculateAndSaveFootprint: $e',
      ); // Log the error
    }
  }

  // Remove the old fetchDashboardData method.
  // @override
  // Future<void> fetchDashboardData() async {
  //   // This method is no longer needed as the stream subscription
  //   // triggers updates automatically.
  // }

  // Remember to dispose of resources by cancelling the subscription.
  @override
  void dispose() {
    // Cancel the stream subscription to prevent memory leaks.
    _activitiesSubscription?.cancel();
    print(
      'DashboardViewModel: Activities stream subscription cancelled.',
    ); // Debug log
    super.dispose();
  }
}
