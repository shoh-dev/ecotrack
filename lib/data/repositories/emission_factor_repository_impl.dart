import 'package:ecotrack/domain/entities/emission_factor.dart'; // Import the EmissionFactor entity
import 'package:ecotrack/domain/repositories/emission_factor_repository.dart'; // Import the abstract repository interface
import 'package:uuid/uuid.dart'; // Assuming uuid is already added for other repositories

// In-memory implementation of the EmissionFactorRepository interface.
// Provides sample emission factors from a static list.
class EmissionFactorRepositoryImpl implements EmissionFactorRepository {
  // Static list of sample emission factors.
  // In a real app, this data would likely come from an API, database, or config file.
  static final List<EmissionFactor> _emissionFactors = [
    // Transportation Factors (example values, may vary by vehicle type, fuel, etc.)
    EmissionFactor(
      id: const Uuid().v4(),
      activityCategory: 'Transportation',
      activityType: 'Car Trip',
      unit: 'km',
      co2ePerUnit: 0.21, // Example: kg CO2e per km for an average car
      source: 'Example Data Source A',
    ),
    EmissionFactor(
      id: const Uuid().v4(),
      activityCategory: 'Transportation',
      activityType: 'Car Trip',
      unit: 'mile',
      co2ePerUnit: 0.34, // Example: kg CO2e per mile (0.21 * 1.60934)
      source: 'Example Data Source A',
    ),
    EmissionFactor(
      id: const Uuid().v4(),
      activityCategory: 'Transportation',
      activityType: 'Bus Trip',
      unit: 'km',
      co2ePerUnit: 0.10, // Example: kg CO2e per km per passenger (average)
      source: 'Example Data Source B',
    ),
    EmissionFactor(
      id: const Uuid().v4(),
      activityCategory: 'Transportation',
      activityType: 'Train Trip',
      unit: 'km',
      co2ePerUnit: 0.04, // Example: kg CO2e per km per passenger (average)
      source: 'Example Data Source B',
    ),
    // Home Energy Factors (example values, may vary by region, energy source)
    EmissionFactor(
      id: const Uuid().v4(),
      activityCategory: 'Home Energy',
      activityType: 'Electricity Usage',
      unit: 'kWh',
      co2ePerUnit: 0.233, // Example: kg CO2e per kWh (US average)
      source: 'Example Data Source C',
    ),
    EmissionFactor(
      id: const Uuid().v4(),
      activityCategory: 'Home Energy',
      activityType: 'Gas Usage',
      unit: 'kWh', // Or other units like therms, m³
      co2ePerUnit: 0.18, // Example: kg CO2e per kWh of natural gas
      source: 'Example Data Source C',
    ),
    // Add more factors for other categories (Diet, Waste, Consumption) later
  ];

  // Note: In-memory repository doesn't manage streams or complex resources,
  // so dispose is empty but included for interface consistency.
  @override
  void dispose() {
    print(
      'EmissionFactorRepositoryImpl: Dispose called (in-memory, no resources to close).',
    ); // For demonstration
  }

  @override
  Future<List<EmissionFactor>> getAllFactors() async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 50));
    print(
      'EmissionFactorRepositoryImpl: Getting all factors.',
    ); // For demonstration
    return _emissionFactors.toList(); // Return a copy
  }

  @override
  Future<EmissionFactor?> getFactorForActivity({
    required String activityCategory,
    required String activityType,
    required String unit,
    DateTime?
    timestamp, // Timestamp is not used in this basic implementation but kept for interface
  }) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 50));

    print(
      'EmissionFactorRepositoryImpl: Looking up factor for Category: $activityCategory, Type: $activityType, Unit: $unit',
    ); // For demonstration

    // Find the first factor that matches the category, type, and unit (case-insensitive for unit).
    try {
      final factor = _emissionFactors.firstWhere(
        (f) =>
            f.activityCategory == activityCategory &&
            f.activityType == activityType &&
            f.unit.toLowerCase() ==
                unit.toLowerCase(), // Case-insensitive unit match
      );
      print(
        'EmissionFactorRepositoryImpl: Found factor: ${factor.co2ePerUnit} for ${factor.unit}',
      ); // For demonstration
      return factor;
    } catch (e) {
      // Return null if no matching factor is found
      print(
        'EmissionFactorRepositoryImpl: No matching factor found.',
      ); // For demonstration
      return null;
    }
  }
}
