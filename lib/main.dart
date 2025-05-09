import 'package:ecotrack/presentation/screens/main_screen_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package

// Import ViewModels
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/track_viewmodel.dart';

// Import concrete Repository implementations
import 'package:ecotrack/data/repositories/activity_repository_impl.dart';
import 'package:ecotrack/data/repositories/footprint_repository_impl.dart';

// Import concrete Use Case implementations
import 'package:ecotrack/domain/use_cases/log_activity_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case_impl.dart';

// Import abstract Repository interfaces (needed for type hinting in Provider)
import 'package:ecotrack/domain/repositories/activity_repository.dart';
import 'package:ecotrack/domain/repositories/footprint_repository.dart';

// Import abstract Use Case interfaces (needed for type hinting in Provider)
import 'package:ecotrack/domain/use_cases/log_activity_use_case.dart';
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart';
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case.dart';

void main() {
  // We use MultiProvider to provide multiple dependencies at the root.
  runApp(
    MultiProvider(
      providers: [
        // Provide concrete Repository implementations.
        // Use the abstract interface type for loose coupling.
        Provider<ActivityRepository>(create: (_) => ActivityRepositoryImpl()),
        Provider<FootprintRepository>(create: (_) => FootprintRepositoryImpl()),

        // Provide concrete Use Case implementations.
        // Use the abstract interface type.
        // Use ProxyProvider if a dependency needs to access other providers.
        // LogActivityUseCase depends on ActivityRepository.
        Provider<LogActivityUseCase>(
          create:
              (context) => LogActivityUseCaseImpl(
                context
                    .read<
                      ActivityRepository
                    >(), // Get ActivityRepository from providers
                // context.read<FootprintRepository>(), // Uncomment if needed in Use Case
              ),
        ),
        // GetFootprintHistoryUseCase depends on FootprintRepository.
        Provider<GetFootprintHistoryUseCase>(
          create:
              (context) => GetFootprintHistoryUseCaseImpl(
                context
                    .read<
                      FootprintRepository
                    >(), // Get FootprintRepository from providers
              ),
        ),
        // CalculateFootprintUseCase depends on ActivityRepository.
        Provider<CalculateFootprintUseCase>(
          create:
              (context) => CalculateFootprintUseCaseImpl(
                context
                    .read<
                      ActivityRepository
                    >(), // Get ActivityRepository from providers
              ),
        ),

        // Provide the AppViewModel.
        // Use ChangeNotifierProvider for ViewModels that extend ChangeNotifier.
        ChangeNotifierProvider<AppViewModel>(
          create:
              (context) => AppViewModel(
                // AppViewModel doesn't currently depend on Use Cases, but could if needed for app-wide logic
                // e.g., context.read<GetFootprintHistoryUseCase>(),
              ),
        ),

        // Provide the DashboardViewModel.
        // Inject its dependencies using context.read.
        ChangeNotifierProvider<DashboardViewModel>(
          create:
              (context) => DashboardViewModel(
                context
                    .read<
                      GetFootprintHistoryUseCase
                    >(), // Inject GetFootprintHistoryUseCase
                context
                    .read<
                      CalculateFootprintUseCase
                    >(), // Inject CalculateFootprintUseCase
                context
                    .read<FootprintRepository>(), // Inject FootprintRepository
              ),
        ),

        // Provide the TrackViewModel.
        // It depends on LogActivityUseCase, which is provided above it.
        ChangeNotifierProvider<TrackViewModel>(
          create:
              (context) => TrackViewModel(
                context.read<LogActivityUseCase>(), // Inject the Use Case
              ),
        ),

        // Add other ViewModels here as they are created,
        // e.g., ChangeNotifierProvider<GoalsViewModel>(create: ...), etc.
      ],
      child: const MyApp(), // Our main application widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // The MaterialApp can access any of the provided dependencies if needed,
    // but typically it just sets up the theme and the initial screen.
    return MaterialApp(
      title: 'EcoTrack', // App title
      theme: ThemeData(
        primarySwatch:
            Colors.green, // Using a green primary color as per design system
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Set MainScreenContainer as the home screen
      home: const MainScreenContainer(),
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}
