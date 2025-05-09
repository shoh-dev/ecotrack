import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart'; // Import the Use Case interface

// DashboardViewModel manages the state and presentation logic for the HomeScreen (Dashboard View).
class DashboardViewModel extends ChangeNotifier {
  // Dependency on the Use Case to fetch footprint data.
  final GetFootprintHistoryUseCase _getFootprintHistoryUseCase;

  // State properties for the Dashboard View:
  FootprintEntry? _latestFootprint; // Holds the most recent footprint data
  bool _isLoading = false; // Indicates if data is currently being loaded
  String? _errorMessage; // Holds an error message if data fetching fails

  // Constructor: Use Provider to inject the GetFootprintHistoryUseCase.
  DashboardViewModel(this._getFootprintHistoryUseCase);

  // Getters to expose the state to the View:
  FootprintEntry? get latestFootprint => _latestFootprint;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to fetch initial data for the dashboard.
  Future<void> fetchDashboardData() async {
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    notifyListeners(); // Notify listeners to show loading indicator

    try {
      // Call the Use Case to get the footprint history.
      // For the dashboard, we might only need the latest entry or a short history.
      // The Use Case implementation will handle the details of fetching from the repository.
      final history = await _getFootprintHistoryUseCase.execute();

      // Assuming the Use Case returns the history, find the latest entry.
      if (history.isNotEmpty) {
        _latestFootprint =
            history.first; // Assuming history is ordered newest first
      } else {
        _latestFootprint = null; // No history found
      }

      _isLoading = false; // Set loading state to false
      notifyListeners(); // Notify listeners with the fetched data or empty state
    } catch (e) {
      // Handle errors during data fetching
      _latestFootprint = null; // Clear data on error
      _isLoading = false; // Set loading state to false
      _errorMessage =
          'Failed to load footprint data: ${e.toString()}'; // Set error message
      notifyListeners(); // Notify listeners with the error state
      print('Error fetching dashboard data: $e'); // Log the error
    }
  }

  // Remember to dispose of resources if needed.
  @override
  void dispose() {
    // Clean up resources like streams or controllers if used
    super.dispose();
  }
}
