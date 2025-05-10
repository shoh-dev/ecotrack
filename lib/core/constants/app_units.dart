// Defines standard units used throughout the application, particularly for activities, goals, and results.
class AppUnits {
  // Emission Units
  static const String kgCo2e = 'kg CO2e'; // Kilograms of CO2 Equivalent

  // Transportation Units
  static const String kilometer = 'km';
  static const String mile = 'mile';

  // Home Energy Units
  static const String kilowattHour = 'kWh';
  static const String cubicMeter = 'm³'; // For natural gas

  // Diet Units (less common for quantitative tracking, maybe 'count' for meals?)
  static const String count = 'count';

  // Waste Units (less common for quantitative tracking, maybe 'count' or 'kg')
  static const String kilogram = 'kg';

  // Consumption Units (depends heavily on what's being tracked, maybe 'count', 'kg', 'liter')
  static const String liter = 'liter';

  // Map to get relevant units based on activity category/type (simplified example)
  // This map is primarily for INPUT units for activities.
  static const Map<String, List<String>> unitsByCategory = {
    'Transportation': [kilometer, mile],
    'Home Energy': [kilowattHour, cubicMeter],
    'Diet': [count],
    'Waste': [kilogram, count],
    'Consumption': [count, kilogram, liter],
  };

  // Add more units and mappings as needed.
}
