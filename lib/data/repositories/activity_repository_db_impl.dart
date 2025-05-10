import 'dart:async'; // Import async for StreamController
import 'dart:convert'; // Import convert for JSON encoding/decoding
import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'package:ecotrack/domain/entities/activity.dart'; // Import the Activity entity
import 'package:ecotrack/domain/repositories/activity_repository.dart'; // Import the abstract repository interface
import 'package:ecotrack/data/database_helper.dart'; // Import the DatabaseHelper
import 'package:uuid/uuid.dart'; // Assuming uuid is already added for generating IDs

// Database-backed implementation of the ActivityRepository interface using sqflite.
class ActivityRepositoryDbImpl implements ActivityRepository {
  final DatabaseHelper _databaseHelper; // Dependency on DatabaseHelper
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // StreamController to manage the stream of activity lists.
  // The stream will emit the current list whenever it changes in the database.
  final _activitiesController = StreamController<List<Activity>>.broadcast();

  // Constructor: Inject the DatabaseHelper dependency.
  ActivityRepositoryDbImpl(this._databaseHelper);

  // Helper method to convert Activity entity to a database Map.
  Map<String, dynamic> _toMap(Activity activity) {
    return {
      DatabaseHelper.columnActivityId:
          activity.id.isEmpty
              ? _uuid.v4()
              : activity.id, // Generate ID if empty
      DatabaseHelper.columnActivityCategory: activity.category,
      DatabaseHelper.columnActivityType: activity.type,
      DatabaseHelper.columnActivityTimestamp:
          activity
              .timestamp
              .millisecondsSinceEpoch, // Convert DateTime to Unix timestamp (INTEGER)
      DatabaseHelper.columnActivityValue: activity.value,
      DatabaseHelper.columnActivityUnit: activity.unit,
      DatabaseHelper.columnActivityDetails:
          activity.details != null
              ? jsonEncode(activity.details)
              : null, // Convert Map to JSON string (TEXT)
    };
  }

  // Helper method to convert a database Map to an Activity entity.
  Activity _fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map[DatabaseHelper.columnActivityId] as String,
      category: map[DatabaseHelper.columnActivityCategory] as String,
      type: map[DatabaseHelper.columnActivityType] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseHelper.columnActivityTimestamp] as int,
      ), // Convert Unix timestamp back to DateTime
      value: map[DatabaseHelper.columnActivityValue] as double,
      unit: map[DatabaseHelper.columnActivityUnit] as String,
      details:
          map[DatabaseHelper.columnActivityDetails] != null
              ? jsonDecode(map[DatabaseHelper.columnActivityDetails] as String)
                  as Map<String, dynamic>
              : null, // Convert JSON string back to Map
    );
  }

  // Helper method to notify stream listeners after a database change.
  Future<void> _notifyListeners() async {
    // Fetch the latest data from the database and add it to the stream.
    final latestActivities =
        await getActivities(); // Reuse getActivities to fetch from DB
    _activitiesController.sink.add(latestActivities);
  }

  @override
  Future<String> saveActivity(Activity activity) async {
    final db = await _databaseHelper.database;
    final activityMap = _toMap(activity);

    // If activity has an ID, attempt to update. Otherwise, insert.
    if (activity.id.isNotEmpty) {
      final rowsAffected = await db.update(
        DatabaseHelper.activityTable,
        activityMap,
        where: '${DatabaseHelper.columnActivityId} = ?',
        whereArgs: [activity.id],
      );
      if (rowsAffected > 0) {
        print(
          'ActivityRepositoryDbImpl: Updated activity with ID: ${activity.id}',
        );
        await _notifyListeners(); // Notify after update
        return activity.id;
      }
    }

    // Insert new activity if no ID or update failed.
    final newId =
        activityMap[DatabaseHelper.columnActivityId]
            as String; // Get the generated ID
    await db.insert(
      DatabaseHelper.activityTable,
      activityMap,
      conflictAlgorithm:
          ConflictAlgorithm
              .replace, // Replace if ID already exists (shouldn't happen with new ID)
    );
    print('ActivityRepositoryDbImpl: Inserted new activity with ID: $newId');

    await _notifyListeners(); // Notify after insert

    return newId; // Return the ID of the saved activity
  }

  @override
  Future<List<Activity>> getActivities({
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    // Build the WHERE clause for filtering
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (category != null) {
      whereClauses.add('${DatabaseHelper.columnActivityCategory} = ?');
      whereArgs.add(category);
    }
    if (startDate != null) {
      whereClauses.add('${DatabaseHelper.columnActivityTimestamp} >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      whereClauses.add('${DatabaseHelper.columnActivityTimestamp} <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    print(
      'ActivityRepositoryDbImpl: Getting activities with WHERE: "$whereString", Args: $whereArgs',
    ); // Debug log

    // Query the database
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.activityTable,
      where: whereString,
      whereArgs: whereArgs,
      orderBy:
          '${DatabaseHelper.columnActivityTimestamp} DESC', // Order by timestamp descending (newest first)
    );

    print(
      'ActivityRepositoryDbImpl: Retrieved ${maps.length} activity maps.',
    ); // Debug log

    // Convert the list of Maps to a list of Activity entities
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    final db = await _databaseHelper.database;

    print(
      'ActivityRepositoryDbImpl: Deleting activity with ID: $activityId',
    ); // Debug log

    final rowsAffected = await db.delete(
      DatabaseHelper.activityTable,
      where: '${DatabaseHelper.columnActivityId} = ?',
      whereArgs: [activityId],
    );

    if (rowsAffected > 0) {
      print('ActivityRepositoryDbImpl: Deleted $rowsAffected rows.');
      await _notifyListeners(); // Notify after deletion
    } else {
      print(
        'ActivityRepositoryDbImpl: No rows deleted for ID: $activityId (not found).',
      );
    }
  }

  @override
  Stream<List<Activity>> watchActivities() {
    print(
      'ActivityRepositoryDbImpl: Someone is watching activities stream.',
    ); // Debug log
    // Add the current list immediately when someone starts listening.
    // Use Future.microtask to ensure the database is ready if this is called very early.
    Future.microtask(() async {
      await _notifyListeners(); // Emit the current data on subscription
    });
    return _activitiesController.stream;
  }

  @override
  void dispose() {
    // Close the stream controller when the repository is no longer needed.
    _activitiesController.close();
    print('ActivityRepositoryDbImpl: StreamController disposed.'); // Debug log
    // Note: The DatabaseHelper instance is a singleton and its close() method
    // should be called when the entire app is shutting down, not necessarily here.
  }
}
