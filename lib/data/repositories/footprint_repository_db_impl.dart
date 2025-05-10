import 'dart:convert'; // Import convert for JSON encoding/decoding
import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the abstract repository interface
import 'package:ecotrack/data/database_helper.dart'; // Import the DatabaseHelper
import 'package:uuid/uuid.dart'; // Assuming uuid is already added for generating IDs

// Database-backed implementation of the FootprintRepository interface using sqflite.
class FootprintRepositoryDbImpl implements FootprintRepository {
  final DatabaseHelper _databaseHelper; // Dependency on DatabaseHelper
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // Constructor: Inject the DatabaseHelper dependency.
  FootprintRepositoryDbImpl(this._databaseHelper);

  // Helper method to convert FootprintEntry entity to a database Map.
  Map<String, dynamic> _toMap(FootprintEntry entry) {
    return {
      DatabaseHelper.columnFootprintId:
          entry.id.isEmpty ? _uuid.v4() : entry.id, // Generate ID if empty
      DatabaseHelper.columnFootprintTimestamp:
          entry
              .timestamp
              .millisecondsSinceEpoch, // Convert DateTime to Unix timestamp (INTEGER)
      DatabaseHelper.columnFootprintTotalCo2e: entry.totalCo2e,
      DatabaseHelper.columnFootprintCategoryBreakdown:
          entry.categoryBreakdown != null
              ? jsonEncode(entry.categoryBreakdown)
              : null, // Convert Map to JSON string (TEXT)
    };
  }

  // Helper method to convert a database Map to a FootprintEntry entity.
  FootprintEntry _fromMap(Map<String, dynamic> map) {
    // Correctly handle JSON decoding and conversion for categoryBreakdown
    Map<String, double>? categoryBreakdown;
    final breakdownJson = map[DatabaseHelper.columnFootprintCategoryBreakdown];
    if (breakdownJson != null && breakdownJson is String) {
      try {
        final decodedMap = jsonDecode(breakdownJson) as Map<String, dynamic>;
        // Convert values from dynamic to double
        categoryBreakdown = decodedMap.map(
          (key, value) => MapEntry(key, value is num ? value.toDouble() : 0.0),
        );
      } catch (e) {
        print(
          'FootprintRepositoryDbImpl: Error decoding categoryBreakdown JSON: $e',
        );
        categoryBreakdown = null; // Set to null on decoding error
      }
    }

    return FootprintEntry(
      id: map[DatabaseHelper.columnFootprintId] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map[DatabaseHelper.columnFootprintTimestamp] as int,
      ), // Convert Unix timestamp back to DateTime
      totalCo2e: map[DatabaseHelper.columnFootprintTotalCo2e] as double,
      categoryBreakdown: categoryBreakdown, // Use the correctly converted map
    );
  }

  @override
  Future<void> saveFootprintEntry(FootprintEntry entry) async {
    final db = await _databaseHelper.database;
    final entryMap = _toMap(entry);

    // If entry has an ID, attempt to update. Otherwise, insert.
    // For footprint entries, we typically insert new ones rather than update existing by ID,
    // but the save method can handle both. We'll primarily use insert.
    if (entry.id.isNotEmpty) {
      final rowsAffected = await db.update(
        DatabaseHelper.footprintTable,
        entryMap,
        where: '${DatabaseHelper.columnFootprintId} = ?',
        whereArgs: [entry.id],
      );
      if (rowsAffected > 0) {
        print('FootprintRepositoryDbImpl: Updated entry with ID: ${entry.id}');
        // Footprint entries don't typically have a stream to notify,
        // as the dashboard ViewModel recalculates from activities.
        return;
      }
    }

    // Insert new entry.
    await db.insert(
      DatabaseHelper.footprintTable,
      entryMap,
      conflictAlgorithm:
          ConflictAlgorithm
              .replace, // Replace if ID already exists (shouldn't happen with new ID)
    );
    print(
      'FootprintRepositoryDbImpl: Inserted new entry with ID: ${entryMap[DatabaseHelper.columnFootprintId]}',
    );

    // Footprint entries don't typically have a stream to notify,
    // as the dashboard ViewModel recalculates from activities.
  }

  @override
  Future<List<FootprintEntry>> getFootprintHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    // Build the WHERE clause for filtering by timestamp
    final List<String> whereClauses = [];
    final List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClauses.add('${DatabaseHelper.columnFootprintTimestamp} >= ?');
      whereArgs.add(startDate.millisecondsSinceEpoch);
    }
    if (endDate != null) {
      whereClauses.add('${DatabaseHelper.columnFootprintTimestamp} <= ?');
      whereArgs.add(endDate.millisecondsSinceEpoch);
    }

    final whereString =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    print(
      'FootprintRepositoryDbImpl: Getting footprint history with WHERE: "$whereString", Args: $whereArgs',
    ); // Debug log

    // Query the database
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.footprintTable,
      where: whereString,
      whereArgs: whereArgs,
      orderBy:
          '${DatabaseHelper.columnFootprintTimestamp} DESC', // Order by timestamp descending (newest first)
    );

    print(
      'FootprintRepositoryDbImpl: Retrieved ${maps.length} footprint maps.',
    ); // Debug log

    // Convert the list of Maps to a list of FootprintEntry entities
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<FootprintEntry?> getLatestFootprintEntry() async {
    final db = await _databaseHelper.database;

    print(
      'FootprintRepositoryDbImpl: Getting latest footprint entry...',
    ); // Debug log

    // Query the database, order by timestamp descending, limit to 1
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.footprintTable,
      orderBy: '${DatabaseHelper.columnFootprintTimestamp} DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final latest = _fromMap(maps.first);
      print(
        'FootprintRepositoryDbImpl: Found latest entry: ${latest.totalCo2e}',
      ); // Debug log
      return latest;
    } else {
      print('FootprintRepositoryDbImpl: No latest entry found.'); // Debug log
      return null;
    }
  }

  // FootprintRepository does not have a stream or dispose method in its abstract interface.
  // If we were to make FootprintRepository reactive (e.g., watchHistory), we would add a StreamController here and implement dispose.
}
