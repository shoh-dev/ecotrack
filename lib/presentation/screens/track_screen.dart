import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/track_viewmodel.dart'; // Import TrackViewModel
import 'package:intl/intl.dart'; // Import intl for date formatting

// TrackScreen is the View for logging activities.
// It is a StatefulWidget to manage form state and lifecycle.
class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  // Global key for the form to manage validation state.
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();

  // State for dropdowns (simplified for now)
  String _selectedCategory = 'Transportation'; // Default category
  String _selectedType = 'Car Trip'; // Default type

  // State for timestamp (defaulting to now)
  DateTime _selectedTimestamp = DateTime.now();

  // Example lists for dropdowns (will come from a ViewModel/Model later)
  final List<String> _categories = [
    'Transportation',
    'Home Energy',
    'Diet',
    'Waste',
    'Consumption',
  ];
  final Map<String, List<String>> _types = {
    'Transportation': ['Car Trip', 'Bus Trip', 'Train Trip', 'Flight'],
    'Home Energy': ['Electricity Usage', 'Gas Usage'],
    'Diet': ['Meal'],
    'Waste': ['Recycling', 'Compost', 'Landfill'],
    'Consumption': ['Purchase'],
  };

  // Keep track of the previous log message to trigger field clearing only on change.
  String? _previousLogMessage;

  @override
  void initState() {
    super.initState();
    print('TrackScreen: initState called'); // Debug log

    // --- Debug: Pre-fill form fields for testing ---
    _valueController.text = '15.0'; // Sample value
    _unitController.text = 'km'; // Sample unit
    _selectedCategory = 'Transportation'; // Sample category
    _selectedType = 'Car Trip'; // Sample type
    _selectedTimestamp =
        DateTime.now(); // Sample timestamp (can adjust if needed for specific goal dates)
    // --- End Debug ---
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('TrackScreen: didChangeDependencies called'); // Debug log

    // Listen to changes in the TrackViewModel's logMessage.
    // Use context.watch to listen to the ViewModel.
    final trackViewModel = context.watch<TrackViewModel>();

    // Get the current messages from the ViewModel.
    final currentLogMessage = trackViewModel.logMessage;
    final currentErrorMessage = trackViewModel.errorMessage;

    // Determine the current relevant message (success or error).
    final currentMessage = currentLogMessage ?? currentErrorMessage;

    // If the message has changed and is a success message, clear the form and show Snackbar.
    if (currentLogMessage != null &&
        currentLogMessage != _previousLogMessage &&
        currentLogMessage.contains('successfully')) {
      // Check for success indicator
      // Use Future.microtask to defer UI actions.
      Future.microtask(() {
        _clearFormFields();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(currentLogMessage)));
      });
    }
    // If it's a new error message, show a Snackbar.
    else if (currentErrorMessage != null &&
        currentErrorMessage != _previousLogMessage) {
      // Use Future.microtask to defer UI actions.
      Future.microtask(() {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(currentErrorMessage)));
      });
    }

    // Update the previous log message.
    _previousLogMessage = currentMessage; // Update previous log/error message
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed.
    _valueController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  // Method to show a date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedTimestamp,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _selectedTimestamp) {
      setState(() {
        // Keep the time part from the original timestamp
        _selectedTimestamp = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _selectedTimestamp.hour,
          _selectedTimestamp.minute,
        );
      });
    }
  }

  // Method to show a time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTimestamp),
    );
    if (pickedTime != null) {
      setState(() {
        // Keep the date part from the original timestamp
        _selectedTimestamp = DateTime(
          _selectedTimestamp.year,
          _selectedTimestamp.month,
          _selectedTimestamp.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // Method to clear the form fields
  void _clearFormFields() {
    _formKey.currentState?.reset(); // Use form key reset for TextFormFields
    _valueController
        .clear(); // Clear controllers explicitly if needed (reset might cover this)
    _unitController.clear(); // Clear controllers explicitly
    setState(() {
      _selectedCategory = 'Transportation'; // Reset to default
      _selectedType = 'Car Trip'; // Reset to default
      _selectedTimestamp = DateTime.now(); // Reset to now
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the TrackViewModel to react to state changes (isLogging, messages).
    // This context.watch is primarily for updating the UI based on ViewModel state.
    final trackViewModel = context.watch<TrackViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Activity'),
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
                'Enter Activity Details:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                      // Reset type when category changes
                      _selectedType = _types[newValue]!.first;
                    });
                  }
                },
                validator: (value) {
                  // Add validator
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Type'),
                value: _selectedType,
                items:
                    _types[_selectedCategory]!.map((String type) {
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
                  // Add validator
                  if (value == null || value.isEmpty) {
                    return 'Please select a type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Value Input
              TextFormField(
                // Use TextFormField for validation
                controller: _valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Value (e.g., distance, kWh, count)',
                ),
                validator: (value) {
                  // Add validator
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Unit Input (could be a dropdown later based on category/type)
              TextFormField(
                // Use TextFormField for validation
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (e.g., km, mile, kWh, count)',
                ), // Clarified label
                validator: (value) {
                  // Add validator
                  if (value == null || value.isEmpty) {
                    return 'Please enter a unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Timestamp Input (Date and Time Pickers)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      // Make the date text tappable
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(_selectedTimestamp),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      // Make the time text tappable
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(
                          DateFormat('HH:mm').format(_selectedTimestamp),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Display loading indicator if logging
              if (trackViewModel.isLogging)
                const Center(child: CircularProgressIndicator()),

              // Display success or error message (Snackbars are also used now)
              // We removed the Text widgets here as Snackbars are now used for feedback.
              // if (trackViewModel.logMessage != null) ...
              // if (trackViewModel.errorMessage != null) ...
              const SizedBox(height: 24),

              // Button to trigger logging
              ElevatedButton(
                onPressed:
                    trackViewModel.isLogging
                        ? null
                        : () {
                          // Validate the form before attempting to log
                          if (_formKey.currentState!.validate()) {
                            // Form is valid, proceed with logging

                            final double? value = double.tryParse(
                              _valueController.text,
                            );
                            final String unit = _unitController.text.trim();

                            // Call the ViewModel method with collected data
                            trackViewModel.logActivity(
                              category: _selectedCategory,
                              type: _selectedType,
                              timestamp: _selectedTimestamp,
                              value:
                                  value!, // Use ! because validation ensures it's not null
                              unit: unit,
                              // details: {}, // Add details based on category/type later
                            );

                            // Fields will be cleared in didChangeDependencies upon success message
                          }
                        },
                child: const Text('Log Activity'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
