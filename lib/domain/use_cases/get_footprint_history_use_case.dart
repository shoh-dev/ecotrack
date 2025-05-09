import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the FootprintRepository interface

// Abstract interface defining the business logic for retrieving footprint history.
abstract class GetFootprintHistoryUseCase {
  // Executes the use case: retrieves the history of footprint entries.
  Future<List<FootprintEntry>> execute({
    DateTime? startDate,
    DateTime? endDate,
  });
}

// Example implementation (we will add this later in the domain layer)
/*
class GetFootprintHistoryUseCaseImpl implements GetFootprintHistoryUseCase {
  final FootprintRepository footprintRepository;

  GetFootprintHistoryUseCaseImpl(this.footprintRepository);

  @override
  Future<List<FootprintEntry>> execute({DateTime? startDate, DateTime? endDate}) async {
    // Retrieve history using the repository
    return footprintRepository.getFootprintHistory(startDate: startDate, endDate: endDate);
  }
}
*/
