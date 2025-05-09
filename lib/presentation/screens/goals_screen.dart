import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/goals_viewmodel.dart'; // Import GoalsViewModel
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart'; // Import AppViewModel to listen to navigation state
import 'package:ecotrack/domain/entities/goal.dart'; // Import Goal entity
import 'package:ecotrack/presentation/screens/create_goal_screen.dart'; // Import CreateGoalScreen

// GoalsScreen is the View for displaying and managing user goals.
// It is a StatefulWidget to manage its lifecycle and listen to tab changes.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Keep track of the previously active index to trigger fetch only on tab change to Goals.
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

    // Watch the AppViewModel to get the current screen index.
    // This establishes a dependency, ensuring didChangeDependencies is called
    // when currentScreenIndex changes.
    final appViewModel = context.watch<AppViewModel>();
    final currentIndex = appViewModel.currentScreenIndex;

    // Check if the current index is the Goals index (2) AND
    // if the previous index was different from the current index.
    // This ensures the fetch is triggered only when the Goals tab becomes active.
    // The index for Goals is 2 (Dashboard 0, Track 1, Goals 2).
    if (currentIndex == 2 && _previousIndex != currentIndex) {
      print(
        'GoalsScreen: Navigated to Goals tab. Triggering data fetch.',
      ); // Debug log
      // Use Future.microtask to schedule the fetch after the build phase.
      Future.microtask(() {
        // Use context.read to call the ViewModel method.
        context.read<GoalsViewModel>().fetchGoals();
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
    // Watch the GoalsViewModel to react to state changes (isLoading, messages, goals).
    // This widget will rebuild when the ViewModel notifies listeners.
    final goalsViewModel = context.watch<GoalsViewModel>();

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
          // Navigate to the CreateGoalScreen
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
          // Display each goal in a ListTile (basic representation for now)
          return ListTile(
            title: Text(goal.name),
            subtitle: Text(
              '${goal.type} - Target: ${goal.targetValue} ${goal.targetUnit}',
            ),
            trailing: Text(goal.status),
            onTap: () {
              // TODO: Implement navigation to a "Goal Details" screen
              print('Tapped on goal: ${goal.name}'); // Placeholder
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
