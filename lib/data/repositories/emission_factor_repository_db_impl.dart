import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'package:ecotrack/domain/entities/emission_factor.dart'; // Import the EmissionFactor entity
import 'package:ecotrack/domain/repositories/emission_factor_repository.dart'; // Import the abstract repository interface
import 'package:ecotrack/data/database_helper.dart'; // Import the DatabaseHelper
import 'package:uuid/uuid.dart'; // Assuming uuid is already added

// Database-backed implementation of the EmissionFactorRepository interface using sqflite.
// Emission factors are typically pre-populated or loaded from a static source into the database.
class EmissionFactorRepositoryDbImpl implements EmissionFactorRepository {
  final DatabaseHelper _databaseHelper; // Dependency on DatabaseHelper
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // Constructor: Inject the DatabaseHelper dependency.
  EmissionFactorRepositoryDbImpl(this._databaseHelper) {
    // In a real app, you might load default factors into the DB here if it's empty.
    // For this implementation, we assume the _onCreate method in DatabaseHelper
    // would handle initial population or factors are loaded via another mechanism.
    // We'll add a simple check/populate logic for demonstration.
    _checkAndPopulateDefaultFactors();
  }

  // Helper method to check if factors exist and populate if not.
  Future<void> _checkAndPopulateDefaultFactors() async {
    final db = await _databaseHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseHelper.emissionFactorTable}',
      ),
    );

    if (count == 0) {
      print(
        'EmissionFactorRepositoryDbImpl: Database is empty. Populating with default factors...',
      ); // Debug log
      // Define default factors (same as our in-memory list)
      final List<EmissionFactor> defaultFactors = [
        // Transportation Factors (example values, may vary by vehicle type, fuel, etc.)
        EmissionFactor(
          id: _uuid.v4(),
          activityCategory: 'Transportation',
          activityType: 'Car Trip',
          unit: 'km',
          co2ePerUnit: 0.21, // Example: kg CO2e per km for an average car
          source: 'Example Data Source A',
        ),
        EmissionFactor(
          id: _uuid.v4(),
          activityCategory: 'Transportation',
          activityType: 'Car Trip',
          unit: 'mile',
          co2ePerUnit: 0.34, // Example: kg CO2e per mile (0.21 * 1.60934)
          source: 'Example Data Source A',
        ),
        EmissionFactor(
          id: _uuid.v4(),
          activityCategory: 'Transportation',
          activityType: 'Bus Trip',
          unit: 'km',
          co2ePerUnit: 0.10, // Example: kg CO2e per km per passenger (average)
          source: 'Example Data Source B',
        ),
        EmissionFactor(
          id: _uuid.v4(),
          activityCategory: 'Transportation',
          activityType: 'Train Trip',
          unit: 'km',
          co2ePerUnit: 0.04, // Example: kg CO2e per km per passenger (average)
          source: 'Example Data Source B',
        ),
        // Home Energy Factors (example values, may vary by region, energy source)
        EmissionFactor(
          id: _uuid.v4(),
          activityCategory: 'Home Energy',
          activityType: 'Electricity Usage',
          unit: 'kWh',
          co2ePerUnit: 0.233, // Example: kg CO2e per kWh (US average)
          source: 'Example Data Source C',
        ),
        EmissionFactor(
          id: _uuid.v4(),
          activityCategory: 'Home Energy',
          activityType: 'Gas Usage',
          unit: 'kWh', // Or other units like therms, m³
          co2ePerUnit: 0.18, // Example: kg CO2e per kWh of natural gas
          source: 'Example Data Source C',
        ),
        // Add more factors for other categories (Diet, Waste, Consumption) later
      ];

      // Insert default factors into the database
      final batch = db.batch();
      for (final factor in defaultFactors) {
        batch.insert(DatabaseHelper.emissionFactorTable, _toMap(factor));
      }
      await batch.commit(noResult: true);
      print(
        'EmissionFactorRepositoryDbImpl: Default factors populated.',
      ); // Debug log
    } else {
      print(
        'EmissionFactorRepositoryDbImpl: Emission factors already exist in database ($count factors).',
      ); // Debug log
    }
  }

  // Helper method to convert EmissionFactor entity to a database Map.
  Map<String, dynamic> _toMap(EmissionFactor factor) {
    return {
      DatabaseHelper.columnFactorId:
          factor.id.isEmpty ? _uuid.v4() : factor.id, // Generate ID if empty
      DatabaseHelper.columnFactorActivityCategory: factor.activityCategory,
      DatabaseHelper.columnFactorActivityType: factor.activityType,
      DatabaseHelper.columnFactorUnit: factor.unit,
      DatabaseHelper.columnFactorCo2ePerUnit: factor.co2ePerUnit,
      DatabaseHelper.columnFactorSource: factor.source,
      DatabaseHelper.columnFactorEffectiveDate:
          factor
              .effectiveDate
              ?.millisecondsSinceEpoch, // Convert DateTime to Unix timestamp (INTEGER)
    };
  }

  // Helper method to convert a database Map to an EmissionFactor entity.
  EmissionFactor _fromMap(Map<String, dynamic> map) {
    return EmissionFactor(
      id: map[DatabaseHelper.columnFactorId] as String,
      activityCategory:
          map[DatabaseHelper.columnFactorActivityCategory] as String,
      activityType: map[DatabaseHelper.columnFactorActivityType] as String,
      unit: map[DatabaseHelper.columnFactorUnit] as String,
      co2ePerUnit: map[DatabaseHelper.columnFactorCo2ePerUnit] as double,
      source: map[DatabaseHelper.columnFactorSource] as String?,
      effectiveDate:
          map[DatabaseHelper.columnFactorEffectiveDate] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                map[DatabaseHelper.columnFactorEffectiveDate] as int,
              )
              : null, // Convert Unix timestamp back to DateTime
    );
  }

  @override
  void dispose() {
    print(
      'EmissionFactorRepositoryDbImpl: Dispose called (no streams to close).',
    ); // For demonstration
    // No StreamController in this repository as factors are typically static or updated less frequently.
    // If we added a watchFactors stream, we would close the controller here.
  }

  @override
  Future<List<EmissionFactor>> getAllFactors() async {
    final db = await _databaseHelper.database;

    print(
      'EmissionFactorRepositoryDbImpl: Getting all factors from database.',
    ); // For demonstration

    // Query the database
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.emissionFactorTable,
      // orderBy: '${DatabaseHelper.columnFactorActivityCategory} ASC', // Optional ordering
    );

    print(
      'EmissionFactorRepositoryDbImpl: Retrieved ${maps.length} factor maps.',
    ); // For demonstration

    // Convert the list of Maps to a list of EmissionFactor entities
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<EmissionFactor?> getFactorForActivity({
    required String activityCategory,
    required String activityType,
    required String unit,
    DateTime? timestamp, // Timestamp can be used for time-sensitive factors
  }) async {
    final db = await _databaseHelper.database;

    print(
      'EmissionFactorRepositoryDbImpl: Looking up factor in database for Category: $activityCategory, Type: $activityType, Unit: $unit',
    ); // For demonstration

    // Build the WHERE clause for matching category, type, and unit (case-insensitive for unit).
    final List<String> whereClauses = [
      '${DatabaseHelper.columnFactorActivityCategory} = ?',
      '${DatabaseHelper.columnFactorActivityType} = ?',
      'LOWER(${DatabaseHelper.columnFactorUnit}) = LOWER(?)', // Case-insensitive unit match
    ];
    final List<dynamic> whereArgs = [activityCategory, activityType, unit];

    // Add logic for time-sensitive factors if needed (e.g., filter by effectiveDate <= timestamp)
    // if (timestamp != null) {
    //   whereClauses.add('${DatabaseHelper.columnFactorEffectiveDate} <= ?');
    //   whereArgs.add(timestamp.millisecondsSinceEpoch);
    // }
    // Add ordering to get the most recent effective factor if multiple match
    // final orderBy = (timestamp != null) ? '${DatabaseHelper.columnFactorEffectiveDate} DESC' : null;

    final whereString = whereClauses.join(' AND ');

    // Query the database, limit to 1 as we expect at most one factor per criteria
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.emissionFactorTable,
      where: whereString,
      whereArgs: whereArgs,
      // orderBy: orderBy, // Apply ordering if using time-sensitive factors
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final factor = _fromMap(maps.first);
      print(
        'EmissionFactorRepositoryDbImpl: Found factor in database: ${factor.co2ePerUnit} for ${factor.unit}',
      ); // For demonstration
      return factor;
    } else {
      print(
        'EmissionFactorRepositoryDbImpl: No matching factor found in database.',
      ); // For demonstration
      return null;
    }
  }

  // Emission factors are typically not created/updated by the user through the app UI,
  // so saveFactor and deleteFactor methods are not included here.
  // If needed, they would interact with the database using db.insert, db.update, db.delete.
}
