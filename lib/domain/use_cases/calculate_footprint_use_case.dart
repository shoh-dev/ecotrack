import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity

// Abstract interface defining the business logic for calculating the user's eco-footprint.
abstract class CalculateFootprintUseCase {
  // Executes the use case: calculates the footprint based on available data
  // and returns the calculated FootprintEntry.
  Future<FootprintEntry> execute();
}
