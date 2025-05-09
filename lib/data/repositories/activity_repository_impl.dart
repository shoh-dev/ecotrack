import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the abstract repository interface
import 'package:uuid/uuid.dart'; // We'll use this for generating unique IDs

// Add the uuid package dependency:
// flutter pub add uuid

// In-memory implementation of the ActivityRepository interface.
// Data is stored in a simple list in memory.
class ActivityRepositoryImpl implements ActivityRepository {
  // Use a static list to simulate data persistence across different instances
  // (though data is still lost on app restart).
  static final List<Activity> _activities = [];
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // Note: You will need to add the uuid package to your pubspec.yaml
  // using 'flutter pub add uuid' in the terminal.

  @override
  Future<String> saveActivity(Activity activity) async {
    // Generate a unique ID if the activity doesn't have one (useful for new activities)
    final activityToSave =
        activity.id.isEmpty
            ? Activity(
              id: _uuid.v4(), // Generate a new UUID
              category: activity.category,
              type: activity.type,
              timestamp: activity.timestamp,
              value: activity.value,
              unit: activity.unit,
              details: activity.details,
            )
            : activity;

    // In a real implementation, you'd save to a database or send to an API.
    // Here, we just add to the list.
    _activities.add(activityToSave);
    print('Saved activity: ${activityToSave.id}'); // For demonstration
    return activityToSave.id; // Return the ID of the saved activity
  }

  @override
  Future<List<Activity>> getActivities({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 100));

    // Filter activities based on optional criteria
    Iterable<Activity> filteredActivities =
        _activities.reversed; // Show newest first

    if (category != null) {
      filteredActivities = filteredActivities.where(
        (activity) => activity.category == category,
      );
    }
    if (startDate != null) {
      filteredActivities = filteredActivities.where(
        (activity) =>
            activity.timestamp.isAfter(startDate) ||
            activity.timestamp.isAtSameMomentAs(startDate),
      );
    }
    if (endDate != null) {
      filteredActivities = filteredActivities.where(
        (activity) =>
            activity.timestamp.isBefore(endDate) ||
            activity.timestamp.isAtSameMomentAs(endDate),
      );
    }

    return filteredActivities.toList();
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    // Remove the activity with the given ID
    _activities.removeWhere((activity) => activity.id == activityId);
    print('Deleted activity: $activityId'); // For demonstration
  }

  // Note: We are not implementing updateActivity for this basic example.
}
