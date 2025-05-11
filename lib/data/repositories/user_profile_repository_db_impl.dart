import 'dart:convert'; // Import convert for JSON encoding/decoding
import 'package:sqflite/sqflite.dart'; // Import sqflite
import 'package:ecotrack/domain/entities/user_profile.dart'; // Import the UserProfile entity
import 'package:ecotrack/domain/repositories/user_profile_repository.dart'; // Import the abstract repository interface
import 'package:ecotrack/data/database_helper.dart'; // Import the DatabaseHelper
import 'package:uuid/uuid.dart'; // Assuming uuid is already added

// Database-backed implementation of the UserProfileRepository interface using sqflite.
class UserProfileRepositoryDbImpl implements UserProfileRepository {
  final DatabaseHelper _databaseHelper; // Dependency on DatabaseHelper
  final Uuid _uuid = const Uuid(); // Helper to generate unique IDs

  // Constructor: Inject the DatabaseHelper dependency.
  UserProfileRepositoryDbImpl(this._databaseHelper);

  // Helper method to convert UserProfile entity to a database Map.
  Map<String, dynamic> _toMap(UserProfile profile) {
    return {
      // Assuming UserProfile has a consistent ID (e.g., 'current_user_profile') or is handled uniquely.
      // For simplicity, let's use a fixed ID or the provided ID.
      DatabaseHelper.columnProfileId:
          profile.id.isEmpty
              ? 'current_user_profile'
              : profile.id, // Use ProfileId constant
      DatabaseHelper.columnProfileName:
          profile.name, // Use ProfileName constant
      DatabaseHelper.columnProfileEmail:
          profile.email, // Use ProfileEmail constant
      DatabaseHelper.columnProfileLocation:
          profile.location, // Use ProfileLocation constant
      DatabaseHelper.columnProfileMemberSince:
          profile
              .memberSince
              ?.millisecondsSinceEpoch, // Use ProfileMemberSince constant (INTEGER)
      DatabaseHelper.columnProfileSettings:
          profile.settings != null
              ? jsonEncode(profile.settings)
              : null, // Use ProfileSettings constant (TEXT)
      // --- New Fields ---
      DatabaseHelper.columnProfilePreferredUnits:
          profile.preferredUnits, // Include preferredUnits
      DatabaseHelper.columnProfileBaselineYear:
          profile.baselineYear, // Include baselineYear
      // --- End New Fields ---
    };
  }

  // Helper method to convert a database Map to a UserProfile entity.
  UserProfile _fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id:
          map[DatabaseHelper.columnProfileId]
              as String, // Use ProfileId constant
      name:
          map[DatabaseHelper.columnProfileName]
              as String, // Use ProfileName constant
      email:
          map[DatabaseHelper.columnProfileEmail]
              as String?, // Use ProfileEmail constant
      location:
          map[DatabaseHelper.columnProfileLocation]
              as String?, // Use ProfileLocation constant
      memberSince:
          map[DatabaseHelper.columnProfileMemberSince] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                map[DatabaseHelper.columnProfileMemberSince] as int,
              )
              : null, // Use ProfileMemberSince constant
      settings:
          map[DatabaseHelper.columnProfileSettings] != null
              ? jsonDecode(map[DatabaseHelper.columnProfileSettings] as String)
                  as Map<String, dynamic>
              : null, // Use ProfileSettings constant
      // --- New Fields ---
      preferredUnits:
          map[DatabaseHelper.columnProfilePreferredUnits]
              as String?, // Read preferredUnits
      baselineYear:
          map[DatabaseHelper.columnProfileBaselineYear]
              as int?, // Read baselineYear
      // --- End New Fields ---
    );
  }

  @override
  void dispose() {
    print(
      'UserProfileRepositoryDbImpl: Dispose called (no streams to close).',
    ); // For demonstration
    // No StreamController in this repository currently.
  }

  @override
  Future<UserProfile?> getUserProfile() async {
    final db = await _databaseHelper.database;

    print(
      'UserProfileRepositoryDbImpl: Getting user profile from database.',
    ); // Debug log

    // Query the database for the user profile (assuming at most one).
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseHelper.userProfileTable, // Use the table name constant
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final profile = _fromMap(maps.first);
      print(
        'UserProfileRepositoryDbImpl: Found user profile: ${profile.name}',
      ); // Debug log
      return profile;
    } else {
      print('UserProfileRepositoryDbImpl: No user profile found.'); // Debug log
      return null;
    }
  }

  @override
  Future<UserProfile> saveUserProfile(UserProfile profile) async {
    final db = await _databaseHelper.database;
    final profileMap = _toMap(profile);
    final profileId =
        profileMap[DatabaseHelper.columnProfileId]
            as String; // Get the ID (fixed or provided)

    // Attempt to update if a profile with this ID exists, otherwise insert.
    final rowsAffected = await db.update(
      DatabaseHelper.userProfileTable, // Use the table name constant
      profileMap,
      where: '${DatabaseHelper.columnProfileId} = ?', // Use ProfileId constant
      whereArgs: [profileId],
    );

    if (rowsAffected > 0) {
      print(
        'UserProfileRepositoryDbImpl: Updated user profile with ID: $profileId',
      );
    } else {
      // Insert if no profile with this ID was found.
      await db.insert(
        DatabaseHelper.userProfileTable, // Use the table name constant
        profileMap,
        conflictAlgorithm:
            ConflictAlgorithm
                .replace, // Replace if ID already exists (shouldn't happen with fixed ID)
      );
      print(
        'UserProfileRepositoryDbImpl: Inserted new user profile with ID: $profileId',
      );
    }

    // Fetch the saved profile to return the latest state from the database.
    final savedProfile = await getUserProfile();
    // We expect savedProfile to be non-null after saving.
    return savedProfile!; // Return the saved profile
  }

  // watchUserProfile method could be added here if needed for reactivity.
  // @override
  // Stream<UserProfile?> watchUserProfile() {
  //   // Implementation would involve a StreamController.
  // }
}
