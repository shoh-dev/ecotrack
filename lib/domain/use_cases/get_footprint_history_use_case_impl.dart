import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import the FootprintEntry entity
import 'package:ecotrack/domain/repositories/footprint_repository.dart'; // Import the FootprintRepository interface
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart'; // Import the abstract use case interface

// Concrete implementation of the GetFootprintHistoryUseCase.
// This class contains the business logic for retrieving footprint history.
class GetFootprintHistoryUseCaseImpl implements GetFootprintHistoryUseCase {
  final FootprintRepository footprintRepository;

  GetFootprintHistoryUseCaseImpl(this.footprintRepository);

  @override
  Future<List<FootprintEntry>> execute({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Business logic:
    // 1. Retrieve footprint entries from the FootprintRepository.
    final history = await footprintRepository.getFootprintHistory(
      startDate: startDate,
      endDate: endDate,
    );

    // 2. Potentially perform additional domain-specific processing on the history
    // (e.g., aggregate data, filter based on complex rules - omitted for brevity).

    print(
      'GetFootprintHistoryUseCase executed: Retrieved ${history.length} entries.',
    ); // For demonstration

    return history;
  }
}
