import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the ActivityRepository interface
import 'package:ecotrack/domain/use_cases/calculate_goal_progress_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the CalculateGoalProgressUseCase.
// This class contains the business logic for calculating progress towards a goal.
class CalculateGoalProgressUseCaseImpl implements CalculateGoalProgressUseCase {
  final ActivityRepository
  _activityRepository; // Dependency on ActivityRepository

  // Constructor: Inject the ActivityRepository dependency.
  CalculateGoalProgressUseCaseImpl(this._activityRepository);

  @override
  Future<double> execute(Goal goal) async {
    print(
      'CalculateGoalProgressUseCase: Executing for goal: ${goal.name}',
    ); // Debug log
    print(
      'Goal Details: Type: ${goal.type}, Target: ${goal.targetValue} ${goal.targetUnit}, Dates: ${goal.startDate.toIso8601String()} to ${goal.endDate.toIso8601String()}',
    ); // New Debug log
    print('Goal Details Map: ${goal.details}'); // New Debug log

    // Business logic:
    // 1. Determine which activities are relevant to this goal (based on goal type, details, date range).
    // 2. Fetch relevant activities from the ActivityRepository.
    // 3. Aggregate the relevant activity data (e.g., sum values).
    // 4. Calculate progress based on the aggregated data and the goal's target value.

    // --- Simplified Progress Calculation Placeholder ---
    // This is a very basic placeholder. Actual logic will depend heavily on goal type and details.
    // For 'ActivityTarget' type, let's sum up activity values within the goal date range.
    if (goal.type == 'ActivityTarget') {
      final relevantActivities = await _activityRepository.getActivities(
        // Fetch activities within the goal's date range.
        startDate: goal.startDate,
        endDate: goal.endDate,
      );

      print(
        'CalculateGoalProgressUseCase: Fetched ${relevantActivities.length} activities within date range.',
      ); // New Debug log
      for (final activity in relevantActivities) {
        print(
          '  - Activity within range: Category: ${activity.category}, Type: ${activity.type}, Value: ${activity.value} ${activity.unit}, Timestamp: ${activity.timestamp.toIso8601String()}',
        ); // New Debug log
      }

      double accumulatedValue = 0.0;
      // Filter activities further based on goal details (category, type, unit).
      final filteredActivities =
          relevantActivities.where((activity) {
            bool matchesCategory =
                goal.details?['activityCategory'] == null ||
                activity.category == goal.details?['activityCategory'];
            bool matchesType =
                goal.details?['activityType'] == null ||
                activity.type == goal.details?['activityType'];
            bool matchesUnit =
                goal.targetUnit.isEmpty ||
                activity.unit.toLowerCase() ==
                    goal.targetUnit
                        .toLowerCase(); // Basic unit check, case-insensitive
            return matchesCategory && matchesType && matchesUnit;
          }).toList();

      print(
        'CalculateGoalProgressUseCase: ${filteredActivities.length} activities matched goal details after filtering.',
      ); // New Debug log
      for (final activity in filteredActivities) {
        print(
          '  - Filtered Activity: Category: ${activity.category}, Type: ${activity.type}, Value: ${activity.value} ${activity.unit}, Timestamp: ${activity.timestamp.toIso8601String()}',
        ); // New Debug log
      }

      for (final activity in filteredActivities) {
        // Simple summation - real logic might need unit conversion
        accumulatedValue += activity.value;
      }

      print(
        'CalculateGoalProgressUseCase: Accumulated value: $accumulatedValue ${goal.targetUnit}',
      ); // New Debug log

      // Progress as a percentage of the target value
      if (goal.targetValue <= 0) {
        print(
          'CalculateGoalProgressUseCase: Target value is <= 0. Progress is 0%.',
        ); // New Debug log
        return 0.0; // Avoid division by zero
      }
      double progress = (accumulatedValue / goal.targetValue) * 100.0;
      print(
        'CalculateGoalProgressUseCase: Calculated progress: ${progress.toStringAsFixed(2)}%',
      ); // New Debug log
      return progress.clamp(0.0, 100.0); // Clamp progress between 0 and 100%
    } else if (goal.type == 'FootprintReduction') {
      // Progress calculation for footprint reduction goals is more complex,
      // requiring historical baseline data and comparing current footprint.
      // Placeholder: return 0 for now.
      print(
        'CalculateGoalProgressUseCase: FootprintReduction goal type not fully implemented. Progress is 0%.',
      ); // Debug log
      return 0.0;
    }
    // Add other goal types here...
    print(
      'CalculateGoalProgressUseCase: Unknown goal type: ${goal.type}. Returning 0 progress.',
    ); // Debug log
    return 0.0; // Default to 0 progress for unknown types
    // --- End Simplified Progress Calculation Placeholder ---
  }
}
