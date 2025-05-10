import 'dart:async'; // Import async for StreamController
import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the abstract repository interface
import 'package:uuid/uuid.dart'; // Assuming uuid is already added for other repositories

// In-memory implementation of the ActivityRepository interface.
// Data is stored in a simple list in memory.
class ActivityRepositoryImpl implements ActivityRepository {
  // Use a static list to simulate data persistence across different instances
  // (though data is still lost on app restart).
  static final List<Activity> _activities = [];

  // StreamController to manage the stream of activity lists.
  // The stream will emit the current list whenever it changes.
  final _activitiesController =
      StreamController<
        List<Activity>
      >.broadcast(); // Use .broadcast for multiple listeners

  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // Note: You will need to add the uuid package to your pubspec.yaml
  // using 'flutter pub add uuid' in the terminal.

  @override
  Future<String> saveActivity(Activity activity) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 100));

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
    print(
      'ActivityRepositoryImpl: Saved activity: ${activityToSave.id}',
    ); // For demonstration

    // Add the updated list of activities to the stream.
    _activitiesController.sink.add(
      _activities.toList(),
    ); // Add a copy to the stream

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

    // --- New Debug Logs ---
    print(
      'ActivityRepositoryImpl.getActivities: Received startDate: ${startDate?.toIso8601String()}',
    );
    print(
      'ActivityRepositoryImpl.getActivities: Received endDate: ${endDate?.toIso8601String()}',
    );
    // --- End New Debug Logs ---

    print('ActivityRepositoryImpl: Getting activities...'); // For demonstration

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

    final result = filteredActivities.toList();
    print(
      'ActivityRepositoryImpl: Retrieved ${result.length} activities.',
    ); // For demonstration
    return result;
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 50));

    // Remove the activity with the given ID
    final initialLength = _activities.length;
    _activities.removeWhere((activity) => activity.id == activityId);
    if (_activities.length < initialLength) {
      print(
        'ActivityRepositoryImpl: Deleted activity with ID: $activityId',
      ); // For demonstration
      // Add the updated list of activities to the stream after deletion.
      _activitiesController.sink.add(
        _activities.toList(),
      ); // Add a copy to the stream
    } else {
      print(
        'ActivityRepositoryImpl: Goal with ID $activityId not found for deletion.',
      ); // For demonstration
    }
  }

  @override
  Stream<List<Activity>> watchActivities() {
    // Return the stream from the controller.
    // We also add the current list immediately when someone starts listening.
    // This ensures the listener gets the initial data.
    if (_activities.isNotEmpty) {
      _activitiesController.sink.add(_activities.toList());
    } else {
      _activitiesController.sink.add([]); // Emit empty list if no activities
    }
    return _activitiesController.stream;
  }

  @override
  void dispose() {
    // Close the stream controller when the repository is no longer needed.
    // This prevents memory leaks.
    _activitiesController.close();
    print(
      'ActivityRepositoryImpl: StreamController disposed.',
    ); // For demonstration
  }
}
