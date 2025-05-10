import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/goal_details_viewmodel.dart'; // Import GoalDetailsViewModel
import 'package:ecotrack/domain/entities/goal.dart'; // Import Goal entity
import 'package:intl/intl.dart'; // Import intl for date formatting

// GoalDetailsScreen is the View for displaying the details of a single goal.
// It takes a goalId as a parameter and uses GoalDetailsViewModel to fetch the data.
class GoalDetailsScreen extends StatefulWidget {
  final String goalId; // The ID of the goal to display

  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  @override
  void initState() {
    super.initState();
    print(
      'GoalDetailsScreen: initState called for goal ID: ${widget.goalId}',
    ); // Debug log
    // Fetch the goal details when the screen is initialized.
    // Use Future.microtask to ensure context is available after the first frame.
    Future.microtask(() {
      context.read<GoalDetailsViewModel>().fetchGoalDetails(widget.goalId);
    });
  }

  @override
  void dispose() {
    // Clean up resources if needed.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      'GoalDetailsScreen: build called for goal ID: ${widget.goalId}',
    ); // Debug log
    // Watch the GoalDetailsViewModel to react to state changes (isLoading, messages, goal).
    final goalDetailsViewModel = context.watch<GoalDetailsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          goalDetailsViewModel.goal?.name ?? 'Goal Details',
        ), // Use goal name if available
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _buildBody(
        context,
        goalDetailsViewModel,
      ), // Delegate building the body based on state
    );
  }

  // Helper method to build the body content based on ViewModel state.
  Widget _buildBody(BuildContext context, GoalDetailsViewModel viewModel) {
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
    } else if (viewModel.goal != null) {
      // Display the goal details
      final goal = viewModel.goal!;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // Use ListView for scrolling
          children: <Widget>[
            Text(
              goal.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Description: ${goal.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Type: ${goal.type}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Target: ${goal.targetValue} ${goal.targetUnit}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${goal.status}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Start Date: ${DateFormat('yyyy-MM-dd').format(goal.startDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'End Date: ${DateFormat('yyyy-MM-dd').format(goal.endDate)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            // TODO: Add Goal Progress display here later
            // TODO: Add Edit and Delete buttons here later
          ],
        ),
      );
    } else {
      // Should ideally not happen if errorMessage is set, but as a fallback
      return const Center(
        child: Text(
          'Goal details could not be loaded.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }
  }
}
