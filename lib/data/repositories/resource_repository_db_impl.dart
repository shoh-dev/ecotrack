import 'dart:async'; // Import async for StreamController
import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'package:ecotrack/domain/entities/resource.dart'; // Import the Resource entity
import 'package:ecotrack/domain/repositories/resource_repository.dart'; // Import the abstract repository interface
import 'package:ecotrack/data/database_helper.dart'; // Import the DatabaseHelper
import 'package:uuid/uuid.dart'; // Assuming uuid is already added

// Database-backed implementation of the ResourceRepository interface using sqflite.
// Resources are typically pre-populated or loaded from a static source into the database.
class ResourceRepositoryDbImpl implements ResourceRepository {
  final DatabaseHelper _databaseHelper; // Dependency on DatabaseHelper
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // StreamController for watchResources. For static data, it mainly emits the list once.
  final _resourcesController = StreamController<List<Resource>>.broadcast();

  // Constructor: Inject the DatabaseHelper dependency.
  ResourceRepositoryDbImpl(this._databaseHelper) {
    // Check if factors exist and populate if not.
    _checkAndPopulateDefaultResources();
    print(
      'ResourceRepositoryDbImpl: Constructor finished. _checkAndPopulateDefaultResources called.',
    ); // Debug log
  }

  // Helper method to check if resources exist and populate if not.
  // This is where you define your default resources.
  Future<void> _checkAndPopulateDefaultResources() async {
    print(
      'ResourceRepositoryDbImpl: _checkAndPopulateDefaultResources starting...',
    ); // New Debug log
    final db = await _databaseHelper.database;

    // A more robust check:
    final resourcesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DatabaseHelper.resourceTable}'),
    );

    print(
      'ResourceRepositoryDbImpl: Checking resource count. Found $resourcesCount.',
    ); // New Debug log

    if (resourcesCount == 0) {
      print(
        'ResourceRepositoryDbImpl: Resources table is empty. Populating with default resources...',
      ); // Debug log
      // Define default resources (same as our in-memory list)
      final List<Resource> defaultResources = [
        Resource(
          id: _uuid.v4(),
          title: '10 Simple Ways to Reduce Food Waste',
          description: 'Practical tips for minimizing food waste at home.',
          type: 'Article',
          url: 'https://example.com/food-waste-tips', // Placeholder URL
          category: 'Diet',
          imageUrl:
              'https://placehold.co/600x400/green/white?text=Food+Waste', // Placeholder image
          publicationDate: DateTime(2023, 10, 26),
        ),
        Resource(
          id: _uuid.v4(),
          title: 'Beginner\'s Guide to Composting',
          description:
              'Learn how to start composting kitchen scraps and yard waste.',
          type: 'Article',
          url: 'https://example.com/composting-guide', // Placeholder URL
          category: 'Waste',
          imageUrl:
              'https://placehold.co/600x400/brown/white?text=Composting', // Placeholder image
          publicationDate: DateTime(2024, 01, 15),
        ),
        Resource(
          id: const Uuid().v4(),
          title: 'Choosing Eco-Friendly Transportation',
          description:
              'Compare the environmental impact of different ways to get around.',
          type: 'Article',
          url: 'https://example.com/eco-transport', // Placeholder URL
          category: 'Transportation',
          imageUrl:
              'https://placehold.co/600x400/blue/white?text=Transport', // Placeholder image
          publicationDate: DateTime(2023, 11, 01),
        ),
        Resource(
          id: const Uuid().v4(),
          title: 'Quick Tip: Save Energy with Smart Plugs',
          description:
              'Use smart plugs to easily turn off electronics when not in use.',
          type: 'Tip',
          url: '', // No URL for a simple tip
          category: 'Home Energy',
          publicationDate: DateTime(2024, 05, 10), // Today's date example
        ),
        Resource(
          id: const Uuid().v4(),
          title: 'Understanding Your Electricity Bill',
          description:
              'Learn how to read your bill and find ways to save energy.',
          type: 'Article',
          url: 'https://example.com/electricity-bill', // Placeholder URL
          category: 'Home Energy',
          imageUrl:
              'https://placehold.co/600x400/yellow/black?text=Electricity', // Placeholder image
          publicationDate: DateTime(2024, 03, 20),
        ),
      ];

      // Insert default resources into the database
      final batch = db.batch();
      for (final resource in defaultResources) {
        batch.insert(DatabaseHelper.resourceTable, _toMap(resource));
      }
      print(
        'ResourceRepositoryDbImpl: Starting batch commit for population.',
      ); // New Debug log
      await batch.commit(noResult: true);
      print(
        'ResourceRepositoryDbImpl: Batch commit finished. Default resources populated.',
      ); // Debug log
    } else {
      print(
        'ResourceRepositoryDbImpl: Resources already exist in database ($resourcesCount resources).',
      ); // Debug log
    }
    // After checking/populating, emit the current list to the stream
    print(
      'ResourceRepositoryDbImpl: Calling _notifyListeners() after check/populate.',
    ); // New Debug log
    await _notifyListeners();
    print(
      'ResourceRepositoryDbImpl: _notifyListeners() finished after check/populate.',
    ); // New Debug log
    print(
      'ResourceRepositoryDbImpl: _checkAndPopulateDefaultResources finished.',
    ); // New Debug log
  }

  // Helper method to convert Resource entity to a database Map.
  Map<String, dynamic> _toMap(Resource resource) {
    return {
      DatabaseHelper.columnResourceId:
          resource.id.isEmpty
              ? _uuid.v4()
              : resource.id, // Use ResourceId constant
      DatabaseHelper.columnResourceTitle:
          resource.title, // Use ResourceTitle constant
      DatabaseHelper.columnResourceDescription:
          resource.description, // Use ResourceDescription constant
      DatabaseHelper.columnResourceType:
          resource.type, // Use ResourceType constant
      DatabaseHelper.columnResourceUrl:
          resource.url, // Use ResourceUrl constant
      DatabaseHelper.columnResourceCategory:
          resource.category, // Use ResourceCategory constant
      DatabaseHelper.columnResourceImageUrl:
          resource.imageUrl, // Use ResourceImageUrl constant
      DatabaseHelper.columnResourcePublicationDate:
          resource
              .publicationDate
              ?.millisecondsSinceEpoch, // Use ResourcePublicationDate constant (INTEGER)
    };
  }

  // Helper method to convert a database Map to a Resource entity.
  Resource _fromMap(Map<String, dynamic> map) {
    return Resource(
      id:
          map[DatabaseHelper.columnResourceId]
              as String, // Use ResourceId constant
      title:
          map[DatabaseHelper.columnResourceTitle]
              as String, // Use ResourceTitle constant
      description:
          map[DatabaseHelper.columnResourceDescription] as String? ??
          '', // Use ResourceDescription constant
      type:
          map[DatabaseHelper.columnResourceType]
              as String, // Use ResourceType constant
      url:
          map[DatabaseHelper.columnResourceUrl] as String? ??
          '', // Use ResourceUrl constant
      category:
          map[DatabaseHelper.columnResourceCategory]
              as String?, // Use ResourceCategory constant
      imageUrl:
          map[DatabaseHelper.columnResourceImageUrl]
              as String?, // Use ResourceImageUrl constant
      publicationDate:
          map[DatabaseHelper.columnResourcePublicationDate] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                map[DatabaseHelper.columnResourcePublicationDate] as int,
              )
              : null, // Use ResourcePublicationDate constant
    );
  }

  // Helper method to notify stream listeners after a database change.
  // For static resources, this is mainly called on initial load or population.
  Future<void> _notifyListeners() async {
    print(
      'ResourceRepositoryDbImpl: Fetching latest resources to notify listeners...',
    ); // New Debug log
    // Fetch the latest data from the database and add it to the stream.
    final latestResources =
        await getAllResources(); // Reuse getAllResources to fetch from DB
    print(
      'ResourceRepositoryDbImpl: Adding ${latestResources.length} resources to stream sink.',
    ); // New Debug log
    _resourcesController.sink.add(latestResources);
    print(
      'ResourceRepositoryDbImpl: Finished adding resources to stream sink.',
    ); // New Debug log
  }

  @override
  void dispose() {
    // Close the stream controller when the repository is no longer needed.
    _resourcesController.close();
    print(
      'ResourceRepositoryDbImpl: StreamController disposed.',
    ); // For demonstration
  }

  @override
  Future<List<Resource>> getAllResources() async {
    final db = await _databaseHelper.database;

    print(
      'ResourceRepositoryDbImpl: Getting all resources from database.',
    ); // New Debug log

    // Query the database
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.resourceTable, // Use the correct table name
      // orderBy: '${DatabaseHelper.columnResourcePublicationDate} DESC', // Optional ordering by publication date
    );

    print(
      'ResourceRepositoryDbImpl: Retrieved ${maps.length} resource maps.',
    ); // New Debug log

    // Convert the list of Maps to a list of Resource entities
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Future<List<Resource>> getResourcesByCategory(String category) async {
    final db = await _databaseHelper.database;

    print(
      'ResourceRepositoryDbImpl: Getting resources by category from database: $category',
    ); // New Debug log

    // Build the WHERE clause for filtering by category (case-insensitive).
    final whereString =
        'LOWER(${DatabaseHelper.columnResourceCategory}) = LOWER(?)'; // Use constant
    final whereArgs = [category];

    // Query the database
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.resourceTable, // Use the correct table name
      where: whereString,
      whereArgs: whereArgs,
      // orderBy: '${DatabaseHelper.columnResourcePublicationDate} DESC', // Optional ordering
    );

    print(
      'ResourceRepositoryDbImpl: Retrieved ${maps.length} resource maps for category "$category".',
    ); // New Debug log

    // Convert the list of Maps to a list of Resource entities
    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  @override
  Stream<List<Resource>> watchResources() {
    print(
      'ResourceRepositoryDbImpl: Someone is watching resources stream.',
    ); // Debug log
    // The initial data is added in _checkAndPopulateDefaultResources.
    // If resources were dynamic, you'd add logic here to emit changes.
    return _resourcesController.stream;
  }

  // Methods for adding/updating/deleting resources are not included here
  // as resources are typically static data managed outside the user UI.
}
