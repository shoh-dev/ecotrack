import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/profile_viewmodel.dart'; // Import ProfileViewModel
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart'; // Import AppViewModel to listen to navigation state
import 'package:ecotrack/domain/entities/user_profile.dart'; // Import UserProfile entity
import 'package:intl/intl.dart'; // Import intl for date formatting

// ProfileScreen is the View for displaying and managing the user's profile.
// It is a StatefulWidget to manage lifecycle and form state, and consumes ProfileViewModel.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Global key for the form to manage validation state.
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _baselineYearController =
      TextEditingController(); // New controller for baseline year

  // State for dropdowns
  // String? _selectedPreferredUnits; // New state for preferred units (optional)
  // Using a simple list for now, could be enum or constants later
  final List<String> _unitSystems = ['Metric', 'Imperial'];
  String? _selectedUnitSystem; // State for selected unit system

  // Keep track of the previous save message to trigger actions only on change.
  String? _previousSaveMessage;

  // State for View/Edit Mode
  bool _isEditing = false; // Controls whether the form is editable

  @override
  void initState() {
    super.initState();
    print('ProfileScreen: initState called'); // Debug log

    // Fetch the user profile when the screen is initialized.
    // Use Future.microtask to ensure context is available after the first frame.
    Future.microtask(() {
      final viewModel = context.read<ProfileViewModel>();
      viewModel.fetchUserProfile();

      // Add a listener to populate fields when the profile is fetched.
      // We use addListener directly on the ViewModel instance here.
      // Remember to remove this listener in dispose.
      viewModel.addListener(_populateFieldsFromProfile);
    });
  }

  // Listener method to populate form fields when the goal is fetched.
  void _populateFieldsFromProfile() {
    final viewModel = context.read<ProfileViewModel>();
    final fetchedProfile = viewModel.userProfile;

    if (fetchedProfile != null) {
      // Use WidgetsBinding.instance.addPostFrameCallback to ensure
      // controllers are attached to TextFormFields before setting text.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _nameController.text = fetchedProfile.name;
        _emailController.text =
            fetchedProfile.email ?? ''; // Use empty string for null email
        _locationController.text =
            fetchedProfile.location ?? ''; // Use empty string for null location
        _baselineYearController.text =
            fetchedProfile.baselineYear?.toString() ??
            ''; // Populate baseline year

        // --- New: Populate new state variables from fetched profile ---
        setState(() {
          _selectedUnitSystem =
              fetchedProfile.preferredUnits; // Populate preferred units
        });
        // --- End New ---

        // --- New: Set _isEditing to false after populating fields ---
        // This switches to the read-only view after the profile is loaded.
        setState(() {
          _isEditing = false;
        });
        // --- End New ---

        print(
          'ProfileScreen: Fields populated from fetched profile.',
        ); // Debug log
      });
    } else {
      // If profile is null after fetch, ensure we are in editing mode to show the form.
      setState(() {
        _isEditing = true;
      });
      print(
        'ProfileScreen: Profile not found after fetch. Setting _isEditing = true.',
      ); // Debug log
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('ProfileScreen: didChangeDependencies called'); // Debug log

    // Watch the ProfileViewModel for save messages.
    final viewModel = context.watch<ProfileViewModel>();

    // Get the current save messages from the ViewModel.
    final currentSaveMessage = viewModel.saveMessage;
    final currentSaveErrorMessage = viewModel.saveErrorMessage;

    // Determine the current relevant message (success or error).
    final currentMessage = currentSaveMessage ?? currentSaveErrorMessage;

    // Check if the save message has changed compared to the previous state.
    if (currentMessage != null && currentMessage != _previousSaveMessage) {
      // Use Future.microtask to defer actions to after the build phase.
      Future.microtask(() {
        // If it's a success message, show a Snackbar.
        if (currentSaveMessage != null &&
            currentSaveMessage.contains('successfully')) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentSaveMessage)));
          // Clear the success message from the ViewModel after handling it.
          viewModel.clearSaveMessage();
          // --- New: Switch to read-only view after successful save ---
          setState(() {
            _isEditing = false;
          });
          // --- End New ---
        }
        // If it's an error message, show a Snackbar.
        else if (currentSaveErrorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(currentSaveErrorMessage)));
          // Clear the error message from the ViewModel after handling it.
          viewModel.clearSaveErrorMessage();
        }
      });
    }

    // Update the previous message for the next comparison.
    _previousSaveMessage = currentMessage;
  }

  @override
  void dispose() {
    // Clean up controllers when the widget is removed.
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _baselineYearController.dispose(); // Dispose new controller

    // Remove the listener added in initState.
    final viewModel = context.read<ProfileViewModel>();
    viewModel.removeListener(_populateFieldsFromProfile);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('ProfileScreen: build called'); // Debug log
    // Watch the ProfileViewModel to react to state changes (isLoading, messages, userProfile, isSaving).
    final profileViewModel = context.watch<ProfileViewModel>();
    print(
      'ProfileScreen: ViewModel state - isLoading: ${profileViewModel.isLoading}, isSaving: ${profileViewModel.isSaving}, errorMessage: ${profileViewModel.errorMessage}, userProfile: ${profileViewModel.userProfile != null}, isEditing: $_isEditing',
    ); // Debug log

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // App bar title
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          // Add Edit button
          if (profileViewModel.userProfile != null &&
              !profileViewModel.isLoading &&
              !profileViewModel.isSaving &&
              !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profile',
              onPressed: () {
                setState(() {
                  _isEditing = true; // Switch to editing mode
                });
              },
            ),
        ],
      ),
      body: _buildBody(
        context,
        profileViewModel,
      ), // Delegate building the body based on state
    );
  }

  // Helper method to build the body content based on ViewModel state and _isEditing.
  Widget _buildBody(BuildContext context, ProfileViewModel viewModel) {
    print(
      'ProfileScreen:_buildBody called. Checking ViewModel state...',
    ); // Debug log
    print(
      'ProfileScreen:_buildBody: isLoading: ${viewModel.isLoading}, isSaving: ${viewModel.isSaving}, errorMessage: ${viewModel.errorMessage}, userProfile: ${viewModel.userProfile != null}, isEditing: $_isEditing',
    ); // Debug log

    // Show loading for initial fetch OR for saving
    if (viewModel.isLoading || viewModel.isSaving) {
      // Check both loading and saving states
      print(
        'ProfileScreen:_buildBody: Showing loading indicator.',
      ); // Debug log
      // Show a loading indicator
      return const Center(child: CircularProgressIndicator());
    }
    // Show a general error message ONLY if there's an error AND the profile is null.
    // This handles cases where the fetch itself failed, not just 'not found'.
    else if (viewModel.errorMessage != null && viewModel.userProfile == null) {
      print(
        'ProfileScreen:_buildBody: Showing error message: ${viewModel.errorMessage}',
      ); // Debug log
      // Show an error message if initial fetch failed and no profile was loaded
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
    }
    // If profile exists AND we are NOT editing, show the read-only view.
    else if (viewModel.userProfile != null && !_isEditing) {
      print(
        'ProfileScreen:_buildBody: Displaying read-only view.',
      ); // Debug log
      return _buildReadOnlyView(
        context,
        viewModel.userProfile!,
      ); // Pass the loaded profile
    }
    // Otherwise (profile is null OR we ARE editing), display the editable form.
    else {
      print(
        'ProfileScreen:_buildBody: Displaying profile form (for creation or editing).',
      ); // Debug log
      final userProfile = viewModel.userProfile; // Can be null

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          // Wrap content in a Form widget
          key: _formKey, // Assign the form key
          child: ListView(
            // Use ListView for scrolling
            children: <Widget>[
              const Text(
                'Your Profile Information:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Input (Optional)
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (Optional)',
                ),
                keyboardType: TextInputType.emailAddress,
                // No validator needed if optional
              ),
              const SizedBox(height: 16),

              // Location Input (Optional)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location/Region (Optional)',
                ),
                // No validator needed if optional
              ),
              const SizedBox(height: 16),

              // --- New Fields for Profile ---
              // Preferred Units Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Preferred Units'),
                value: _selectedUnitSystem,
                items:
                    _unitSystems.map((String system) {
                      return DropdownMenuItem<String>(
                        value: system,
                        child: Text(system),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnitSystem = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select preferred units';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Baseline Year Input
              TextFormField(
                controller: _baselineYearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Baseline Year (Optional)',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null ||
                        year < 1900 ||
                        year > DateTime.now().year) {
                      // Basic year validation
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
              ),

              // --- End New Fields ---
              const SizedBox(height: 24),

              // Display loading indicator if saving (also handled by main loading check)
              if (viewModel.isSaving)
                const Center(child: CircularProgressIndicator()),

              // Display save messages via Snackbar (handled in didChangeDependencies)
              const SizedBox(height: 24),

              // Save Profile Button
              ElevatedButton(
                onPressed:
                    viewModel.isSaving
                        ? null
                        : () {
                          // Validate the form before attempting to save
                          if (_formKey.currentState!.validate()) {
                            // Form is valid, proceed with saving

                            final int? baselineYear =
                                _baselineYearController.text.trim().isNotEmpty
                                    ? int.tryParse(
                                      _baselineYearController.text.trim(),
                                    )
                                    : null; // Parse baseline year

                            // Call the ViewModel method with collected data.
                            // Pass the existing profile ID if updating, or null if creating.
                            viewModel.saveUserProfile(
                              id:
                                  userProfile
                                      ?.id, // Pass existing ID if profile is not null
                              name: _nameController.text.trim(),
                              email:
                                  _emailController.text.trim().isNotEmpty
                                      ? _emailController.text.trim()
                                      : null, // Pass null if empty
                              location:
                                  _locationController.text.trim().isNotEmpty
                                      ? _locationController.text.trim()
                                      : null, // Pass null if empty
                              memberSince:
                                  userProfile
                                      ?.memberSince, // Keep existing memberSince date
                              // settings: userProfile?.settings, // Keep existing settings or update
                              // --- New Fields ---
                              preferredUnits: _selectedUnitSystem,
                              baselineYear: baselineYear,
                              // --- End New Fields ---
                            );

                            // Snackbar and switching to read-only view will be handled in didChangeDependencies upon message change
                          }
                        },
                child: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Helper method to build a row for a profile detail.
  Widget _buildProfileDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120, // Fixed width for labels for alignment
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  // --- New Helper Method for Read-Only View ---
  Widget _buildReadOnlyView(BuildContext context, UserProfile profile) {
    print(
      'ProfileScreen:_buildReadOnlyView called for profile: ${profile.name}',
    ); // Debug log
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        // Use ListView for scrolling
        children: <Widget>[
          const Text(
            'Your Profile Information:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Name Display
          _buildProfileDetailRow('Name:', profile.name),
          const SizedBox(height: 8),

          // Email Display (if available)
          if (profile.email != null && profile.email!.isNotEmpty)
            _buildProfileDetailRow('Email:', profile.email!),
          if (profile.email != null && profile.email!.isNotEmpty)
            const SizedBox(height: 8),

          // Location Display (if available)
          if (profile.location != null && profile.location!.isNotEmpty)
            _buildProfileDetailRow('Location:', profile.location!),
          if (profile.location != null && profile.location!.isNotEmpty)
            const SizedBox(height: 8),

          // Member Since Display (if available)
          if (profile.memberSince != null)
            _buildProfileDetailRow(
              'Member Since:',
              DateFormat('yyyy-MM-dd').format(profile.memberSince!),
            ),
          if (profile.memberSince != null) const SizedBox(height: 8),

          // --- New Fields Display ---
          if (profile.preferredUnits != null &&
              profile.preferredUnits!.isNotEmpty)
            _buildProfileDetailRow('Preferred Units:', profile.preferredUnits!),
          if (profile.preferredUnits != null &&
              profile.preferredUnits!.isNotEmpty)
            const SizedBox(height: 8),

          if (profile.baselineYear != null)
            _buildProfileDetailRow(
              'Baseline Year:',
              profile.baselineYear!.toString(),
            ),
          if (profile.baselineYear != null) const SizedBox(height: 8),

          // --- End New Fields Display ---

          // TODO: Add display for settings etc. later
          const SizedBox(height: 24),

          // No Save button in read-only view. Edit button is in AppBar.
        ],
      ),
    );
  }
}
