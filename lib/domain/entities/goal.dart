// Represents a user's eco-footprint reduction or activity goal.
// This is a core domain entity, independent of UI or data sources.
class Goal {
  final String id; // Unique identifier for the goal
  final String
  name; // Name of the goal (e.g., 'Reduce transportation footprint', 'Walk 100km this month')
  final String description; // More detailed description of the goal
  final String type; // e.g., 'FootprintReduction', 'ActivityTarget', 'Habit'
  final String
  targetUnit; // Unit for the target value (e.g., 'kg CO2e', 'km', 'count')
  final double targetValue; // The value the user aims to reach or stay below
  final DateTime startDate; // When the goal period starts
  final DateTime endDate; // When the goal period ends
  final String status; // e.g., 'Active', 'Completed', 'Failed'
  final Map<String, dynamic>?
  details; // Optional additional details (e.g., specific activity category)

  Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetUnit,
    required this.targetValue,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.details,
  });

  // Basic toString for debugging
  @override
  String toString() {
    return 'Goal(id: $id, name: $name, type: $type, targetValue: $targetValue $targetUnit, status: $status)';
  }
}
