import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/resources_viewmodel.dart'; // Import ResourcesViewModel
// No longer need AppViewModel import here as we don't listen to its index directly.
// import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';
import 'package:ecotrack/domain/entities/resource.dart'; // Import Resource entity

// ResourcesScreen is the View for displaying sustainable living resources.
// It is a StatelessWidget that consumes the ResourcesViewModel,
// which now reacts to changes in the ResourceRepository stream.
class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  // Removed initState and didChangeDependencies as the ViewModel is reactive.

  @override
  Widget build(BuildContext context) {
    print('ResourcesScreen: build called'); // Debug log
    // Watch the ResourcesViewModel to react to state changes (isLoading, messages, resources).
    // This widget will rebuild when the ViewModel notifies listeners.
    final resourcesViewModel = context.watch<ResourcesViewModel>();
    print(
      'ResourcesScreen: ViewModel has ${resourcesViewModel.resources.length} resources, isLoading: ${resourcesViewModel.isLoading}, errorMessage: ${resourcesViewModel.errorMessage}',
    ); // Debug log

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sustainable Resources'), // App bar title
        backgroundColor:
            Theme.of(context).primaryColor, // Use primary color from theme
      ),
      body: _buildBody(
        context,
        resourcesViewModel,
      ), // Delegate building the body based on state
      // No FAB needed for this screen currently.
    );
  }

  // Helper method to build the body content based on ViewModel state.
  Widget _buildBody(BuildContext context, ResourcesViewModel viewModel) {
    if (viewModel.isLoading) {
      // Show a loading indicator
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null) {
      // Show an error message
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error: ${viewModel.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    } else if (viewModel.resources.isNotEmpty) {
      // Display the list of resources
      return ListView.builder(
        itemCount: viewModel.resources.length,
        itemBuilder: (context, index) {
          final resource = viewModel.resources[index];
          // Display each resource in a ListTile (basic representation for now)
          return ListTile(
            leading:
                resource.imageUrl != null
                    ? Image.network(
                      resource.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Provide a placeholder or error icon if image fails to load
                        return const Icon(Icons.broken_image, size: 50);
                      },
                    )
                    : null, // No leading if no image URL
            title: Text(resource.title),
            subtitle: Text('${resource.type} - ${resource.description}'),
            onTap: () {
              // TODO: Implement navigation to a resource detail view or open URL
              print('Tapped on resource: ${resource.title}'); // Placeholder
              if (resource.url != null && resource.url!.isNotEmpty) {
                // TODO: Open URL in a browser or in-app webview
                print('Opening URL: ${resource.url}');
              }
            },
          );
        },
      );
    } else {
      // No resources available
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No resources available at the moment.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
  }
}
