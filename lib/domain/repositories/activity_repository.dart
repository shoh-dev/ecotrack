import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity

// Abstract interface defining the contract for Activity data operations.
// Implementations will be in the data layer (e.g., LocalDatabaseActivityRepository).
abstract class ActivityRepository {
  // Saves a single activity. Returns the saved activity or its ID.
  Future<String> saveActivity(Activity activity);

  // Gets a list of activities, optionally filtered by category or time range.
  Future<List<Activity>> getActivities({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  // Deletes a specific activity by its ID.
  Future<void> deleteActivity(String activityId);

  // --- Reactive Method ---
  // Returns a stream that emits the current list of activities whenever it changes.
  Stream<List<Activity>> watchActivities();
  // --- End Reactive Method ---

  // Remember to add a dispose method to close streams/resources in implementations.
  void dispose();
}
