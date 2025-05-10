import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/entities/emission_factor.dart'; // Import EmissionFactor entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the ActivityRepository interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the FootprintRepository interface
import 'package:ecotrack/domain/repositories/emission_factor_repository.dart'; // Import EmissionFactorRepository interface
import 'package:ecotrack/domain/use_cases/calculate_goal_progress_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the CalculateGoalProgressUseCase.
// This class contains the business logic for calculating progress towards a goal.
class CalculateGoalProgressUseCaseImpl implements CalculateGoalProgressUseCase {
  final ActivityRepository
  _activityRepository; // Dependency on ActivityRepository
  final FootprintRepository
  _footprintRepository; // New dependency on FootprintRepository
  final EmissionFactorRepository
  _emissionFactorRepository; // New dependency on EmissionFactorRepository

  // Constructor: Inject dependencies.
  CalculateGoalProgressUseCaseImpl(
    this._activityRepository,
    this._footprintRepository,
    this._emissionFactorRepository,
  );

  @override
  Future<double> execute(Goal goal) async {
    print(
      'CalculateGoalProgressUseCase: Executing for goal: ${goal.name}',
    ); // Debug log
    print(
      'Goal Details: Type: ${goal.type}, Target: ${goal.targetValue} ${goal.targetUnit}, Dates: ${goal.startDate.toIso8601String()} to ${goal.endDate.toIso8601String()}',
    ); // Debug log
    print('Goal Details Map: ${goal.details}'); // Debug log

    // Business logic for different goal types.
    if (goal.type == 'ActivityTarget') {
      // --- Activity Target Logic (Existing) ---
      final relevantActivities = await _activityRepository.getActivities(
        startDate: goal.startDate,
        endDate: goal.endDate,
      );

      print(
        'CalculateGoalProgressUseCase (ActivityTarget): Fetched ${relevantActivities.length} activities within date range.',
      ); // Debug log

      double accumulatedValue = 0.0;
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
        'CalculateGoalProgressUseCase (ActivityTarget): ${filteredActivities.length} activities matched goal details after filtering.',
      ); // Debug log

      for (final activity in filteredActivities) {
        accumulatedValue += activity.value;
      }

      print(
        'CalculateGoalProgressUseCase (ActivityTarget): Accumulated value: ${accumulatedValue.toStringAsFixed(2)} ${goal.targetUnit}',
      ); // Debug log

      if (goal.targetValue <= 0) {
        print(
          'CalculateGoalProgressUseCase (ActivityTarget): Target value is <= 0. Progress is 0%.',
        ); // Debug log
        return 0.0; // Avoid division by zero
      }
      double progress = (accumulatedValue / goal.targetValue) * 100.0;
      print(
        'CalculateGoalProgressUseCase (ActivityTarget): Calculated progress: ${progress.toStringAsFixed(2)}%',
      ); // Debug log
      return progress.clamp(0.0, 100.0); // Clamp progress between 0 and 100%
    } else if (goal.type == 'FootprintReduction') {
      // --- Footprint Reduction Logic (New) ---
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Calculating progress...',
      ); // Debug log

      // 1. Get all activities to calculate footprints.
      final allActivities = await _activityRepository.getActivities();

      // 2. Filter activities for the goal period (current footprint).
      final activitiesInGoalPeriod =
          allActivities
              .where(
                (activity) =>
                    (activity.timestamp.isAfter(goal.startDate) ||
                        activity.timestamp.isAtSameMomentAs(goal.startDate)) &&
                    (activity.timestamp.isBefore(goal.endDate) ||
                        activity.timestamp.isAtSameMomentAs(goal.endDate)),
              )
              .toList();

      // 3. Filter activities for the baseline period (before goal start).
      // This is a simplified baseline: activities before the goal started.
      // A more realistic baseline might be the same duration *before* the goal.
      final activitiesBeforeGoalPeriod =
          allActivities
              .where((activity) => activity.timestamp.isBefore(goal.startDate))
              .toList();

      // Helper function to calculate footprint for a list of activities.
      Future<double> _calculateFootprintForActivities(
        List<Activity> activities,
      ) async {
        double totalCo2e = 0.0;
        for (final activity in activities) {
          final factor = await _emissionFactorRepository.getFactorForActivity(
            activityCategory: activity.category,
            activityType: activity.type,
            unit: activity.unit,
            timestamp: activity.timestamp,
          );
          if (factor != null) {
            totalCo2e += activity.value * factor.co2ePerUnit;
          }
        }
        return totalCo2e;
      }

      // Calculate current footprint during the goal period.
      final currentFootprint = await _calculateFootprintForActivities(
        activitiesInGoalPeriod,
      );
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Current footprint in goal period: ${currentFootprint.toStringAsFixed(2)} kg CO2e',
      ); // Debug log

      // Calculate baseline footprint from activities before the goal started.
      // If no activities before, assume a baseline (e.g., the average of the first few activities, or 0 if no history).
      // For simplicity here, let's calculate from activities before the goal.
      final baselineFootprint = await _calculateFootprintForActivities(
        activitiesBeforeGoalPeriod,
      );
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Baseline footprint before goal period: ${baselineFootprint.toStringAsFixed(2)} kg CO2e',
      ); // Debug log

      // Calculate the reduction achieved so far.
      // Reduction = Baseline - Current
      final reductionAchieved = baselineFootprint - currentFootprint;
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Reduction achieved: ${reductionAchieved.toStringAsFixed(2)} kg CO2e',
      ); // Debug log

      // Calculate progress towards the target reduction.
      // Goal targetValue is the *desired reduction*.
      final targetReduction =
          goal.targetValue; // Assuming targetValue is the reduction target in kg CO2e

      if (targetReduction <= 0) {
        print(
          'CalculateGoalProgressUseCase (FootprintReduction): Target reduction is <= 0. Progress is 0%.',
        ); // Debug log
        return 0.0; // Avoid division by zero or negative target
      }

      // Progress is the achieved reduction as a percentage of the target reduction.
      double progress = (reductionAchieved / targetReduction) * 100.0;

      // If current footprint is higher than baseline (negative reduction), progress is 0.
      if (reductionAchieved < 0) {
        progress = 0.0;
        print(
          'CalculateGoalProgressUseCase (FootprintReduction): Current footprint is higher than baseline. Progress is 0%.',
        ); // Debug log
      }

      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Calculated progress: ${progress.toStringAsFixed(2)}%',
      ); // Debug log
      return progress.clamp(0.0, 100.0); // Clamp progress between 0 and 100%
    }
    // Add other goal types here...
    print(
      'CalculateGoalProgressUseCase: Unknown goal type: ${goal.type}. Returning 0 progress.',
    ); // Debug log
    return 0.0; // Default to 0 progress for unknown types
    // --- End Simplified Progress Calculation Placeholder ---
  }
}
