import 'package:flutter/material.dart';

// CreateGoalScreen is the View for adding a new goal.
// It will contain a form for goal details.
class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Goal'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: const Center(
        child: Text(
          'Create Goal Form - Coming Soon!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
