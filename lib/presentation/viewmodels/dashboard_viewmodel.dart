import 'dart:async'; // Import async for StreamSubscription
import 'package:ecotrack/domain/entities/activity.dart';
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart'; // Import GetFootprintHistory Use Case interface
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case.dart'; // Import CalculateFootprint Use Case interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import FootprintRepository interface
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import ActivityRepository interface (for stream)
// We might need fl_chart imports here later if we prepare data points in the ViewModel
// import 'package:fl_chart/fl_chart.dart';

// DashboardViewModel manages the state and presentation logic for the HomeScreen (Dashboard View).
// It now reacts to changes in the ActivityRepository stream and prepares historical footprint data.
class DashboardViewModel extends ChangeNotifier {
  // Dependencies:
  final GetFootprintHistoryUseCase
  _getFootprintHistoryUseCase; // Used to fetch historical data
  final CalculateFootprintUseCase
  _calculateFootprintUseCase; // Used to calculate footprint on activity change
  final FootprintRepository
  _footprintRepository; // Used to save the calculated footprint
  final ActivityRepository
  _activityRepository; // Dependency to subscribe to its stream

  // State properties for the Dashboard View:
  FootprintEntry? _latestFootprint; // Holds the most recent footprint data
  List<FootprintEntry> _footprintHistory =
      []; // New state property for historical data
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
    this._activityRepository,
  ) {
    print(
      'DashboardViewModel: Initializing. Subscribing to activities stream.',
    ); // Debug log
    // Subscribe to the activity stream immediately when the ViewModel is created.
    _subscribeToActivities(_activityRepository);
    // Initial loading state is handled by the UI checking _isLoading and _footprintHistory.
  }

  // Getters to expose the state to the View:
  FootprintEntry? get latestFootprint => _latestFootprint;
  List<FootprintEntry> get footprintHistory =>
      _footprintHistory; // New getter for history list
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to subscribe to the ActivityRepository stream.
  void _subscribeToActivities(ActivityRepository activityRepository) {
    _activitiesSubscription?.cancel();
    _activitiesSubscription = activityRepository.watchActivities().listen(
      (activities) async {
        // Make the listener async
        print(
          'DashboardViewModel: Activities stream updated. Recalculating footprint and fetching history...',
        ); // Debug log

        // When activities change, trigger the footprint calculation, save it, and then fetch the updated history.
        await _recalculateAndSaveFootprint();

        print(
          'DashboardViewModel: Finished processing activities stream update. Calling notifyListeners().',
        ); // Debug log
        notifyListeners(); // Notify listeners with the updated data and history
      },
      onError: (error) {
        print(
          'DashboardViewModel: Stream error: ${error.toString()}',
        ); // Debug log
        _latestFootprint = null;
        _footprintHistory = []; // Clear history on error
        _isLoading = false;
        _errorMessage = 'Error in activity stream: ${error.toString()}';
        notifyListeners();
        print('DashboardViewModel: Stream error: $error'); // Log the error
      },
      onDone: () {
        print('DashboardViewModel: Activity stream closed.'); // Debug log
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Private method to perform the calculation, saving, and history fetching logic.
  Future<void> _recalculateAndSaveFootprint() async {
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    // Don't notifyListeners here to avoid showing loading spinner for every activity change while on dashboard.
    // The notifyListeners after this method completes will update the UI.

    try {
      // 1. Trigger the footprint calculation using the Use Case.
      final calculatedFootprint = await _calculateFootprintUseCase.execute();
      print('DashboardViewModel: Calculation complete.'); // For demonstration

      // 2. Save the newly calculated footprint entry using the repository.
      await _footprintRepository.saveFootprintEntry(calculatedFootprint);
      print('DashboardViewModel: Footprint entry saved.'); // For demonstration

      // 3. Fetch the historical footprint entries.
      // We can add date range filtering here later if needed (e.g., last 30 days).
      _footprintHistory =
          await _getFootprintHistoryUseCase.execute(); // Fetch all history
      print(
        'DashboardViewModel: Fetched ${_footprintHistory.length} historical entries.',
      ); // For demonstration

      // 4. Find the latest entry from the fetched history.
      _latestFootprint =
          _footprintHistory.isNotEmpty
              ? _footprintHistory.first
              : null; // Assuming history is ordered newest first
      print(
        'DashboardViewModel: Identified latest entry from history.',
      ); // For demonstration

      _isLoading = false; // Set loading state to false
      print(
        'DashboardViewModel: Finished recalculating and fetching history. Setting _isLoading = false.',
      ); // Debug log
    } catch (e) {
      // Handle errors during data fetching or calculation
      print(
        'DashboardViewModel: Error in _recalculateAndSaveFootprint: $e',
      ); // Debug log
      _latestFootprint = null;
      _footprintHistory = []; // Clear history on error
      _isLoading = false; // Set loading state to false
      _errorMessage =
          'Failed to load/calculate footprint data: ${e.toString()}'; // Set error message
      // notifyListeners() is called in the stream listener's finally block.
    }
    // Note: notifyListeners is called in the stream listener after this method completes.
  }

  // Helper getter to prepare data for a line chart (example - can be refined)
  // You would call this from your DashboardScreen build method.
  /*
  List<FlSpot> get footprintChartData {
    // Convert FootprintEntry list to a list of FlSpot points.
    // X-axis could be time (converted to a numerical value), Y-axis is CO2e.
    // Need to decide on the time representation for the X-axis (e.g., days since start, Unix timestamp).
    // For simplicity, let's use the index as the X value for now, and CO2e as Y.
    // A better approach would map timestamp to a meaningful X value (e.g., DateTime to double).

    // Example: Sort by timestamp ascending for chart display
    final sortedHistory = footprintHistory.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedHistory.asMap().entries.map((entry) {
      // entry.key is the index, entry.value is the FootprintEntry
      // Convert timestamp to a double for the X axis.
      // A common way is to use millisecondsSinceEpoch and scale it.
      // Or simply use the index for now if time spacing isn't critical.
      final double xValue = entry.key.toDouble(); // Using index as X for simplicity
      final double yValue = entry.value.totalCo2e;
      return FlSpot(xValue, yValue);
    }).toList();
  }
  */

  // Remember to dispose of resources by cancelling the subscription.
  @override
  void dispose() {
    _activitiesSubscription?.cancel();
    print(
      'DashboardViewModel: Activities stream subscription cancelled.',
    ); // Debug log
    super.dispose();
  }
}
