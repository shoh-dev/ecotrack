import 'package:ecotrack/domain/entities/resource.dart'; // Import the Resource entity

// Abstract interface defining the contract for Resource data operations.
// Implementations will be in the data layer (e.g., StaticResourceRepository, ApiResourceRepository).
abstract class ResourceRepository {
  // Gets a list of all resources.
  Future<List<Resource>> getAllResources();

  // Gets a list of resources filtered by category.
  Future<List<Resource>> getResourcesByCategory(String category);

  // Potentially methods for getting a single resource by ID if needed.
  // Future<Resource?> getResourceById(String resourceId);

  // --- Reactive Method ---
  // Returns a stream that emits the current list of resources whenever it changes.
  // For static data, this might just emit the list once on subscription.
  Stream<List<Resource>> watchResources();
  // --- End Reactive Method ---

  // Remember to add a dispose method to close streams/resources in implementations.
  void dispose();
}
