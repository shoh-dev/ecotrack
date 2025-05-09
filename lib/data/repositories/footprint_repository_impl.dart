import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the abstract repository interface
import 'package:uuid/uuid.dart'; // We'll use this for generating unique IDs

// In-memory implementation of the FootprintRepository interface.
// Data is stored in a simple list in memory.
class FootprintRepositoryImpl implements FootprintRepository {
  // Use a static list to simulate data persistence across different instances
  // (though data is still lost on app restart).
  static final List<FootprintEntry> _footprintEntries = [];
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  @override
  Future<void> saveFootprintEntry(FootprintEntry entry) async {
    print('FootprintRepositoryImpl: Saving footprint entry...'); // New log
    // Generate a unique ID if the entry doesn't have one (useful for new entries)
    final entryToSave =
        entry.id.isEmpty
            ? FootprintEntry(
              id: _uuid.v4(), // Generate a new UUID
              timestamp: entry.timestamp,
              totalCo2e: entry.totalCo2e,
              categoryBreakdown: entry.categoryBreakdown,
            )
            : entry;

    // In a real implementation, you'd save to a database or send to an API.
    // Here, we just add to the list.
    _footprintEntries.add(entryToSave);
    print(
      'FootprintRepositoryImpl: Saved entry with ID: ${entryToSave.id}, Total CO2e: ${entryToSave.totalCo2e}',
    ); // Updated log
  }

  @override
  Future<List<FootprintEntry>> getFootprintHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 100));

    print('FootprintRepositoryImpl: Getting footprint history...'); // New log

    // Filter entries based on optional criteria
    Iterable<FootprintEntry> filteredEntries =
        _footprintEntries.reversed; // Show newest first

    if (startDate != null) {
      filteredEntries = filteredEntries.where(
        (entry) =>
            entry.timestamp.isAfter(startDate) ||
            entry.timestamp.isAtSameMomentAs(startDate),
      );
    }
    if (endDate != null) {
      filteredEntries = filteredEntries.where(
        (entry) =>
            entry.timestamp.isBefore(endDate) ||
            entry.timestamp.isAtSameMomentAs(endDate),
      );
    }

    final result = filteredEntries.toList();
    print(
      'FootprintRepositoryImpl: Retrieved ${result.length} history entries.',
    ); // New log
    return result;
  }

  @override
  Future<FootprintEntry?> getLatestFootprintEntry() async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 50));

    print(
      'FootprintRepositoryImpl: Getting latest footprint entry...',
    ); // New log

    // Return the most recent entry, or null if the list is empty.
    final latest = _footprintEntries.isNotEmpty ? _footprintEntries.last : null;
    print(
      'FootprintRepositoryImpl: Latest entry: ${latest != null ? latest.totalCo2e : 'null'}',
    ); // New log
    return latest;
  }
}
