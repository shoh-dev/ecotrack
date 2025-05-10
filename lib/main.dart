import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Import the provider package

// Import ViewModels
import 'package:ecotrack/presentation/viewmodels/app_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/track_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/goals_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/create_goal_viewmodel.dart';
import 'package:ecotrack/presentation/viewmodels/goal_details_viewmodel.dart';

// Import concrete Repository implementations
import 'package:ecotrack/data/repositories/activity_repository_db_impl.dart';
import 'package:ecotrack/data/repositories/footprint_repository_db_impl.dart';
import 'package:ecotrack/data/repositories/goal_repository_db_impl.dart';
import 'package:ecotrack/data/repositories/emission_factor_repository_db_impl.dart';

// Import concrete Use Case implementations
import 'package:ecotrack/domain/use_cases/log_activity_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/create_goal_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/get_goals_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/calculate_goal_progress_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/get_goal_by_id_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/update_goal_use_case_impl.dart';
import 'package:ecotrack/domain/use_cases/delete_goal_use_case_impl.dart';

// Import abstract Repository interfaces (needed for type hinting in Provider)
import 'package:ecotrack/domain/repositories/activity_repository.dart';
import 'package:ecotrack/domain/repositories/footprint_repository.dart';
import 'package:ecotrack/domain/repositories/goal_repository.dart';
import 'package:ecotrack/domain/repositories/emission_factor_repository.dart';

// Import abstract Use Case interfaces (needed for type hinting in Provider)
import 'package:ecotrack/domain/use_cases/log_activity_use_case.dart';
import 'package:ecotrack/domain/use_cases/get_footprint_history_use_case.dart';
import 'package:ecotrack/domain/use_cases/calculate_footprint_use_case.dart';
import 'package:ecotrack/domain/use_cases/create_goal_use_case.dart';
import 'package:ecotrack/domain/use_cases/get_goals_use_case.dart';
import 'package:ecotrack/domain/use_cases/calculate_goal_progress_use_case.dart';
import 'package:ecotrack/domain/use_cases/get_goal_by_id_use_case.dart';
import 'package:ecotrack/domain/use_cases/update_goal_use_case.dart';
import 'package:ecotrack/domain/use_cases/delete_goal_use_case.dart';

// Import DatabaseHelper
import 'package:ecotrack/data/database_helper.dart';

// Import Screens/Containers
import 'package:ecotrack/presentation/screens/main_screen_container.dart';
import 'package:sqflite/sqflite.dart';

// --- Debug Flag ---
// Set to true to delete the database on app start for testing.
const bool _clearDatabaseOnStart = true; // Set to true to clear database
// --- End Debug Flag ---

// Function to delete the database file.
Future<void> _deleteDatabase() async {
  try {
    // Get the application's documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(
      documentsDirectory.path,
      'ecotrack.db',
    ); // Use the database name constant if available in DatabaseHelper

    // Check if the database file exists
    final file = File(path);
    if (await file.exists()) {
      print('Deleting database at path: $path'); // Debug log
      await deleteDatabase(path);
      print('Database deleted.'); // Debug log
    } else {
      print(
        'Database file not found at path: $path. No deletion needed.',
      ); // Debug log
    }
  } catch (e) {
    print('Error deleting database: $e'); // Log any errors during deletion
  }
}

void main() async {
  // main needs to be async to await database initialization
  WidgetsFlutterBinding.ensureInitialized(); // Required before using plugins like sqflite

  // --- Debug: Clear database if flag is true ---
  if (_clearDatabaseOnStart) {
    await _deleteDatabase();
  }
  // --- End Debug ---

  // Get the singleton instance of DatabaseHelper
  final databaseHelper = DatabaseHelper();
  // Initialize the database before running the app
  await databaseHelper.database; // Await database initialization

  // We use MultiProvider to provide multiple dependencies at the root.
  runApp(
    MultiProvider(
      providers: [
        // Provide DatabaseHelper instance
        Provider<DatabaseHelper>(
          create:
              (_) =>
                  databaseHelper, // Provide the initialized singleton instance
          dispose:
              (_, dbHelper) =>
                  dbHelper
                      .close(), // Close the database when the app is disposed
        ),

        // Provide concrete Repository implementations.
        // Use the abstract interface type for loose coupling.
        // Add dispose callback for repositories that manage resources (like streams).
        Provider<ActivityRepository>(
          create:
              (context) => ActivityRepositoryDbImpl(
                context.read<DatabaseHelper>(),
              ), // Provide DbImpl and inject DatabaseHelper
          dispose:
              (_, repository) =>
                  repository
                      .dispose(), // Dispose the repository (closes stream controller)
        ),
        Provider<FootprintRepository>(
          // Provide DbImpl and inject DatabaseHelper
          create:
              (context) =>
                  FootprintRepositoryDbImpl(context.read<DatabaseHelper>()),
          // FootprintRepository does not have a dispose method in its abstract interface.
        ),
        Provider<GoalRepository>(
          // Provide DbImpl and inject DatabaseHelper
          create:
              (context) => GoalRepositoryDbImpl(context.read<DatabaseHelper>()),
          dispose:
              (_, repository) =>
                  repository
                      .dispose(), // Dispose the repository (closes stream controller)
        ),
        Provider<EmissionFactorRepository>(
          // Provide DbImpl and inject DatabaseHelper
          create:
              (context) => EmissionFactorRepositoryDbImpl(
                context.read<DatabaseHelper>(),
              ),
          dispose:
              (_, repository) =>
                  repository
                      .dispose(), // Dispose the repository (even if empty for consistency)
        ),

        // Provide concrete Use Case implementations.
        // LogActivityUseCase depends on ActivityRepository.
        Provider<LogActivityUseCase>(
          create:
              (context) => LogActivityUseCaseImpl(
                // Corrected spacing
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
                // Corrected spacing
                context
                    .read<
                      FootprintRepository
                    >(), // Get FootprintRepository from providers
              ),
        ),
        // CalculateFootprintUseCase depends on ActivityRepository AND EmissionFactorRepository.
        Provider<CalculateFootprintUseCase>(
          // Corrected spacing
          create:
              (context) => CalculateFootprintUseCaseImpl(
                // Corrected spacing
                context
                    .read<
                      ActivityRepository
                    >(), // Get ActivityRepository from providers
                context
                    .read<
                      EmissionFactorRepository
                    >(), // Inject EmissionFactorRepository
              ),
        ),
        // CreateGoalUseCase depends on GoalRepository.
        Provider<CreateGoalUseCase>(
          // Corrected spacing
          create:
              (context) => CreateGoalUseCaseImpl(
                // Corrected spacing
                context
                    .read<
                      GoalRepository
                    >(), // Get GoalRepository from providers
              ),
        ),
        // GetGoalsUseCase depends on GoalRepository.
        Provider<GetGoalsUseCase>(
          // Corrected spacing
          create:
              (context) => GetGoalsUseCaseImpl(
                // Corrected spacing
                context
                    .read<
                      GoalRepository
                    >(), // Get GoalRepository from providers
              ),
        ),
        // CalculateGoalProgressUseCase depends on ActivityRepository, FootprintRepository, AND EmissionFactorRepository.
        Provider<CalculateGoalProgressUseCase>(
          // Corrected spacing
          create:
              (context) => CalculateGoalProgressUseCaseImpl(
                // Corrected spacing
                context
                    .read<
                      ActivityRepository
                    >(), // Get ActivityRepository from providers
                context
                    .read<FootprintRepository>(), // Inject FootprintRepository
                context
                    .read<
                      EmissionFactorRepository
                    >(), // Inject EmissionFactorRepository
              ),
        ),
        // GetGoalByIdUseCase depends on GoalRepository.
        Provider<GetGoalByIdUseCase>(
          // Corrected spacing
          create:
              (context) => GetGoalByIdUseCaseImpl(
                // Corrected spacing
                context
                    .read<
                      GoalRepository
                    >(), // Get GoalRepository from providers
              ),
        ),
        // UpdateGoalUseCase depends on GoalRepository.
        Provider<UpdateGoalUseCase>(
          // Corrected spacing
          create:
              (context) => UpdateGoalUseCaseImpl(
                // Corrected spacing
                context
                    .read<
                      GoalRepository
                    >(), // Get GoalRepository from providers
              ),
        ),
        // DeleteGoalUseCase depends on GoalRepository.
        Provider<DeleteGoalUseCase>(
          // Corrected spacing
          create:
              (context) => DeleteGoalUseCaseImpl(
                // Corrected spacing
                context
                    .read<
                      GoalRepository
                    >(), // Get GoalRepository from providers
              ),
        ),

        // Provide the AppViewModel first, as other Viewmodels might depend on it (e.g., Dashboard).
        ChangeNotifierProvider<AppViewModel>(
          create: (context) => AppViewModel(),
        ),

        // Provide the DashboardViewModel.
        // Inject its dependencies, including ActivityRepository for the stream.
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
                context
                    .read<
                      ActivityRepository
                    >(), // Inject ActivityRepository for stream
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
        // It depends on GoalRepository for the stream AND CalculateGoalProgressUseCase AND ActivityRepository for its stream.
        ChangeNotifierProvider<GoalsViewModel>(
          create:
              (context) => GoalsViewModel(
                context
                    .read<GoalRepository>(), // Inject GoalRepository for stream
                context
                    .read<
                      ActivityRepository
                    >(), // Inject ActivityRepository for stream
                context
                    .read<
                      CalculateGoalProgressUseCase
                    >(), // Inject CalculateGoalProgressUseCase
              ),
        ),

        // Provide the CreateGoalViewModel.
        // It depends on CreateGoalUseCase.
        ChangeNotifierProvider<CreateGoalViewModel>(
          create:
              (context) => CreateGoalViewModel(
                context.read<CreateGoalUseCase>(), // Inject CreateGoalUseCase
              ),
        ),

        // Provide the GoalDetailsViewModel.
        // It depends on GetGoalByIdUseCase AND UpdateGoalUseCase AND DeleteGoalUseCase.
        ChangeNotifierProvider<GoalDetailsViewModel>(
          // Provide GoalDetailsViewModel
          create:
              (context) => GoalDetailsViewModel(
                context.read<GetGoalByIdUseCase>(), // Inject GetGoalByIdUseCase
                context.read<UpdateGoalUseCase>(), // Inject UpdateGoalUseCase
                context.read<DeleteGoalUseCase>(), // Inject DeleteGoalUseCase
              ),
        ),

        // Add other Viewmodels here as they are created.
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
