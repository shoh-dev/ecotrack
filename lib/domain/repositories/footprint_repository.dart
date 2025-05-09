import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity

// Abstract interface defining the contract for FootprintEntry data operations.
// Implementations will be in the data layer.
abstract class FootprintRepository {
  // Saves a calculated footprint entry.
  Future<void> saveFootprintEntry(FootprintEntry entry);

  // Gets the history of footprint entries, optionally filtered by time range.
  Future<List<FootprintEntry>> getFootprintHistory({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Gets the latest footprint entry.
  Future<FootprintEntry?> getLatestFootprintEntry();

  // Potentially other methods.
}
