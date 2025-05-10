import 'dart:async'; // Import async for StreamSubscription
import 'package:flutter/foundation.dart'; // Required for ChangeNotifier
import 'package:ecotrack/domain/entities/resource.dart'; // Import the Resource entity
import 'package:ecotrack/domain/repositories/resource_repository.dart'; // Import ResourceRepository interface (for stream)
// We no longer need GetResourcesUseCase here as we get resources directly from the stream.
// import 'package:ecotrack/domain/use_cases/get_resources_use_case.dart';

// ResourcesViewModel manages the state and logic for the ResourcesScreen.
// It now reacts to changes in the ResourceRepository stream.
class ResourcesViewModel extends ChangeNotifier {
  // Dependencies:
  // We no longer need GetResourcesUseCase as we subscribe to the repository stream directly.
  // final GetResourcesUseCase _getResourcesUseCase;
  final ResourceRepository
  _resourceRepository; // New dependency to subscribe to its stream

  // State properties for the Resources View:
  List<Resource> _resources = []; // Holds the list of resources
  // _isLoading starts as false by default. The UI will handle the initial empty state display.
  bool _isLoading = false;
  String? _errorMessage; // Holds an error message if fetching fails

  // Stream subscription to resources.
  StreamSubscription<List<Resource>>? _resourcesSubscription;

  // Constructor: Use Provider to inject dependencies.
  ResourcesViewModel(this._resourceRepository) {
    print(
      'ResourcesViewModel: Initializing. Subscribing to resources stream.',
    ); // Debug log
    // Subscribe to the resource stream immediately when the ViewModel is created.
    _subscribeToResources(_resourceRepository);
    // Removed: _isLoading = true; // THIS LINE SHOULD BE REMOVED
    // The UI will handle the initial empty state display by checking if _resources is empty.
  }

  // Getters to expose the state to the View:
  List<Resource> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to subscribe to the ResourceRepository stream.
  void _subscribeToResources(ResourceRepository resourceRepository) {
    // Cancel any existing subscription before creating a new one.
    _resourcesSubscription?.cancel();

    // Subscribe to the stream. The listener will be called whenever resources change.
    _resourcesSubscription = resourceRepository.watchResources().listen(
      (resources) {
        print(
          'ResourcesViewModel: Stream listener received ${resources.length} resources.',
        ); // Debug log

        // When resources change, update the ViewModel's state.
        print(
          'ResourcesViewModel: Resources stream updated. Updating resources list...',
        ); // Debug log
        _resources = resources; // Update the list of resources
        print(
          'ResourcesViewModel: Received ${_resources.length} resources. Setting _isLoading = false.',
        ); // Debug log
        _isLoading =
            false; // Data is loaded after the first emission, set loading to false
        _errorMessage = null; // Clear any previous errors
        print('ResourcesViewModel: Calling notifyListeners().'); // Debug log
        notifyListeners(); // Notify listeners with the new data
      },
      onError: (error) {
        // Handle errors from the stream.
        print(
          'ResourcesViewModel: Stream error: $error. Setting _isLoading = false.',
        ); // Debug log
        _resources = []; // Clear resources on error
        _isLoading = false; // Set loading to false on error
        _errorMessage = 'Error in resources stream: ${error.toString()}';
        print('ResourcesViewModel: Calling notifyListeners().'); // Debug log
        notifyListeners();
        print('ResourcesViewModel: Stream error: $error'); // Log the error
      },
      onDone: () {
        // Handle stream completion (less common for repositories that live long).
        print(
          'ResourcesViewModel: Resources stream closed. Setting _isLoading = false.',
        ); // Debug log
        _isLoading = false;
        print('ResourcesViewModel: Calling notifyListeners().'); // Debug log
        notifyListeners();
      },
    );
  }

  // Remember to dispose of resources by cancelling the subscription.
  @override
  void dispose() {
    _resourcesSubscription?.cancel();
    print(
      'ResourcesViewModel: Resources stream subscription cancelled.',
    ); // Debug log
    super.dispose();
  }
}
