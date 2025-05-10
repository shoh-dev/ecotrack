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
  final Map<String, dynamic>? settings; // Optional map for user settings

  UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.location,
    this.memberSince,
    this.settings,
  });

  // Basic toString for debugging
  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, email: $email, location: $location)';
  }
}
