import 'dart:async'; // Import async for StreamController
import 'package:ecotrack/domain/entities/resource.dart';
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

  // StreamController for watchResources. For static data, it mainly emits the list once.
  final _resourcesController =
      StreamController<
        List<Resource>
      >.broadcast(); // Note: This controller is for Resources, not EmissionFactors. EmissionFactorRepository is not reactive in this implementation.

  // Constructor: Inject the DatabaseHelper dependency.
  EmissionFactorRepositoryDbImpl(this._databaseHelper) {
    // Check if factors exist and populate if not.
    _checkAndPopulateDefaultFactors();
    print(
      'EmissionFactorRepositoryDbImpl: Constructor finished. _checkAndPopulateDefaultFactors called.',
    ); // Debug log
  }

  // Helper method to check if factors exist and populate if not.
  // This is where you define your default factors.
  Future<void> _checkAndPopulateDefaultFactors() async {
    print(
      'EmissionFactorRepositoryDbImpl: _checkAndPopulateDefaultFactors starting...',
    ); // Debug log
    final db = await _databaseHelper.database;

    final factorsCount = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM ${DatabaseHelper.emissionFactorTable}',
      ),
    );

    print(
      'EmissionFactorRepositoryDbImpl: Checking emission factor count. Found $factorsCount.',
    ); // Debug log

    if (factorsCount == 0) {
      print(
        'EmissionFactorRepositoryDbImpl: Emission factors table is empty. Populating with default factors...',
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
        // Example with details:
        EmissionFactor(
          id: _uuid.v4(),
          activityCategory: 'Transportation',
          activityType: 'Car Trip',
          unit: 'km',
          co2ePerUnit: 0.18, // Example: kg CO2e per km for a Small Car
          source: 'Example Data Source A',
          // You would need columns in the DB table for details like 'vehicleType'
          // and update _toMap/_fromMap to handle them.
          // For this simplified DB impl, we'll just match on category/type/unit.
          // details: {'vehicleType': 'Small Car'},
        ),
      ];

      // Insert default factors into the database
      final batch = db.batch();
      for (final factor in defaultFactors) {
        batch.insert(DatabaseHelper.emissionFactorTable, _toMap(factor));
      }
      print(
        'ResourceRepositoryDbImpl: Starting batch commit for population.',
      ); // Debug log
      await batch.commit(noResult: true);
      print(
        'ResourceRepositoryDbImpl: Batch commit finished. Default factors populated.',
      ); // Debug log
    } else {
      print(
        'EmissionFactorRepositoryDbImpl: Emission factors already exist in database ($factorsCount factors).',
      ); // Debug log
    }
    print(
      'EmissionFactorRepositoryDbImpl: _checkAndPopulateDefaultFactors finished.',
    ); // Debug log
  }

  // Helper method to convert EmissionFactor entity to a database Map.
  Map<String, dynamic> _toMap(EmissionFactor factor) {
    return {
      DatabaseHelper.columnFactorId:
          factor.id.isEmpty ? _uuid.v4() : factor.id, // Use FactorId constant
      DatabaseHelper.columnFactorActivityCategory:
          factor.activityCategory, // Use FactorActivityCategory constant
      DatabaseHelper.columnFactorActivityType:
          factor.activityType, // Use FactorActivityType constant
      DatabaseHelper.columnFactorUnit: factor.unit, // Use FactorUnit constant
      DatabaseHelper.columnFactorCo2ePerUnit:
          factor.co2ePerUnit, // Use FactorCo2ePerUnit constant
      DatabaseHelper.columnFactorSource:
          factor.source, // Use FactorSource constant
      DatabaseHelper.columnFactorEffectiveDate:
          factor
              .effectiveDate
              ?.millisecondsSinceEpoch, // Use FactorEffectiveDate constant (INTEGER)
      // Add columns for details if needed in the DB schema
      // 'applicableVehicleType': factor.details?['vehicleType'],
    };
  }

  // Helper method to convert a database Map to an EmissionFactor entity.
  EmissionFactor _fromMap(Map<String, dynamic> map) {
    return EmissionFactor(
      id: map[DatabaseHelper.columnFactorId] as String, // Use FactorId constant
      activityCategory:
          map[DatabaseHelper.columnFactorActivityCategory]
              as String, // Use FactorActivityCategory constant
      activityType:
          map[DatabaseHelper.columnFactorActivityType]
              as String, // Use FactorActivityType constant
      unit:
          map[DatabaseHelper.columnFactorUnit]
              as String, // Use FactorUnit constant
      co2ePerUnit:
          map[DatabaseHelper.columnFactorCo2ePerUnit]
              as double, // Use FactorCo2ePerUnit constant
      source:
          map[DatabaseHelper.columnFactorSource]
              as String?, // Use FactorSource constant
      effectiveDate:
          map[DatabaseHelper.columnFactorEffectiveDate] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                map[DatabaseHelper.columnFactorEffectiveDate] as int,
              )
              : null, // Use FactorEffectiveDate constant
      // Read details from DB columns if they exist
      // details: map['applicableVehicleType'] != null ? {'vehicleType': map['applicableVehicleType']} : null,
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
    ); // Debug log

    // Query the database
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.emissionFactorTable, // Use the correct table name
      // orderBy: '${DatabaseHelper.columnFactorEffectiveDate} DESC', // Optional ordering
    );

    print(
      'EmissionFactorRepositoryDbImpl: Retrieved ${maps.length} factor maps.',
    ); // Debug log

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
    Map<String, dynamic>? details, // New: Additional activity details
    String? location, // New: User's location/region
  }) async {
    final db = await _databaseHelper.database;

    print(
      'EmissionFactorRepositoryDbImpl: Looking up factor in database for Category: $activityCategory, Type: $activityType, Unit: $unit, Details: $details, Location: $location',
    ); // New Debug log

    // Build the WHERE clause for matching category, type, and unit (case-insensitive for unit).
    // Add filtering based on details and location if the DB schema supports it.
    final List<String> whereClauses = [
      '${DatabaseHelper.columnFactorActivityCategory} = ?',
      '${DatabaseHelper.columnFactorActivityType} = ?',
      'LOWER(${DatabaseHelper.columnFactorUnit}) = LOWER(?)', // Case-insensitive unit match
    ];
    final List<dynamic> whereArgs = [activityCategory, activityType, unit];

    // --- New: Add filtering based on details and location (requires DB schema update) ---
    // This is a simplified example. Real implementation needs careful mapping of details keys to DB columns.
    // if (details != null) {
    //   if (details.containsKey('vehicleType')) {
    //      whereClauses.add('applicableVehicleType = ?'); // Assuming 'applicableVehicleType' column exists
    //      whereArgs.add(details['vehicleType']);
    //   }
    //   // Add more detail filtering as needed
    // }
    // if (location != null) {
    //   whereClauses.add('applicableRegion = ?'); // Assuming 'applicableRegion' column exists
    //   whereArgs.add(location);
    // }
    // --- End New ---

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
      DatabaseHelper.emissionFactorTable, // Use the correct table name
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

  // Methods for adding/updating/deleting resources are not included here
  // as resources are typically static data managed outside the user UI.
}
