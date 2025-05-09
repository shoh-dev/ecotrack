import 'package:ecotrack/domain/entities/activity.dart'; // Import Activity entity
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import FootprintEntry entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import ActivityRepository interface
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case.dart'; // Import the abstract use case interface
import 'package:uuid/uuid.dart'; // Import uuid for generating FootprintEntry ID

// Concrete implementation of the CalculateFootprintUseCase.
// Contains the business logic for calculating the eco-footprint.
class CalculateFootprintUseCaseImpl implements CalculateFootprintUseCase {
  final ActivityRepository
  _activityRepository; // Dependency on ActivityRepository
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // Constructor: Inject the ActivityRepository dependency.
  CalculateFootprintUseCaseImpl(this._activityRepository);

  @override
  Future<FootprintEntry> execute() async {
    print('CalculateFootprintUseCase: Starting calculation...'); // New log

    // 1. Fetch all activities.
    final allActivities = await _activityRepository.getActivities();
    print(
      'CalculateFootprintUseCase: Fetched ${allActivities.length} activities.',
    ); // New log

    // 2. Perform the footprint calculation based on the activities.
    // *** This is a simplified placeholder calculation. ***
    double totalCo2e = 0.0;
    Map<String, double> categoryBreakdown = {};

    for (final activity in allActivities) {
      double activityCo2e = 0.0; // CO2e for this specific activity

      print(
        'CalculateFootprintUseCase: Processing activity: ${activity.category}, Value: ${activity.value} ${activity.unit}',
      ); // New log

      // --- Simplified Calculation Logic Placeholder ---
      // Assign arbitrary CO2e based on category and value.
      // Replace this with actual emission factor calculations later.
      switch (activity.category) {
        case 'Transportation':
          // Example: Assume 0.1 kg CO2e per km for transportation value
          activityCo2e = activity.value * 0.1;
          break;
        case 'Home Energy':
          // Example: Assume 0.5 kg CO2e per kWh for energy value
          activityCo2e = activity.value * 0.5;
          break;
        case 'Diet':
          // Example: Assume 1.0 kg CO2e per meal count (very rough)
          activityCo2e = activity.value * 1.0;
          break;
        case 'Waste':
          // Example: Assume 0.2 kg CO2e per count of waste item (very rough)
          activityCo2e = activity.value * 0.2;
          break;
        case 'Consumption':
          // Example: Assume 0.3 kg CO2e per unit of consumption value (very rough)
          activityCo2e = activity.value * 0.3;
          break;
        default:
          // Unknown category, assume 0 impact for now
          activityCo2e = 0.0;
      }
      print(
        'CalculateFootprintUseCase: Calculated activityCo2e = $activityCo2e',
      ); // New log
      // --- End Simplified Calculation Logic Placeholder ---

      totalCo2e += activityCo2e;

      // Add to category breakdown
      categoryBreakdown[activity.category] =
          (categoryBreakdown[activity.category] ?? 0.0) + activityCo2e;
    }

    print('CalculateFootprintUseCase: Final totalCo2e = $totalCo2e'); // New log
    print(
      'CalculateFootprintUseCase: Final categoryBreakdown = $categoryBreakdown',
    ); // New log

    // 3. Create a new FootprintEntry with the calculated result.
    final newFootprintEntry = FootprintEntry(
      id: _uuid.v4(), // Generate a unique ID for this entry
      timestamp: DateTime.now(), // Timestamp when the calculation was performed
      totalCo2e: totalCo2e,
      categoryBreakdown: categoryBreakdown,
    );

    print(
      'CalculateFootprintUseCase: Calculation complete.',
    ); // Existing log (kept)

    // 4. Return the calculated footprint entry.
    return newFootprintEntry;
  }
}
