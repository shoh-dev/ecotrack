// Represents a user's profile information.
// This is a core domain entity.
class UserProfile {
  final String id; // Unique identifier for the user profile (could be user ID)
  final String name; // User's name
  final String? email; // User's email (optional)
  final String?
  location; // User's general location/region (optional, for regional factors)
  final DateTime? memberSince; // Date the user joined (optional)
  // Add other profile-related fields as needed (e.g., preferred units, baseline year)
  final String?
  preferredUnits; // New: User's preferred unit system (e.g., 'metric', 'imperial')
  final int?
  baselineYear; // New: Year to use as a baseline for footprint comparisons
  final Map<String, dynamic>? settings; // Optional map for user settings

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.location,
    this.memberSince,
    this.preferredUnits, // Include in constructor
    this.baselineYear, // Include in constructor
    this.settings,
  });

  // Basic toString for debugging
  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, location: $location, preferredUnits: $preferredUnits, baselineYear: $baselineYear)';
  }
}
