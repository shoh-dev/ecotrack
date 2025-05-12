import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart'; // Import AppViewModel
import 'package:ecotrack/presentation/screens/profile_screen.dart'; // Import ProfileScreen

// OnboardingScreen is the entry point for the user onboarding flow.
// It will guide the user through initial setup steps.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to EcoTrack!'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to EcoTrack!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Measure Your Impact. Reduce Your Footprint. Live More Sustainably.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the ProfileScreen as the first onboarding step.
                  // Pass a callback to signal that onboarding is complete after saving the profile.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ProfileScreen(
                            onboardingCompleteCallback: () {
                              // This callback will be executed by ProfileScreen after successful profile creation/save during onboarding.
                              context.read<AppViewModel>().completeOnboarding();
                            },
                          ),
                    ),
                  );
                },
                child: const Text('Start Onboarding'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
