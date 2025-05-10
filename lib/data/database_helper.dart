import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'package:path/path.dart'; // Import path for joining paths
import 'package:path_provider/path_provider.dart'; // Import path_provider to get document directory
import 'dart:io'; // Import dart:io for Directory

// DatabaseHelper is a singleton class to manage the SQLite database connection and operations.
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Database instance
  static Database? _database;

  // Database details
  static const int _databaseVersion = 1;
  static const String _databaseName = 'ecotrack.db';

  // Table names
  static const String activityTable = 'activities';
  static const String footprintTable = 'footprint_entries';
  static const String goalTable = 'goals';
  static const String emissionFactorTable = 'emission_factors';
  static const String resourceTable = 'resources';
  static const String userProfileTable =
      'user_profile'; // User Profile table name

  // Column names (examples - will need to match entity properties)
  // Activity Table Columns
  static const String columnActivityId = 'id';
  static const String columnActivityCategory = 'category';
  static const String columnActivityType = 'type';
  static const String columnActivityTimestamp =
      'timestamp'; // Stored as INTEGER (Unix timestamp)
  static const String columnActivityValue = 'value';
  static const String columnActivityUnit = 'unit';
  static const String columnActivityDetails =
      'details'; // Stored as TEXT (JSON string)

  // Footprint Entry Table Columns
  static const String columnFootprintId = 'id';
  static const String columnFootprintTimestamp =
      'timestamp'; // Stored as INTEGER (Unix timestamp)
  static const String columnFootprintTotalCo2e = 'totalCo2e';
  static const String columnFootprintCategoryBreakdown =
      'categoryBreakdown'; // Stored as TEXT (JSON string)

  // Goal Table Columns
  static const String columnGoalId = 'id';
  static const String columnGoalName = 'name';
  static const String columnGoalDescription = 'description';
  static const String columnGoalType = 'type';
  static const String columnGoalTargetUnit = 'targetUnit';
  static const String columnGoalTargetValue = 'targetValue';
  static const String columnGoalStartDate =
      'startDate'; // Stored as INTEGER (Unix timestamp)
  static const String columnGoalEndDate =
      'endDate'; // Stored as INTEGER (Unix timestamp)
  static const String columnGoalStatus = 'status';
  static const String columnGoalDetails =
      'details'; // Stored as TEXT (JSON string)

  // Emission Factor Table Columns
  static const String columnFactorId = 'id';
  static const String columnFactorActivityCategory = 'activityCategory';
  static const String columnFactorActivityType = 'activityType';
  static const String columnFactorUnit = 'unit';
  static const String columnFactorCo2ePerUnit = 'co2ePerUnit';
  static const String columnFactorSource = 'source';
  static const String columnFactorEffectiveDate =
      'effectiveDate'; // Stored as INTEGER (Unix timestamp)

  // Resource Table Columns
  static const String columnResourceId = 'id';
  static const String columnResourceTitle = 'title';
  static const String columnResourceDescription = 'description';
  static const String columnResourceType = 'type';
  static const String columnResourceUrl = 'url';
  static const String columnResourceCategory = 'category';
  static const String columnResourceImageUrl = 'imageUrl';
  static const String columnResourcePublicationDate =
      'publicationDate'; // Stored as INTEGER (Unix timestamp)

  // User Profile Table Columns (New)
  static const String columnProfileId = 'id';
  static const String columnProfileName = 'name';
  static const String columnProfileEmail = 'email';
  static const String columnProfileLocation = 'location';
  static const String columnProfileMemberSince =
      'memberSince'; // Stored as INTEGER (Unix timestamp)
  static const String columnProfileSettings =
      'settings'; // Stored as TEXT (JSON string)

  // Get the database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    // If database is null, initialize it
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the application's documents directory
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    print('DatabaseHelper: Initializing database at path: $path'); // Debug log

    // Open the database, creating it if it doesn't exist
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create the database tables
  Future<void> _onCreate(Database db, int version) async {
    print('DatabaseHelper: Creating tables (version $version)...'); // Debug log

    // Create Activity Table
    await db.execute('''
      CREATE TABLE $activityTable (
        $columnActivityId TEXT PRIMARY KEY,
        $columnActivityCategory TEXT NOT NULL,
        $columnActivityType TEXT NOT NULL,
        $columnActivityTimestamp INTEGER NOT NULL,
        $columnActivityValue REAL NOT NULL,
        $columnActivityUnit TEXT NOT NULL,
        $columnActivityDetails TEXT
      )
    ''');

    // Create Footprint Entry Table
    await db.execute('''
      CREATE TABLE $footprintTable (
        $columnFootprintId TEXT PRIMARY KEY,
        $columnFootprintTimestamp INTEGER NOT NULL,
        $columnFootprintTotalCo2e REAL NOT NULL,
        $columnFootprintCategoryBreakdown TEXT
      )
    ''');

    // Create Goal Table
    await db.execute('''
      CREATE TABLE $goalTable (
        $columnGoalId TEXT PRIMARY KEY,
        $columnGoalName TEXT NOT NULL,
        $columnGoalDescription TEXT,
        $columnGoalType TEXT NOT NULL,
        $columnGoalTargetUnit TEXT NOT NULL,
        $columnGoalTargetValue REAL NOT NULL,
        $columnGoalStartDate INTEGER NOT NULL,
        $columnGoalEndDate INTEGER NOT NULL,
        $columnGoalStatus TEXT NOT NULL,
        $columnGoalDetails TEXT
      )
    ''');

    // Create Emission Factor Table
    await db.execute('''
      CREATE TABLE $emissionFactorTable (
        $columnFactorId TEXT PRIMARY KEY,
        $columnFactorActivityCategory TEXT NOT NULL,
        $columnFactorActivityType TEXT NOT NULL,
        $columnFactorUnit TEXT NOT NULL,
        $columnFactorCo2ePerUnit REAL NOT NULL,
        $columnFactorSource TEXT,
        $columnFactorEffectiveDate INTEGER
      )
    ''');

    // Create Resource Table
    await db.execute('''
      CREATE TABLE $resourceTable (
        $columnResourceId TEXT PRIMARY KEY,
        $columnResourceTitle TEXT NOT NULL,
        $columnResourceDescription TEXT,
        $columnResourceType TEXT NOT NULL,
        $columnResourceUrl TEXT,
        $columnResourceCategory TEXT,
        $columnResourceImageUrl TEXT,
        $columnResourcePublicationDate INTEGER
      )
    ''');

    // Create User Profile Table (New)
    print(
      'DatabaseHelper: Executing CREATE TABLE for $userProfileTable...',
    ); // New Debug log
    await db.execute('''
      CREATE TABLE $userProfileTable (
        $columnProfileId TEXT PRIMARY KEY,
        $columnProfileName TEXT NOT NULL,
        $columnProfileEmail TEXT,
        $columnProfileLocation TEXT,
        $columnProfileMemberSince INTEGER,
        $columnProfileSettings TEXT
      )
    ''');
    print(
      'DatabaseHelper: CREATE TABLE for $userProfileTable finished.',
    ); // New Debug log

    print('DatabaseHelper: Tables created.'); // Debug log

    // TODO: Consider pre-populating the emission_factors table here on first creation
    // For now, the EmissionFactorRepositoryDbImpl constructor handles initial population.
    // TODO: Consider pre-populating the resources table here on first creation
    // For now, the ResourceRepositoryDbImpl constructor handles initial population.
  }

  // Handle database upgrades (add tables, columns, etc. in future versions)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(
      'DatabaseHelper: Upgrading database from version $oldVersion to $newVersion...',
    ); // Debug log
    // Migration logic would go here for future database versions.
    // Example: if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
    // If upgrading from version 1 to 2, and adding the resources table:
    // if (oldVersion < 2) {
    //   print('DatabaseHelper: Adding $resourceTable table in upgrade...'); // Debug log
    //   await db.execute('''
    //     CREATE TABLE $resourceTable (
    //       $columnResourceId TEXT PRIMARY KEY,
    //       $columnResourceTitle TEXT NOT NULL,
    //       $columnResourceDescription TEXT,
    //       $columnResourceType TEXT NOT NULL,
    //       $columnResourceUrl TEXT,
    //       $columnResourceCategory TEXT,
    //       $columnResourceImageUrl TEXT,
    //       $columnResourcePublicationDate INTEGER
    //     )
    //   ''');
    //    print('DatabaseHelper: $resourceTable table added in upgrade.'); // Debug log
    // }
    // If upgrading from version 1 to 2, and adding the user_profile table:
    // if (oldVersion < 2) {
    //   print('DatabaseHelper: Adding $userProfileTable table in upgrade...'); // Debug log
    //    await db.execute('''
    //     CREATE TABLE $userProfileTable (
    //       $columnProfileId TEXT PRIMARY KEY,
    //       $columnProfileName TEXT NOT NULL,
    //       $columnProfileEmail TEXT,
    //       $columnProfileLocation TEXT,
    //       $columnProfileMemberSince INTEGER,
    //       $columnProfileSettings TEXT
    //     )
    //   ''');
    //   print('DatabaseHelper: $userProfileTable table added in upgrade.'); // Debug log
    // }
  }

  // Close the database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('DatabaseHelper: Database connection closed.'); // Debug log
    }
  }
}
