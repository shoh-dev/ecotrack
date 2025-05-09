import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/track_viewmodel.dart'; // Import TrackViewModel
import 'package:intl/intl.dart'; // Import intl for date formatting (add dependency if needed)

// Add the intl package dependency if you haven't already:
// flutter pub add intl

// TrackScreen is the View for logging activities.
// It is a StatefulWidget to manage form state.
class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  // Controllers for text input fields
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  // We'll add controllers for category/type later, or use dropdowns

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

  @override
  Widget build(BuildContext context) {
    // Watch the TrackViewModel to react to state changes (isLogging, messages).
    final trackViewModel = context.watch<TrackViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Activity'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          // Use ListView for scrolling if content exceeds screen height
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
            ),
            const SizedBox(height: 16),

            // Value Input
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Value (e.g., distance, kWh, count)',
              ),
            ),
            const SizedBox(height: 16),

            // Unit Input (could be a dropdown later based on category/type)
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit (e.g., km, kWh, count)',
              ),
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

            // Display success or error message
            if (trackViewModel.logMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  trackViewModel.logMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
            if (trackViewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  trackViewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            const SizedBox(height: 24),

            // Button to trigger logging
            ElevatedButton(
              onPressed:
                  trackViewModel.isLogging
                      ? null
                      : () {
                        // Get data from controllers and state
                        final double? value = double.tryParse(
                          _valueController.text,
                        );
                        final String unit = _unitController.text.trim();

                        // Basic validation (can be enhanced)
                        if (value == null || unit.isEmpty) {
                          // Show a basic error message or use a SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter a valid value and unit.',
                              ),
                            ),
                          );
                          return; // Stop here if validation fails
                        }

                        // Call the ViewModel method with collected data
                        trackViewModel.logActivity(
                          category: _selectedCategory,
                          type: _selectedType,
                          timestamp: _selectedTimestamp,
                          value: value,
                          unit: unit,
                          // details: {}, // Add details based on category/type later
                        );

                        // Optional: Clear fields after successful log (ViewModel could trigger this via state)
                        // _valueController.clear();
                        // _unitController.clear();
                        // setState(() { _selectedTimestamp = DateTime.now(); });
                      },
              child: const Text('Log Activity'),
            ),

            // More input fields and buttons will go here later
          ],
        ),
      ),
    );
  }
}
