// Represents a factor used to calculate CO2e emissions for a specific activity type and unit.
// This is a core domain entity.
class EmissionFactor {
  final String id; // Unique identifier for the emission factor
  final String activityCategory; // e.g., 'Transportation', 'Home Energy'
  final String activityType; // e.g., 'Car Trip', 'Electricity Usage'
  final String unit; // The unit the factor applies to (e.g., 'km', 'kWh')
  final double
  co2ePerUnit; // The amount of CO2e emitted per unit (e.g., 0.15 kg CO2e/km)
  final String? source; // Optional source of the data (e.g., 'EPA', 'IEA')
  final DateTime?
  effectiveDate; // Optional date from which this factor is effective

  EmissionFactor({
    required this.id,
    required this.activityCategory,
    required this.activityType,
    required this.unit,
    required this.co2ePerUnit,
    this.source,
    this.effectiveDate,
  });

  // Basic toString for debugging
  @override
  String toString() {
    return 'EmissionFactor(id: $id, category: $activityCategory, type: $activityType, factor: $co2ePerUnit $unit/CO2e)';
  }
}
