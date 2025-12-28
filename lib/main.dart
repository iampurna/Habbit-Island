import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:habbit_island/data/data_sources/local/habit_local_ds.dart';
import 'package:habbit_island/data/data_sources/local/hive_database.dart';
import 'package:habbit_island/data/data_sources/local/user_local_ds.dart';
import 'package:habbit_island/data/data_sources/remote/habit_remote_ds.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';

// Firebase Options
import 'firebase_options.dart';

// BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/habit/habit_bloc.dart';
import 'presentation/blocs/island/island_bloc.dart';
import 'presentation/blocs/premium/premium_bloc.dart';
import 'presentation/blocs/sync/sync_bloc.dart';
import 'presentation/blocs/xp/xp_bloc.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/habit_repository.dart';
import 'data/repositories/island_repository.dart';
import 'data/repositories/premium_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/sync_repository.dart';
import 'data/repositories/xp_repository.dart';

// Services
import 'data/services/auth_service.dart';
import 'data/services/iap_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/analytics_service.dart';
import 'data/services/ad_service.dart';

// Use Cases
import 'domain/use_cases/habits/create_habit.dart';
import 'domain/use_cases/habits/complete_habit.dart';
import 'domain/use_cases/habits/update_habit.dart';
import 'domain/use_cases/habits/delete_habit.dart';
import 'domain/use_cases/habits/get_habits.dart';
import 'domain/use_cases/streaks/use_streak_shield.dart';
import 'domain/use_cases/xp/award_xp.dart';
import 'domain/use_cases/xp/calculate_level.dart';
import 'domain/use_cases/sync/sync_data.dart';

// Config
import 'core/theme/app_theme.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/routes/route_generator.dart';

// Utils
import 'core/utils/app_logger.dart';

// Background callback for sync
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      AppLogger.info('Background sync task started: $task');
      // TODOs: Implement actual sync logic with SyncRepository
      return Future.value(true);
    } catch (e, stackTrace) {
      AppLogger.error('Background sync failed', e, stackTrace);
      return Future.value(false);
    }
  });
}

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize app
  await _initializeApp();
}

Future<void> _initializeApp() async {
  try {
    // Load environment variables
    await _loadEnvironment();

    // Initialize Firebase
    await _initializeFirebase();

    // Initialize Hive
    await _initializeHive();

    // Initialize Services
    final services = await _initializeServices();

    // Initialize Repositories
    final repositories = await _initializeRepositories(services);

    // Initialize Use Cases
    final useCases = _initializeUseCases(repositories);

    // Initialize Background Tasks
    await _initializeBackgroundTasks();

    // Run App
    runApp(
      HabitIslandApp(
        services: services,
        repositories: repositories,
        useCases: useCases,
      ),
    );
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize app', e, stackTrace);
    // Show error screen
    runApp(const AppErrorScreen());
  }
}

/// Load environment variables
Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: '.env');
    AppLogger.info('Environment variables loaded');
  } catch (e) {
    AppLogger.warning('No .env file found, using default values');
  }
}

/// Initialize Firebase
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Firebase initialization failed', e, stackTrace);
    rethrow;
  }
}

/// Initialize Hive local database
Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();
    AppLogger.info('Hive initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Hive initialization failed', e, stackTrace);
    rethrow;
  }
}

/// Initialize all services
Future<AppServices> _initializeServices() async {
  try {
    // Storage Service
    final storageService = StorageService();
    await storageService.init();

    // Auth Service
    final authService = AuthService();

    // Analytics Service
    final analyticsService = AnalyticsService();
    await analyticsService.init();

    // Notification Service
    final notificationService = NotificationService(
      analytics: analyticsService,
    );
    await notificationService.init();

    // IAP Service
    final iapService = IAPService(analytics: analyticsService);
    await iapService.init();

    // Ad Service
    final adService = AdService(analytics: analyticsService);
    await adService.init();

    AppLogger.info('All services initialized successfully');

    return AppServices(
      storage: storageService,
      auth: authService,
      notification: notificationService,
      iap: iapService,
      analytics: analyticsService,
      ad: adService,
    );
  } catch (e, stackTrace) {
    AppLogger.error('Service initialization failed', e, stackTrace);
    rethrow;
  }
}

/// Initialize all repositories (implement data sources to avoid nulls)
Future<AppRepositories> _initializeRepositories(AppServices services) async {
  try {
    // TODOs: Implement these data sources (e.g., HabitRemoteDataSource using Firebase)
    final habitLocalDS = HabitLocalDataSource(services.storage as HiveDatabase);
    final habitRemoteDS = HabitRemoteDataSource(); // Implement this
    final syncQueueDS = SyncQueueDataSource(storage: services.storage);
    final userLocalDS = UserLocalDataSource(
      services.storage as HiveDatabase,
    ); // Implement if needed
    final userRemoteDS = UserRemoteDataSource(); // Implement this
    final completionsLocalDS = CompletionLocalDataSource(
      services.storage,
    ); // Implement if needed
    final completionsRemoteDS = CompletionRemoteDataSource(); // Implement this

    final authRepository = AuthRepository(
      authService: services.auth,
      storageService: services.storage,
    );

    final habitRepository = HabitRepository(
      storageService: services.storage,
      localDS: habitLocalDS,
      remoteDS: habitRemoteDS,
      syncQueueDS: syncQueueDS,
    );

    final islandRepository = IslandRepository(storageService: services.storage);

    final premiumRepository = PremiumRepository(
      iapService: services.iap,
      storageService: services.storage,
      localDS: userLocalDS, // Use appropriate DS
      remoteDS: userRemoteDS,
    );

    final userRepository = UserRepository(
      storageService: services.storage,
      localDS: userLocalDS,
      remoteDS: userRemoteDS,
    );

    final syncRepository = SyncRepository(
      storageService: services.storage,
      habitLocalDS: habitLocalDS,
      userLocalDS: userLocalDS,
      completionsLocalDS: completionsLocalDS,
      syncQueueDS: syncQueueDS,
      syncRemoteDS: SyncRemoteDataSource(), // Implement this
      habitRemoteDS: habitRemoteDS,
      userRemoteDS: userRemoteDS,
      completionsRemoteDS: completionsRemoteDS,
    );

    final xpRepository = XpRepository(
      storageService: services.storage,
      completionsLocalDS: completionsLocalDS,
      completionsRemoteDS: completionsRemoteDS,
      userLocalDS: userLocalDS,
      userRemoteDS: userRemoteDS,
      habitLocalDS: habitLocalDS,
    );

    AppLogger.info('All repositories initialized successfully');

    return AppRepositories(
      auth: authRepository,
      habit: habitRepository,
      island: islandRepository,
      premium: premiumRepository,
      user: userRepository,
      sync: syncRepository,
      xp: xpRepository,
    );
  } catch (e, stackTrace) {
    AppLogger.error('Repository initialization failed', e, stackTrace);
    rethrow;
  }
}

/// Initialize all use cases
AppUseCases _initializeUseCases(AppRepositories repositories) {
  return AppUseCases(
    createHabit: CreateHabit(repositories.habit),
    completeHabit: CompleteHabit(
      repositories.habit,
      habitRepository: null,
      completionRepository: null,
      xpRepository: null,
    ),
    updateHabit: UpdateHabit(repositories.habit),
    deleteHabit: DeleteHabit(repositories.habit),
    getHabits: GetHabits(repositories.habit),
    useStreakShield: UseStreakShield(
      repositories.habit,
      habitRepository: null,
      premiumRepository: null,
    ),
    awardXp: AwardXp(repositories.xp),
    calculateLevel: CalculateLevel(repositories.xp),
    syncData: SyncData(
      repositories.sync,
      habitRepository: repositories.habit,
      userRepository: repositories.user,
      islandRepository: repositories.island,
    ),
  );
}

/// Initialize background tasks
Future<void> _initializeBackgroundTasks() async {
  try {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // Register periodic sync task (every 1 hour)
    await Workmanager().registerPeriodicTask(
      'habit-island-sync',
      'syncData',
      frequency: const Duration(hours: 1),
      constraints: Constraints(networkType: NetworkType.connected),
    );

    AppLogger.info('Background tasks initialized');
  } catch (e, stackTrace) {
    AppLogger.error('Background task initialization failed', e, stackTrace);
    // Non-critical, don't throw
  }
}

// ============================================================================
// SERVICE CONTAINER
// ============================================================================

class AppServices {
  final StorageService storage;
  final AuthService auth;
  final NotificationService notification;
  final IAPService iap;
  final AnalyticsService analytics;
  final AdService ad;

  AppServices({
    required this.storage,
    required this.auth,
    required this.notification,
    required this.iap,
    required this.analytics,
    required this.ad,
  });
}

class AppRepositories {
  final AuthRepository auth;
  final HabitRepository habit;
  final IslandRepository island;
  final PremiumRepository premium;
  final UserRepository user;
  final SyncRepository sync;
  final XpRepository xp;

  AppRepositories({
    required this.auth,
    required this.habit,
    required this.island,
    required this.premium,
    required this.user,
    required this.sync,
    required this.xp,
  });
}

class AppUseCases {
  final CreateHabit createHabit;
  final CompleteHabit completeHabit;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;
  final GetHabits getHabits;
  final UseStreakShield useStreakShield;
  final AwardXp awardXp;
  final CalculateLevel calculateLevel;
  final SyncData syncData;

  AppUseCases({
    required this.createHabit,
    required this.completeHabit,
    required this.updateHabit,
    required this.deleteHabit,
    required this.getHabits,
    required this.useStreakShield,
    required this.awardXp,
    required this.calculateLevel,
    required this.syncData,
  });
}

// ============================================================================
// APP WIDGET
// ============================================================================

class HabitIslandApp extends StatelessWidget {
  final AppServices services;
  final AppRepositories repositories;
  final AppUseCases useCases;

  const HabitIslandApp({
    super.key,
    required this.services,
    required this.repositories,
    required this.useCases,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authService: services.auth,
            authRepository: repositories.auth,
          )..add(const AuthStateChecked()),
        ),
        BlocProvider(
          create: (context) => HabitBloc(
            createHabit: useCases.createHabit,
            completeHabit: useCases.completeHabit,
            updateHabit: useCases.updateHabit,
            deleteHabit: useCases.deleteHabit,
            getHabits: useCases.getHabits,
            useStreakShield: useCases.useStreakShield,
          ),
        ),
        BlocProvider(
          create: (context) => IslandBloc(repository: repositories.island),
        ),
        BlocProvider(
          create: (context) => PremiumBloc(
            iapService: services.iap,
            repository: repositories.premium,
            premiumRepository: null,
          ),
        ),
        BlocProvider(
          create: (context) => SyncBloc(syncData: useCases.syncData),
        ),
        BlocProvider(
          create: (context) => XpBloc(
            awardXp: useCases.awardXp,
            calculateLevel: useCases.calculateLevel,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Habit Island',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRouter.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
        builder: (context, child) {
          // Global error widget builder
          ErrorWidget.builder = (details) {
            return MaterialApp(
              home: Scaffold(
                body: Center(child: Text('Error: ${details.exception}')),
              ),
            );
          };
          return child!;
        },
      ),
    );
  }
}

// ============================================================================
// ERROR SCREEN
// ============================================================================

class AppErrorScreen extends StatelessWidget {
  const AppErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 24),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize the app. Please try restarting.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart app
                    SystemNavigator.pop();
                  },
                  child: const Text('Exit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
