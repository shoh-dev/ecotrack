import 'package:ecotrack/domain/entities/emission_factor.dart'; // Import the EmissionFactor entity

// Abstract interface defining the contract for Emission Factor data operations.
// Implementations will be in the data layer (e.g., StaticEmissionFactorRepository, ApiEmissionFactorRepository).
abstract class EmissionFactorRepository {
  // Gets a specific emission factor based on activity details and user context.
  // Added optional details and location parameters for more specific lookup.
  Future<EmissionFactor?> getFactorForActivity({
    required String activityCategory,
    required String activityType,
    required String unit,
    DateTime? timestamp, // Optional: for time-sensitive factors
    Map<String, dynamic>?
    details, // New: Additional activity details (e.g., vehicle type)
    String? location, // New: User's location/region
  });

  // Gets a list of all emission factors (potentially useful for management UI later).
  Future<List<EmissionFactor>> getAllFactors();

  // Potentially methods for adding/updating factors (for admin/data loading).
  // Future<void> saveFactor(EmissionFactor factor);

  // Remember to add a dispose method to close streams/resources in implementations.
  void dispose();
}
