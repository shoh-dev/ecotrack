import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/dashboard_viewmodel.dart'; // Import DashboardViewModel
// No longer need AppViewModel import here as we don't listen to its index directly.
// import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';
import 'package:ecotrack/domain/entities/footprint_entry.dart'; // Import FootprintEntry for type hinting

// HomeScreen is the View for the Dashboard.
// It is a StatelessWidget that consumes the DashboardViewModel,
// which now reacts to changes in the ActivityRepository stream.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Removed initState and didChangeDependencies as the ViewModel is reactive.

  @override
  Widget build(BuildContext context) {
    // Watch the DashboardViewModel to react to state changes (isLoading, messages, data).
    // This widget will rebuild when the ViewModel notifies listeners.
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
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No footprint data available yet. Log some activities to see your impact!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
  }
}
