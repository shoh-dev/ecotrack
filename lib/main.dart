import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package

// Import ViewModels
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/track_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/goals_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/create_goal_viewmodel.dart'; // Import CreateGoalViewModel

// Import concrete Repository implementations
import 'package:ecotrack/data/repositories/activity_repository_impl.dart';
import 'package:ecotrack/data/repositories/footprint_repository_impl.dart';
import 'package:ecotrack/data/repositories/goal_repository_impl.dart';

// Import concrete Use Case implementations
import 'package:ecotrack/domain/use_cases/log_activity_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/create_goal_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/get_goals_use_case_impl.dart';

// Import abstract Repository interfaces (needed for type hinting in Provider)
import 'package:ecotrack/domain/repositories/activity_repository.dart';
import 'package:ecotrack/domain/repositories/footprint_repository.dart';
import 'package:ecotrack/domain/repositories/goal_repository.dart';

// Import abstract Use Case interfaces (needed for type hinting in Provider)
import 'package:ecotrack/domain/use_cases/log_activity_use_case.dart';
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart';
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case.dart';
import 'package:ecotrack/domain/use_cases/create_goal_use_case.dart';
import 'package:ecotrack/domain/use_cases/get_goals_use_case.dart';

// Import Screens/Containers
import 'package:ecotrack/presentation/screens/main_screen_container.dart';

void main() {
  // We use MultiProvider to provide multiple dependencies at the root.
  runApp(
    MultiProvider(
      providers: [
        // Provide concrete Repository implementations.
        // Use the abstract interface type for loose coupling.
        Provider<ActivityRepository>(create: (_) => ActivityRepositoryImpl()),
        Provider<FootprintRepository>(create: (_) => FootprintRepositoryImpl()),
        Provider<GoalRepository>(
          // Provide GoalRepositoryImpl
          create: (_) => GoalRepositoryImpl(),
        ),

        // Provide concrete Use Case implementations.
        // LogActivityUseCase depends on ActivityRepository.
        Provider<LogActivityUseCase>(
          create:
              (context) => LogActivityUseCaseImpl(
                context
                    .read<
                      ActivityRepository
                    >(), // Get ActivityRepository from providers
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
        // CreateGoalUseCase depends on GoalRepository.
        Provider<CreateGoalUseCase>(
          // Provide CreateGoalUseCaseImpl
          create:
              (context) => CreateGoalUseCaseImpl(
                context
                    .read<
                      GoalRepository
                    >(), // Get GoalRepository from providers
              ),
        ),
        // GetGoalsUseCase depends on GoalRepository.
        Provider<GetGoalsUseCase>(
          // Provide GetGoalsUseCaseImpl
          create:
              (context) => GetGoalsUseCaseImpl(
                context
                    .read<
                      GoalRepository
                    >(), // Get GoalRepository from providers
              ),
        ),

        // Provide the AppViewModel first, as other ViewModels might depend on it (e.g., Dashboard).
        ChangeNotifierProvider<AppViewModel>(
          create: (context) => AppViewModel(),
        ),

        // Provide the DashboardViewModel.
        // Inject its dependencies.
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
        // Inject its dependency (LogActivityUseCase). No AppViewModel needed currently.
        ChangeNotifierProvider<TrackViewModel>(
          create:
              (context) => TrackViewModel(
                context.read<LogActivityUseCase>(), // Inject LogActivityUseCase
              ),
        ),

        // Provide the GoalsViewModel.
        // It depends on GetGoalsUseCase.
        ChangeNotifierProvider<GoalsViewModel>(
          create:
              (context) => GoalsViewModel(
                context.read<GetGoalsUseCase>(), // Inject GetGoalsUseCase
              ),
        ),

        // Provide the CreateGoalViewModel.
        // It depends on CreateGoalUseCase.
        ChangeNotifierProvider<CreateGoalViewModel>(
          // Provide CreateGoalViewModel
          create:
              (context) => CreateGoalViewModel(
                context.read<CreateGoalUseCase>(), // Inject CreateGoalUseCase
              ),
        ),

        // Add other ViewModels here as they are created.
        // e.g., ChangeNotifierProvider<ResourcesViewModel>(create: ...), etc.
      ],
      child: const MyApp(), // Our main application widget
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
