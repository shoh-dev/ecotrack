import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/goal_details_viewmodel.dart'; // Import GoalDetailsViewModel
import 'package:ecotrack/domain/entities/goal.dart'; // Import Goal entity
import 'package:intl/intl.dart'; // Import intl for date formatting

// GoalDetailsScreen is the View for displaying and editing the details of a single goal.
// It takes a goalId as a parameter and uses GoalDetailsViewModel to fetch and update/delete the data.
class GoalDetailsScreen extends StatefulWidget {
  final String goalId; // The ID of the goal to display or edit

  const GoalDetailsScreen({super.key, required this.goalId});

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  // Global key for the form to manage validation state.
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _targetUnitController = TextEditingController();

  // State for dropdowns
  String _selectedType =
      'FootprintReduction'; // Default type (will be updated from fetched goal)
  String _selectedStatus =
      'Active'; // Default status (will be updated from fetched goal)

  // State for date pickers
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 30));

  // Example lists for dropdowns (should ideally come from a ViewModel/Model/Constants)
  final List<String> _goalTypes = [
    'FootprintReduction',
    'ActivityTarget',
    'Habit',
  ];
  final List<String> _goalStatuses = ['Active', 'Completed', 'Failed'];

  // Keep track of previous messages to trigger actions only on change.
  String? _previousUpdateMessage;
  String? _previousDeleteMessage; // New state variable for delete messages

  @override
  void initState() {
    super.initState();
    print(
      'GoalDetailsScreen: initState called for goal ID: ${widget.goalId}',
    ); // Debug log

    // Fetch the goal details when the screen is initialized.
    // Use Future.microtask to ensure context is available after the first frame.
    Future.microtask(() {
      final viewModel = context.read<GoalDetailsViewModel>();
      viewModel.fetchGoalDetails(widget.goalId);

      // Add a listener to populate fields when the goal is fetched.
      viewModel.addListener(_populateFieldsFromGoal);
    });
  }

  // Listener method to populate form fields when the goal is fetched.
  void _populateFieldsFromGoal() {
    final viewModel = context.read<GoalDetailsViewModel>();
    final fetchedGoal = viewModel.goal;

    if (fetchedGoal != null) {
      // Use WidgetsBinding.instance.addPostFrameCallback to ensure
      // controllers are attached to TextFormFields before setting text.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nameController.text = fetchedGoal.name;
        _descriptionController.text = fetchedGoal.description;
        _targetValueController.text = fetchedGoal.targetValue.toString();
        _targetUnitController.text = fetchedGoal.targetUnit;

        // Use setState to update dropdowns and dates
        setState(() {
          _selectedType = fetchedGoal.type;
          _selectedStatus = fetchedGoal.status;
          _selectedStartDate = fetchedGoal.startDate;
          _selectedEndDate = fetchedGoal.endDate;
        });
        print(
          'GoalDetailsScreen: Fields populated from fetched goal.',
        ); // Debug log
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('GoalDetailsScreen: didChangeDependencies called'); // Debug log

    // Watch the GoalDetailsViewModel for update and delete messages.
    final viewModel = context.watch<GoalDetailsViewModel>();

    // --- Handle Update Messages ---
    final currentUpdateMessage = viewModel.updateMessage;
    final currentUpdateErrorMessage = viewModel.updateErrorMessage;
    final currentUpdateRelevantMessage =
        currentUpdateMessage ?? currentUpdateErrorMessage;

    if (currentUpdateRelevantMessage != null &&
        currentUpdateRelevantMessage != _previousUpdateMessage) {
      Future.microtask(() {
        if (currentUpdateMessage != null &&
            currentUpdateMessage.contains('successfully')) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentUpdateMessage)));
          viewModel.clearUpdateMessage();
          // Decide whether to navigate back after update. For now, just update the view.
          // Navigator.pop(context); // Uncomment if you want to navigate back
        } else if (currentUpdateErrorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentUpdateErrorMessage)));
          viewModel.clearUpdateErrorMessage();
        }
      });
    }
    _previousUpdateMessage = currentUpdateRelevantMessage;
    // --- End Handle Update Messages ---

    // --- Handle Delete Messages ---
    final currentDeleteMessage = viewModel.deleteMessage;
    final currentDeleteErrorMessage = viewModel.deleteErrorMessage;
    final currentDeleteRelevantMessage =
        currentDeleteMessage ?? currentDeleteErrorMessage;

    if (currentDeleteRelevantMessage != null &&
        currentDeleteRelevantMessage != _previousDeleteMessage) {
      Future.microtask(() {
        if (currentDeleteMessage != null &&
            currentDeleteMessage.contains('successfully')) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentDeleteMessage)));
          viewModel.clearDeleteMessage();
          // Navigate back to the Goals list screen after successful deletion.
          Navigator.pop(context);
        } else if (currentDeleteErrorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentDeleteErrorMessage)));
          viewModel.clearDeleteErrorMessage();
        }
      });
    }
    _previousDeleteMessage = currentDeleteRelevantMessage;
    // --- End Handle Delete Messages ---
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed.
    _nameController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    _targetUnitController.dispose();

    // Remove the listener added in initState.
    final viewModel = context.read<GoalDetailsViewModel>();
    viewModel.removeListener(_populateFieldsFromGoal);

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

  // Helper method to show a confirmation dialog before deleting.
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                'Are you sure you want to delete this goal? This action cannot be undone.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).pop(false), // Return false if cancelled
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).pop(true), // Return true if confirmed
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    print(
      'GoalDetailsScreen: build called for goal ID: ${widget.goalId}',
    ); // Debug log
    // Watch the GoalDetailsViewModel to react to state changes (isLoading, messages, goal, isUpdating, isDeleting).
    final goalDetailsViewModel = context.watch<GoalDetailsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          goalDetailsViewModel.goal?.name ?? 'Goal Details',
        ), // Use goal name if available
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // Add Delete button to the AppBar
          if (goalDetailsViewModel.goal != null &&
              !goalDetailsViewModel
                  .isDeleting) // Only show if goal loaded and not deleting
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Goal',
              onPressed: () async {
                // Show confirmation dialog before deleting
                final confirmed = await _confirmDelete(context);
                if (confirmed) {
                  // Call the ViewModel's delete method
                  goalDetailsViewModel.deleteGoal(widget.goalId);
                }
              },
            ),
          if (goalDetailsViewModel
              .isDeleting) // Show loading indicator in AppBar while deleting
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
      body: _buildBody(
        context,
        goalDetailsViewModel,
      ), // Delegate building the body based on state
    );
  }

  // Helper method to build the body content based on ViewModel state.
  Widget _buildBody(BuildContext context, GoalDetailsViewModel viewModel) {
    // Show loading for initial fetch OR for update/delete
    if (viewModel.isLoading || viewModel.isUpdating) {
      // Check both loading and updating states
      // Show a loading indicator
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.errorMessage != null) {
      // Show an error message if initial fetch failed
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
      // Display the editable goal details form
      final goal = viewModel.goal!;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Wrap content in a Form widget
          key: _formKey, // Assign the form key
          child: ListView(
            // Use ListView for scrolling
            children: <Widget>[
              const Text(
                'Edit Goal Details:',
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

              // Goal Type Dropdown (Consider making this read-only after creation)
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

              // Display loading indicator if updating
              if (viewModel.isUpdating)
                const Center(child: CircularProgressIndicator()),

              // Display update/delete messages via Snackbar (handled in didChangeDependencies)
              const SizedBox(height: 24),

              // Save Goal Button
              ElevatedButton(
                onPressed:
                    viewModel.isUpdating
                        ? null
                        : () {
                          // Validate the form before attempting to save
                          if (_formKey.currentState!.validate()) {
                            // Form is valid, proceed with updating

                            final double? targetValue = double.tryParse(
                              _targetValueController.text,
                            );

                            // Call the ViewModel method with collected data and the goal's ID
                            viewModel.updateGoal(
                              id: goal.id, // Pass the original goal's ID
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

                            // Snackbar will be handled in didChangeDependencies upon message change
                          }
                        },
                child: const Text('Save Changes'),
              ),

              // TODO: Add Delete Button here later
            ],
          ),
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
