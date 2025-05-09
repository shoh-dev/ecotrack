import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart'; // Import GetFootprintHistory Use Case interface
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case.dart'; // Import CalculateFootprint Use Case interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import FootprintRepository interface

// DashboardViewModel manages the state and presentation logic for the HomeScreen (Dashboard View).
class DashboardViewModel extends ChangeNotifier {
  // Dependencies:
  final GetFootprintHistoryUseCase _getFootprintHistoryUseCase;
  final CalculateFootprintUseCase
  _calculateFootprintUseCase; // New dependency for calculation
  final FootprintRepository
  _footprintRepository; // New dependency to save the result

  // State properties for the Dashboard View:
  FootprintEntry? _latestFootprint; // Holds the most recent footprint data
  bool _isLoading =
      false; // Indicates if data is currently being loaded/calculated
  String?
  _errorMessage; // Holds an error message if data fetching/calculation fails

  // Constructor: Use Provider to inject dependencies.
  DashboardViewModel(
    this._getFootprintHistoryUseCase,
    this._calculateFootprintUseCase, // Inject the calculation use case
    this._footprintRepository, // Inject the footprint repository
  );

  // Getters to expose the state to the View:
  FootprintEntry? get latestFootprint => _latestFootprint;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to fetch and calculate data for the dashboard.
  Future<void> fetchDashboardData() async {
    _isLoading = true; // Set loading state to true
    _errorMessage = null; // Clear any previous errors
    notifyListeners(); // Notify listeners to show loading indicator

    try {
      // 1. Trigger the footprint calculation using the Use Case.
      final calculatedFootprint = await _calculateFootprintUseCase.execute();
      print('DashboardViewModel: Calculation complete.'); // For demonstration

      // 2. Save the newly calculated footprint entry using the repository.
      // This makes the calculated result available for future fetches.
      await _footprintRepository.saveFootprintEntry(calculatedFootprint);
      print('DashboardViewModel: Footprint entry saved.'); // For demonstration

      // 3. Fetch the latest footprint entry (which should now be the one we just saved).
      // We still use the GetFootprintHistoryUseCase or FootprintRepository
      // to ensure we are getting the data through the defined layer boundaries.
      // Using getLatestFootprintEntry from the repository is simplest here.
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
        'Error in DashboardViewModel.fetchDashboardData: $e',
      ); // Log the error
    }
  }

  // Remember to dispose of resources if needed.
  @override
  void dispose() {
    // Clean up resources like streams or controllers if used
    super.dispose();
  }
}
