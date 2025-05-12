import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/entities/emission_factor.dart'; // Import EmissionFactor entity
import 'package:ecotrack/domain/entities/user_profile.dart'; // Import UserProfile entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the ActivityRepository interface
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the FootprintRepository interface
import 'package:ecotrack/domain/repositories/emission_factor_repository.dart'; // Import EmissionFactorRepository interface
import 'package:ecotrack/domain/repositories/user_profile_repository.dart'; // New: Import UserProfileRepository interface
import 'package:ecotrack/domain/use_cases/calculate_goal_progress_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the CalculateGoalProgressUseCase.
// This class contains the business logic for calculating progress towards a goal.
class CalculateGoalProgressUseCaseImpl implements CalculateGoalProgressUseCase {
  final ActivityRepository
  _activityRepository; // Dependency on ActivityRepository
  final FootprintRepository
  _footprintRepository; // Dependency on FootprintRepository
  final EmissionFactorRepository
  _emissionFactorRepository; // Dependency on EmissionFactorRepository
  final UserProfileRepository
  _userProfileRepository; // New: Dependency on UserProfileRepository

  // Constructor: Inject dependencies.
  CalculateGoalProgressUseCaseImpl(
    this._activityRepository,
    this._footprintRepository,
    this._emissionFactorRepository,
    this._userProfileRepository,
  ); // Inject UserProfileRepository

  @override
  Future<double> execute(Goal goal) async {
    print(
      'CalculateGoalProgressUseCase: Executing for goal: ${goal.name}',
    ); // Debug log
    print(
      'Goal Details: Type: ${goal.type}, Target: ${goal.targetValue} ${goal.targetUnit}, Dates: ${goal.startDate.toIso8601String()} to ${goal.endDate.toIso8601String()}',
    ); // Debug log
    print('Goal Details Map: ${goal.details}'); // Debug log

    // Get the user profile to access location for location-based factors.
    final userProfile = await _userProfileRepository.getUserProfile();
    print(
      'CalculateGoalProgressUseCase: Fetched user profile (found: ${userProfile != null}). Location: ${userProfile?.location}',
    ); // New Debug log

    // Business logic for different goal types.
    if (goal.type == 'ActivityTarget') {
      // --- Activity Target Logic (Debugging) ---
      print(
        'CalculateGoalProgressUseCase (ActivityTarget): Calculating progress...',
      ); // Debug log
      print(
        'Goal Details (ActivityTarget): Type: ${goal.type}, Target: ${goal.targetValue} ${goal.targetUnit}, Dates: ${goal.startDate.toIso8601String()} to ${goal.endDate.toIso8601String()}',
      ); // Debug log
      print('Goal Details Map (ActivityTarget): ${goal.details}'); // Debug log

      final relevantActivities = await _activityRepository.getActivities(
        startDate: goal.startDate,
        endDate: goal.endDate,
      );

      print(
        'CalculateGoalProgressUseCase (ActivityTarget): Fetched ${relevantActivities.length} activities within date range (${goal.startDate.toIso8601String()} to ${goal.endDate.toIso8601String()}).',
      ); // Debug log
      for (final activity in relevantActivities) {
        print(
          '  - Activity within range: Category: ${activity.category}, Type: ${activity.type}, Value: ${activity.value} ${activity.unit}, Timestamp: ${activity.timestamp.toIso8601String()}',
        ); // Debug log
      }

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

            print(
              '  - Filtering Activity: ${activity.type} (${activity.value} ${activity.unit}). Matches Category: $matchesCategory, Matches Type: $matchesType, Matches Unit: $matchesUnit',
            ); // Debug log

            return matchesCategory && matchesType && matchesUnit;
          }).toList();

      print(
        'CalculateGoalProgressUseCase (ActivityTarget): ${filteredActivities.length} activities matched goal details after filtering.',
      ); // Debug log
      for (final activity in filteredActivities) {
        print(
          '  - Filtered Activity (Matches): Category: ${activity.category}, Type: ${activity.type}, Value: ${activity.value} ${activity.unit}, Timestamp: ${activity.timestamp.toIso8601String()}',
        ); // Debug log
      }

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
      // --- Footprint Reduction Logic (Refining Baseline) ---
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Calculating progress...',
      ); // Debug log

      // Helper function to calculate footprint for a list of activities using EmissionFactorRepository.
      Future<double> _calculateFootprintForActivities(
        List<Activity> activities,
      ) async {
        double totalCo2e = 0.0;
        for (final activity in activities) {
          // Use the injected EmissionFactorRepository to get the factor, passing details and location.
          final factor = await _emissionFactorRepository.getFactorForActivity(
            activityCategory: activity.category,
            activityType: activity.type,
            unit: activity.unit,
            timestamp:
                activity
                    .timestamp, // Pass timestamp if factors are time-sensitive
            details: activity.details, // Pass activity details
            location: userProfile?.location, // Pass user location
          );
          if (factor != null) {
            totalCo2e += activity.value * factor.co2ePerUnit;
            // print('  - Footprint Calc: Activity ${activity.type} (${activity.value} ${activity.unit}) * Factor ${factor.co2ePerUnit} = ${activity.value * factor.co2ePerUnit}'); // Debug log (can be noisy)
          } else {
            // print('  - Footprint Calc: No factor found for ${activity.category} - ${activity.type} (${activity.unit}). Skipping.'); // Debug log (can be noisy)
          }
        }
        return totalCo2e;
      }

      // 1. Get all activities to calculate footprints within specific date ranges.
      final allActivities = await _activityRepository.getActivities();
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Fetched ${allActivities.length} total activities.',
      ); // Debug log

      // 2. Calculate the duration of the goal period.
      final goalDuration = goal.endDate.difference(goal.startDate);
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Goal duration: $goalDuration',
      ); // Debug log

      // 3. Determine the baseline period (same duration immediately before the goal starts).
      final baselineEndDate = goal.startDate;
      final baselineStartDate = goal.startDate.subtract(goalDuration);
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Baseline period: ${baselineStartDate.toIso8601String()} to ${baselineEndDate.toIso8601String()}',
      ); // Debug log

      // 4. Filter activities for the goal period (current footprint).
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
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): ${activitiesInGoalPeriod.length} activities in goal period.',
      ); // Debug log

      // 5. Filter activities for the baseline period.
      final activitiesInBaselinePeriod =
          allActivities
              .where(
                (activity) =>
                    (activity.timestamp.isAfter(baselineStartDate) ||
                        activity.timestamp.isAtSameMomentAs(
                          baselineStartDate,
                        )) &&
                    (activity.timestamp.isBefore(baselineEndDate) ||
                        activity.timestamp.isAtSameMomentAs(baselineEndDate)),
              )
              .toList();
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): ${activitiesInBaselinePeriod.length} activities in baseline period.',
      ); // Debug log

      // Calculate current footprint during the goal period using emission factors.
      final currentFootprint = await _calculateFootprintForActivities(
        activitiesInGoalPeriod,
      );
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Current footprint in goal period: ${currentFootprint.toStringAsFixed(2)} kg CO2e',
      ); // Debug log

      // Calculate baseline footprint from activities in the baseline period using emission factors.
      // If no activities before, assume a baseline (e.g., the average of the first few activities, or 0 if no history).
      // For simplicity here, let's calculate from activities before the goal.
      final baselineFootprint = await _calculateFootprintForActivities(
        activitiesInBaselinePeriod,
      );
      print(
        'CalculateGoalProgressUseCase (FootprintReduction): Baseline footprint in baseline period: ${baselineFootprint.toStringAsFixed(2)} kg CO2e',
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
      // Also, progress cannot exceed 100% (already handled by clamp, but explicit check can be good).
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
