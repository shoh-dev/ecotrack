import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/goals_viewmodel.dart'; // Import GoalsViewModel
// No longer need AppViewModel import here as we don't listen to its index directly.
// import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';
import 'package:ecotrack/domain/entities/goal.dart'; // Import Goal entity
import 'package:ecotrack/presentation/screens/create_goal_screen.dart'; // Import CreateGoalScreen
import 'package:ecotrack/presentation/screens/goal_details_screen.dart'; // Import GoalDetailsScreen

// GoalsScreen is the View for displaying and managing user goals.
// It is a StatelessWidget that consumes the GoalsViewModel,
// which now reacts to changes in the GoalRepository stream and calculates progress.
class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  // Removed initState and didChangeDependencies as the ViewModel is reactive.

  @override
  Widget build(BuildContext context) {
    print('GoalsScreen: build called'); // Debug log
    // Watch the GoalsViewModel to react to state changes (isLoading, messages, goals, progress).
    // This widget will rebuild when the ViewModel notifies listeners.
    final goalsViewModel = context.watch<GoalsViewModel>();
    print(
      'GoalsScreen: ViewModel has ${goalsViewModel.goals.length} goals, isLoading: ${goalsViewModel.isLoading}, errorMessage: ${goalsViewModel.errorMessage}',
    ); // Debug log

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Goals'), // App bar title
        backgroundColor:
            Theme.of(context).primaryColor, // Use primary color from theme
      ),
      body: _buildBody(
        context,
        goalsViewModel,
      ), // Delegate building the body based on state
      floatingActionButton: FloatingActionButton(
        // Add a FAB for adding new goals
        onPressed: () {
          // Navigate to the "Create Goal" screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGoalScreen()),
          );
        },
        tooltip: 'Add New Goal',
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  // Helper method to build the body content based on ViewModel state.
  Widget _buildBody(BuildContext context, GoalsViewModel viewModel) {
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
    } else if (viewModel.goals.isNotEmpty) {
      // Display the list of goals
      return ListView.builder(
        itemCount: viewModel.goals.length,
        itemBuilder: (context, index) {
          final goal = viewModel.goals[index];
          // Get the progress for this goal from the ViewModel.
          final progress = viewModel.getGoalProgress(goal.id);
          print(
            'GoalsScreen: Displaying goal "${goal.name}", retrieved progress: ${progress.toStringAsFixed(2)}%',
          ); // Debug log

          // Display each goal in a ListTile, including progress.
          return ListTile(
            title: Text(goal.name),
            subtitle: Text(
              '${goal.type} - Target: ${goal.targetValue} ${goal.targetUnit}\nProgress: ${progress.toStringAsFixed(2)}%',
            ), // Display progress
            trailing: Text(goal.status),
            onTap: () {
              // Navigate to the GoalDetailsScreen when the list tile is tapped.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => GoalDetailsScreen(
                        goalId: goal.id,
                      ), // Pass the goal ID
                ),
              );
            },
          );
        },
      );
    } else {
      // No goals available
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No goals set yet. Tap the + button to add a new goal!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }
  }
}
