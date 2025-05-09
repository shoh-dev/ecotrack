import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/dashboard_viewmodel.dart'; // Import DashboardViewModel
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart'; // Import AppViewModel to listen to navigation state
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import FootprintEntry for type hinting

// HomeScreen is the View for the Dashboard.
// It is a StatefulWidget to manage its lifecycle and listen to tab changes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Keep track of the previously active index to trigger fetch only on tab change to Dashboard.
  int _previousIndex =
      -1; // Initialize with a value that won't match any valid index

  @override
  void initState() {
    super.initState();
    // Initial data fetch logic is in didChangeDependencies.
  }

  // This method is called whenever the widget's dependencies change.
  // It's also called once after initState.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get the current index from the AppViewModel using context.read.
    // We use read here because we only need the value *now* to decide whether to fetch.
    // didChangeDependencies is a safe place to use context.read or context.watch
    // after initState has completed.
    final currentIndex = context.watch<AppViewModel>().currentScreenIndex;

    // Check if the current index is the Dashboard index (0) AND
    // if the previous index was different from the current index.
    // This ensures the fetch is triggered only when the Dashboard tab becomes active.
    if (currentIndex == 0 && _previousIndex != currentIndex) {
      print(
        'HomeScreen: Navigated to Dashboard tab. Triggering data fetch.',
      ); // Debug log
      // Use Future.microtask to schedule the fetch after the build phase,
      // preventing issues with calling notifyListeners during build.
      Future.microtask(() {
        // Use context.read to call the ViewModel method.
        context.read<DashboardViewModel>().fetchDashboardData();
      });
    }

    // Update the previous index to the current index for the next comparison.
    _previousIndex = currentIndex;
  }

  @override
  void dispose() {
    // Clean up resources if needed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the DashboardViewModel to react to state changes (isLoading, messages, data).
    // This widget will rebuild when the ViewModel notifies listeners.
    // This context.watch call also establishes a dependency on DashboardViewModel,
    // which contributes to didChangeDependencies being called.
    // The dependency on AppViewModel.currentScreenIndex is implicitly handled
    // by the fact that MainScreenContainer rebuilds and potentially passes
    // down a different configuration, causing didChangeDependencies to fire.
    final dashboardViewModel = context.watch<DashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoTrack Dashboard'), // App bar title
        backgroundColor:
            Theme.of(context).primaryColor, // Use primary color from theme
      ),
      body: Center(
        child: _buildBody(
          context,
          dashboardViewModel,
        ), // Delegate building the body based on state
      ),
    );
  }

  // Helper method to build the body content based on ViewModel state.
  Widget _buildBody(BuildContext context, DashboardViewModel viewModel) {
    if (viewModel.isLoading) {
      // Show a loading indicator
      return const CircularProgressIndicator();
    } else if (viewModel.errorMessage != null) {
      // Show an error message
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: ${viewModel.errorMessage}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    } else if (viewModel.latestFootprint != null) {
      // Show the latest footprint data
      final footprint = viewModel.latestFootprint!;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Your Latest Footprint Estimate:',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            // Display total CO2e, formatted (formatting can be added later)
            '${footprint.totalCo2e.toStringAsFixed(2)} kg CO2e',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            // Display timestamp, formatted
            'as of ${footprint.timestamp.toLocal().toString().split('.')[0]}', // Basic formatting
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          // We can add category breakdown visualization here later
          // const SizedBox(height: 20),
          // Text('Category Breakdown: ${footprint.categoryBreakdown ?? 'N/A'}'),
        ],
      );
    } else {
      // No data available (e.g., first time user)
      return const Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No footprint data available yet. Log some activities to see your impact!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
  }
}
