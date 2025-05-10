import 'package:ecotrack/domain/entities/resource.dart'; // Import the Resource entity
import 'package:ecotrack/domain/repositories/resource_repository.dart'; // Import the ResourceRepository interface

// Abstract interface defining the business logic for retrieving sustainable living resources.
abstract class GetResourcesUseCase {
  // Executes the use case: retrieves a list of resources from the repository,
  // optionally filtered by category.
  Future<List<Resource>> execute({String? category});
}

// Example implementation (we will add this later in the domain layer)
/*
class GetResourcesUseCaseImpl implements GetResourcesUseCase {
  final ResourceRepository resourceRepository;

  GetResourcesUseCaseImpl(this.resourceRepository);

  @override
  Future<List<Resource>> execute({String? category}) async {
    print('GetResourcesUseCase: Executing...'); // Placeholder

    // Business logic:
    // 1. Retrieve resources from the ResourceRepository based on criteria.
    final resources = category != null
        ? await resourceRepository.getResourcesByCategory(category)
        : await resourceRepository.getAllResources();

    print('GetResourcesUseCase: Retrieved ${resources.length} resources.'); // Placeholder action

    // 2. Potentially perform additional domain-specific processing on the list (e.g., sorting).

    return resources; // Return the list of resources
  }
}
*/
