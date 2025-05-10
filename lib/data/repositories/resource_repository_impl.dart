import 'dart:async'; // Import async for StreamController
import 'package:ecotrack/domain/entities/resource.dart'; // Import the Resource entity
import 'package:ecotrack/domain/repositories/resource_repository.dart'; // Import the abstract repository interface
import 'package:uuid/uuid.dart'; // Assuming uuid is already added for generating IDs

// In-memory implementation of the ResourceRepository interface.
// Provides sample sustainable living resources from a static list.
class ResourceRepositoryImpl implements ResourceRepository {
  // Static list of sample resources.
  // In a real app, this data would likely come from an API, CMS, or local data file.
  static final List<Resource> _resources = [
    Resource(
      id: const Uuid().v4(),
      title: '10 Simple Ways to Reduce Food Waste',
      description: 'Practical tips for minimizing food waste at home.',
      type: 'Article',
      url: 'https://example.com/food-waste-tips', // Placeholder URL
      category: 'Diet',
      imageUrl:
          'https://placehold.co/600x400/green/white?text=Food+Waste', // Placeholder image
      publicationDate: DateTime(2023, 10, 26),
    ),
    Resource(
      id: const Uuid().v4(),
      title: 'Beginner\'s Guide to Composting',
      description:
          'Learn how to start composting kitchen scraps and yard waste.',
      type: 'Article',
      url: 'https://example.com/composting-guide', // Placeholder URL
      category: 'Waste',
      imageUrl:
          'https://placehold.co/600x400/brown/white?text=Composting', // Placeholder image
      publicationDate: DateTime(2024, 01, 15),
    ),
    Resource(
      id: const Uuid().v4(),
      title: 'Choosing Eco-Friendly Transportation',
      description:
          'Compare the environmental impact of different ways to get around.',
      type: 'Article',
      url: 'https://example.com/eco-transport', // Placeholder URL
      category: 'Transportation',
      imageUrl:
          'https://placehold.co/600x400/blue/white?text=Transport', // Placeholder image
      publicationDate: DateTime(2023, 11, 01),
    ),
    Resource(
      id: const Uuid().v4(),
      title: 'Quick Tip: Save Energy with Smart Plugs',
      description:
          'Use smart plugs to easily turn off electronics when not in use.',
      type: 'Tip',
      url: '', // No URL for a simple tip
      category: 'Home Energy',
      publicationDate: DateTime(2024, 05, 10), // Today's date example
    ),
    Resource(
      id: const Uuid().v4(),
      title: 'Understanding Your Electricity Bill',
      description: 'Learn how to read your bill and find ways to save energy.',
      type: 'Article',
      url: 'https://example.com/electricity-bill', // Placeholder URL
      category: 'Home Energy',
      imageUrl:
          'https://placehold.co/600x400/yellow/black?text=Electricity', // Placeholder image
      publicationDate: DateTime(2024, 03, 20),
    ),
  ];

  // StreamController to manage the stream of resource lists.
  // The stream will emit the current list whenever it changes (or just once for static data).
  final _resourcesController =
      StreamController<
        List<Resource>
      >.broadcast(); // Use .broadcast for multiple listeners

  // Constructor: Initialize the stream with the static data.
  ResourceRepositoryImpl() {
    print(
      'ResourceRepositoryImpl: Initializing stream with static data.',
    ); // Debug log
    // Add the initial list of resources to the stream when the repository is created.
    // Use Future.microtask to ensure the stream is ready for listeners if subscribed immediately.
    Future.microtask(() {
      _resourcesController.sink.add(
        _resources.toList(),
      ); // Add a copy to the stream
    });
  }

  @override
  void dispose() {
    // Close the stream controller when the repository is no longer needed.
    // This prevents memory leaks.
    _resourcesController.close();
    print(
      'ResourceRepositoryImpl: StreamController disposed.',
    ); // For demonstration
  }

  @override
  Future<List<Resource>> getAllResources() async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 100));
    print(
      'ResourceRepositoryImpl: Getting all resources.',
    ); // For demonstration
    return _resources.toList(); // Return a copy
  }

  @override
  Future<List<Resource>> getResourcesByCategory(String category) async {
    // Simulate a small delay for async operation
    await Future.delayed(const Duration(milliseconds: 100));
    print(
      'ResourceRepositoryImpl: Getting resources by category: $category',
    ); // For demonstration
    // Filter resources by category (case-insensitive comparison)
    final filtered =
        _resources
            .where(
              (resource) =>
                  resource.category?.toLowerCase() == category.toLowerCase(),
            )
            .toList();
    print(
      'ResourceRepositoryImpl: Found ${filtered.length} resources in category "$category".',
    ); // For demonstration
    return filtered;
  }

  @override
  Stream<List<Resource>> watchResources() {
    print(
      'ResourceRepositoryImpl: Someone is watching resources stream.',
    ); // Debug log
    // The initial data is already added in the constructor.
    return _resourcesController.stream;
  }

  // getResourceById is not implemented in this basic version but could be added if needed.
}
