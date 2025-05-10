import 'dart:async'; // Import async for StreamController
import 'dart:convert'; // Import convert for JSON encoding/decoding
import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'package:ecotrack/domain/entities/goal.dart'; // Import the Goal entity
import 'package:ecotrack/domain/repositories/goal_repository.dart'; // Import the abstract repository interface
import 'package:ecotrack/data/database_helper.dart'; // Import the DatabaseHelper
import 'package:uuid/uuid.dart'; // Assuming uuid is already added for generating IDs

// Database-backed implementation of the GoalRepository interface using sqflite.
class GoalRepositoryDbImpl implements GoalRepository {
  final DatabaseHelper _databaseHelper; // Dependency on DatabaseHelper
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // StreamController to manage the stream of goal lists.
  // The stream will emit the current list whenever it changes in the database.
  final _goalsController = StreamController<List<Goal>>.broadcast();

  // Constructor: Inject the DatabaseHelper dependency.
  GoalRepositoryDbImpl(this._databaseHelper);

  // Helper method to convert Goal entity to a database Map.
  Map<String, dynamic> _toMap(Goal goal) {
    return {
      DatabaseHelper.columnGoalId:
          goal.id.isEmpty ? _uuid.v4() : goal.id, // Generate ID if empty
      DatabaseHelper.columnGoalName: goal.name,
      DatabaseHelper.columnGoalDescription: goal.description,
      DatabaseHelper.columnGoalType: goal.type,
      DatabaseHelper.columnGoalTargetUnit: goal.targetUnit,
      DatabaseHelper.columnGoalTargetValue: goal.targetValue,
      DatabaseHelper.columnGoalStartDate:
          goal
              .startDate
              .millisecondsSinceEpoch, // Convert DateTime to Unix timestamp (INTEGER)
      DatabaseHelper.columnGoalEndDate:
          goal
              .endDate
              .millisecondsSinceEpoch, // Convert DateTime to Unix timestamp (INTEGER)
      DatabaseHelper.columnGoalStatus: goal.status,
      DatabaseHelper.columnGoalDetails:
          goal.details != null
              ? jsonEncode(goal.details)
              : null, // Convert Map to JSON string (TEXT)
    };
  }

  // Helper method to convert a database Map to a Goal entity.
  Goal _fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map[DatabaseHelper.columnGoalId] as String,
      name: map[DatabaseHelper.columnGoalName] as String,
      description:
          map[DatabaseHelper.columnGoalDescription] as String? ??
          '', // Handle potential null description
      type: map[DatabaseHelper.columnGoalType] as String,
      targetUnit: map[DatabaseHelper.columnGoalTargetUnit] as String,
      targetValue: map[DatabaseHelper.columnGoalTargetValue] as double,
      startDate: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseHelper.columnGoalStartDate] as int,
      ), // Convert Unix timestamp back to DateTime
      endDate: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseHelper.columnGoalEndDate] as int,
      ), // Convert Unix timestamp back to DateTime
      status: map[DatabaseHelper.columnGoalStatus] as String,
      details:
          map[DatabaseHelper.columnGoalDetails] != null
              ? jsonDecode(map[DatabaseHelper.columnGoalDetails] as String)
                  as Map<String, dynamic>
              : null, // Convert JSON string back to Map
    );
  }

  // Helper method to notify stream listeners after a database change.
  Future<void> _notifyListeners() async {
    // Fetch the latest data from the database and add it to the stream.
    final latestGoals = await getGoals(); // Reuse getGoals to fetch from DB
    _goalsController.sink.add(latestGoals);
  }

  @override
  Future<String> saveGoal(Goal goal) async {
    final db = await _databaseHelper.database;
    final goalMap = _toMap(goal);
    final goalId =
        goalMap[DatabaseHelper.columnGoalId]
            as String; // Get the ID (generated or existing)

    // If goal has an ID, attempt to update. Otherwise, insert.
    if (goal.id.isNotEmpty) {
      final rowsAffected = await db.update(
        DatabaseHelper.goalTable,
        goalMap,
        where: '${DatabaseHelper.columnGoalId} = ?',
        whereArgs: [goal.id],
      );
      if (rowsAffected > 0) {
        print('GoalRepositoryDbImpl: Updated goal with ID: ${goal.id}');
        await _notifyListeners(); // Notify after update
        return goal.id;
      }
    }

    // Insert new goal if no ID or update failed.
    await db.insert(
      DatabaseHelper.goalTable,
      goalMap,
      conflictAlgorithm:
          ConflictAlgorithm
              .replace, // Replace if ID already exists (shouldn't happen with new ID)
    );
    print('GoalRepositoryDbImpl: Inserted new goal with ID: $goalId');

    await _notifyListeners(); // Notify after insert

    return goalId; // Return the ID of the saved goal
  }

  @override
  Future<Goal?> getGoalById(String goalId) async {
    final db = await _databaseHelper.database;

    print('GoalRepositoryDbImpl: Getting goal by ID: $goalId'); // Debug log

    // Query the database for a single goal by ID
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.goalTable,
      where: '${DatabaseHelper.columnGoalId} = ?',
      whereArgs: [goalId],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final goal = _fromMap(maps.first);
      print(
        'GoalRepositoryDbImpl: Found goal for ID $goalId: ${goal.name}',
      ); // Debug log
      return goal;
    } else {
      print(
        'GoalRepositoryDbImpl: Goal with ID $goalId not found.',
      ); // Debug log
      return null;
    }
  }

  @override
  Future<List<Goal>> getGoals({String? status, String? type}) async {
    final db = await _databaseHelper.database;

    // Build the WHERE clause for filtering
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (status != null) {
      whereClauses.add('${DatabaseHelper.columnGoalStatus} = ?');
      whereArgs.add(status);
    }
    if (type != null) {
      whereClauses.add('${DatabaseHelper.columnGoalType} = ?');
      whereArgs.add(type);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    print(
      'GoalRepositoryDbImpl: Getting goals with WHERE: "$whereString", Args: $whereArgs',
    ); // Debug log

    // Query the database
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.goalTable,
      where: whereString,
      whereArgs: whereArgs,
      orderBy:
          '${DatabaseHelper.columnGoalStartDate} DESC', // Order by start date descending
    );

    print(
      'GoalRepositoryDbImpl: Retrieved ${maps.length} goal maps.',
    ); // Debug log

    // Convert the list of Maps to a list of Goal entities
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final db = await _databaseHelper.database;

    print('GoalRepositoryDbImpl: Deleting goal with ID: $goalId'); // Debug log

    final rowsAffected = await db.delete(
      DatabaseHelper.goalTable,
      where: '${DatabaseHelper.columnGoalId} = ?',
      whereArgs: [goalId],
    );

    if (rowsAffected > 0) {
      print('GoalRepositoryDbImpl: Deleted $rowsAffected rows.');
      await _notifyListeners(); // Notify after deletion
    } else {
      print(
        'GoalRepositoryDbImpl: No rows deleted for ID: $goalId (not found).',
      );
    }
  }

  @override
  Stream<List<Goal>> watchGoals() {
    print(
      'GoalRepositoryDbImpl: Someone is watching goals stream.',
    ); // Debug log
    // Add the current list immediately when someone starts listening.
    // Use Future.microtask to ensure the database is ready if this is called very early.
    Future.microtask(() async {
      await _notifyListeners(); // Emit the current data on subscription
    });
    return _goalsController.stream;
  }

  @override
  void dispose() {
    // Close the stream controller when the repository is no longer needed.
    _goalsController.close();
    print('GoalRepositoryDbImpl: StreamController disposed.'); // Debug log
    // Note: The DatabaseHelper instance is a singleton and its close() method
    // should be called when the entire app is shutting down, not necessarily here.
  }
}
