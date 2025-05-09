// Represents a calculated eco-footprint value at a specific point in time.
// This is a core domain entity.
class FootprintEntry {
  final String id; // Unique identifier for the entry
  final DateTime timestamp; // When the footprint was calculated or recorded
  final double totalCo2e; // The total estimated CO2 equivalent footprint
  final Map<String, double>?
  categoryBreakdown; // Optional breakdown by category (e.g., {'Transportation': 150.5, 'Diet': 80.2})

  FootprintEntry({
    required this.id,
    required this.timestamp,
    required this.totalCo2e,
    this.categoryBreakdown,
  });

  // Basic toString for debugging
  @override
  String toString() {
    return 'FootprintEntry(id: $id, timestamp: $timestamp, totalCo2e: $totalCo2e, categoryBreakdown: $categoryBreakdown)';
  }
}
