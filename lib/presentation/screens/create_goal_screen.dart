import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/create_goal_viewmodel.dart'; // Import CreateGoalViewModel
import 'package:intl/intl.dart'; // Import intl for date formatting

// CreateGoalScreen is the View for adding a new goal.
// It contains a form for goal details and interacts with CreateGoalViewModel.
class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  // Global key for the form to manage validation state.
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _targetUnitController = TextEditingController();

  // State for dropdowns
  String _selectedType = 'FootprintReduction'; // Default type
  String _selectedStatus = 'Active'; // Default status

  // State for date pickers
  // Initialize with time component adjusted for full day coverage
  DateTime _selectedStartDate = DateTime.now().copyWith(
    hour: 0,
    minute: 0,
    second: 0,
    millisecond: 0,
    microsecond: 0,
  );
  DateTime _selectedEndDate = DateTime.now()
      .add(const Duration(days: 30))
      .copyWith(
        hour: 23,
        minute: 59,
        second: 59,
        millisecond: 999,
        microsecond: 999,
      );

  // Example lists for dropdowns (will come from a ViewModel/Model later)
  final List<String> _goalTypes = [
    'FootprintReduction',
    'ActivityTarget',
    'Habit',
  ];
  final List<String> _goalStatuses = ['Active', 'Completed', 'Failed'];

  // Keep track of the previous message to trigger actions only on change.
  String? _previousMessage;

  @override
  void initState() {
    super.initState();
    print('CreateGoalScreen: initState called'); // Debug log
    // No initial data fetch needed here.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('CreateGoalScreen: didChangeDependencies called'); // Debug log

    // Watch the CreateGoalViewModel.
    // This establishes a dependency, ensuring didChangeDependencies is called
    // when the ViewModel notifies listeners (e.g., after saving).
    final createGoalViewModel = context.watch<CreateGoalViewModel>();

    // Get the current messages from the ViewModel.
    final currentSaveMessage = createGoalViewModel.saveMessage;
    final currentErrorMessage = createGoalViewModel.errorMessage;

    // Determine the current relevant message (success or error).
    final currentMessage = currentSaveMessage ?? currentErrorMessage;

    // Check if the message has changed compared to the previous state.
    if (currentMessage != null && currentMessage != _previousMessage) {
      // Use Future.microtask to defer actions to after the build phase.
      Future.microtask(() {
        // If it's a success message, show a Snackbar and navigate back.
        if (currentSaveMessage != null &&
            currentSaveMessage.contains('successfully')) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentSaveMessage)));
          // Clear the success message from the ViewModel after handling it.
          createGoalViewModel.clearSaveMessage();
          // Navigate back to the Goals list screen
          Navigator.pop(context);
        }
        // If it's an error message, show a Snackbar.
        else if (currentErrorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentErrorMessage)));
          // Clear the error message from the ViewModel after handling it.
          createGoalViewModel.clearErrorMessage();
        }
      });
    }

    // Update the previous message for the next comparison.
    _previousMessage = currentMessage;
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed.
    _nameController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();
    super.dispose();
  }

  // Method to show a date picker for start date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101), // Allow selecting dates in the future
    );
    if (pickedDate != null && pickedDate != _selectedStartDate) {
      setState(() {
        // Set the time to the beginning of the day
        _selectedStartDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          0,
          0,
          0,
          0,
          0, // Set time to 00:00:00.000000
        );
        // Ensure end date is not before start date
        if (_selectedEndDate.isBefore(_selectedStartDate)) {
          _selectedEndDate = _selectedStartDate
              .add(const Duration(days: 1))
              .copyWith(
                hour: 23,
                minute: 59,
                second: 59,
                millisecond: 999,
                microsecond: 999,
              ); // Default to day after start, end of day
        }
      });
    }
  }

  // Method to show a date picker for end date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate, // End date cannot be before start date
      lastDate: DateTime(2101), // Allow selecting dates in the future
    );
    if (pickedDate != null && pickedDate != _selectedEndDate) {
      setState(() {
        // Set the time to the end of the day
        _selectedEndDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          23,
          59,
          59,
          999,
          999, // Set time to 23:59:59.999999
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the CreateGoalViewModel to react to state changes (isSaving, messages).
    // This context.watch is primarily for updating the UI based on ViewModel state.
    final createGoalViewModel = context.watch<CreateGoalViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Goal'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Wrap content in a Form widget
          key: _formKey, // Assign the form key
          child: ListView(
            // Use ListView for scrolling
            children: <Widget>[
              const Text(
                'Enter Goal Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Goal Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Goal Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Goal Description Input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Goal Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Goal Type'),
                value: _selectedType,
                items:
                    _goalTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a goal type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Goal Status Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _selectedStatus,
                items:
                    _goalStatuses.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Value Input
              TextFormField(
                controller: _targetValueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Target Value'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Target Unit Input
              TextFormField(
                controller: _targetUnitController,
                decoration: const InputDecoration(labelText: 'Target Unit'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Start Date Input (Date Picker)
              InkWell(
                onTap: () => _selectStartDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Start Date'),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedStartDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // End Date Input (Date Picker)
              InkWell(
                onTap: () => _selectEndDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'End Date'),
                  child: Text(
                    DateFormat('yyyy-MM-dd').format(_selectedEndDate),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Display loading indicator if saving
              if (createGoalViewModel.isSaving)
                const Center(child: CircularProgressIndicator()),

              // Display success or error message (Snackbars are also used now)
              // Text widgets for messages are removed as Snackbars provide feedback.
              const SizedBox(height: 24),

              // Button to trigger goal creation
              ElevatedButton(
                onPressed:
                    createGoalViewModel.isSaving
                        ? null
                        : () {
                          print(
                            'CreateGoalScreen: Save Goal button pressed',
                          ); // Debug log
                          // Validate the form before attempting to save
                          if (_formKey.currentState!.validate()) {
                            // Form is valid, proceed with saving

                            final double? targetValue = double.tryParse(
                              _targetValueController.text,
                            );

                            // Call the ViewModel method with collected data
                            createGoalViewModel.createGoal(
                              name: _nameController.text.trim(),
                              description: _descriptionController.text.trim(),
                              type: _selectedType,
                              targetUnit: _targetUnitController.text.trim(),
                              targetValue:
                                  targetValue!, // Use ! because validation ensures it's not null
                              startDate: _selectedStartDate,
                              endDate: _selectedEndDate,
                              status: _selectedStatus,
                              // details: {}, // Add details based on type later
                            );

                            // Navigation back or Snackbar will be handled in didChangeDependencies upon message change
                          }
                        },
                child: const Text('Save Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
