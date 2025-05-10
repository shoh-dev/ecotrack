import 'package:ecotrack/domain/entities/resource.dart'; // Import the Resource entity
import 'package:ecotrack/domain/repositories/resource_repository.dart'; // Import the ResourceRepository interface
import 'package:ecotrack/domain/use_cases/get_resources_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the GetResourcesUseCase.
// This class contains the business logic for retrieving sustainable living resources.
class GetResourcesUseCaseImpl implements GetResourcesUseCase {
  final ResourceRepository
  _resourceRepository; // Dependency on ResourceRepository

  // Constructor: Inject the ResourceRepository dependency.
  GetResourcesUseCaseImpl(this._resourceRepository);

  @override
  Future<List<Resource>> execute({String? category}) async {
    print('GetResourcesUseCase: Executing...'); // Debug log

    // Business logic:
    // 1. Retrieve resources from the ResourceRepository based on criteria.
    final resources =
        category != null && category.isNotEmpty
            ? await _resourceRepository.getResourcesByCategory(category)
            : await _resourceRepository.getAllResources();

    print(
      'GetResourcesUseCase: Retrieved ${resources.length} resources.',
    ); // Debug log

    // 2. Potentially perform additional domain-specific processing on the list (e.g., sorting by date).
    // For now, we'll sort by publication date descending if available.
    resources.sort((a, b) {
      if (a.publicationDate == null && b.publicationDate == null) return 0;
      if (a.publicationDate == null) return 1; // Null dates go to the end
      if (b.publicationDate == null) return -1; // Null dates go to the end
      return b.publicationDate!.compareTo(
        a.publicationDate!,
      ); // Sort descending
    });

    return resources; // Return the list of resources
  }
}
