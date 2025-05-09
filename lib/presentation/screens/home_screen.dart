import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/dashboard_viewmodel.dart'; // Import DashboardViewModel

// HomeScreen is the View for the Dashboard.
// It is now a StatefulWidget to manage its lifecycle for initial data fetching.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the initial data fetch when the widget is created.
    // Use Future.microtask to ensure the fetch is scheduled after the build method
    // of the parent widget (MainScreenContainer) has completed and the context is fully available.
    // This is a common pattern when initState needs to access Provider.
    Future.microtask(() {
      // Use context.read to call methods on the ViewModel without listening for changes.
      context.read<DashboardViewModel>().fetchDashboardData();
    });
  }

  @override
  void dispose() {
    // Clean up resources if needed when the widget is removed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the DashboardViewModel to react to state changes.
    // This widget will rebuild when isLoading, errorMessage, or latestFootprint changes.
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
