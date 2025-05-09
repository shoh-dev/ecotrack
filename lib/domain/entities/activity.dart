// Represents a single user activity that contributes to their eco-footprint.
// This is a core domain entity, independent of UI or data sources.
class Activity {
  final String id; // Unique identifier for the activity
  final String category; // e.g., 'Transportation', 'Diet', 'Home Energy'
  final String
  type; // e.g., 'Car Trip', 'Bus Trip', 'Meal', 'Electricity Usage'
  final DateTime timestamp; // When the activity occurred
  final double
  value; // The quantitative value of the activity (e.g., distance, kWh, number of meals)
  final String unit; // The unit for the value (e.g., 'km', 'kWh', 'count')
  final Map<String, dynamic>?
  details; // Optional additional details (e.g., vehicle type, meal type)

  Activity({
    required this.id,
    required this.category,
    required this.type,
    required this.timestamp,
    required this.value,
    required this.unit,
    this.details,
  });

  // Basic toString for debugging
  @override
  String toString() {
    return 'Activity(id: $id, category: $category, type: $type, timestamp: $timestamp, value: $value $unit, details: $details)';
  }
}
