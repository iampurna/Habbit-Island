import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

// BLoCs
import 'blocs/auth/auth_bloc.dart';
import 'blocs/habit/habit_bloc.dart';
import 'blocs/island/island_bloc.dart';
import 'blocs/premium/premium_bloc.dart';
import 'blocs/sync/sync_bloc.dart';
import 'blocs/xp/xp_bloc.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/habit_repository.dart';
import 'data/repositories/island_repository.dart';
import 'data/repositories/premium_repository.dart';
import 'data/repositories/user_repository.dart';

// Services
import 'services/auth_service.dart';
import 'services/iap_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

// Use Cases
import 'domain/use_cases/habit/create_habit.dart';
import 'domain/use_cases/habit/complete_habit.dart';
import 'domain/use_cases/habit/update_habit.dart';
import 'domain/use_cases/habit/delete_habit.dart';
import 'domain/use_cases/habit/get_habits.dart';
import 'domain/use_cases/habit/use_streak_shield.dart';
import 'domain/use_cases/xp/award_xp.dart';
import 'domain/use_cases/xp/calculate_level.dart';
import 'domain/use_cases/sync/sync_data.dart';

// Config
import 'config/theme.dart';
import 'config/app_router.dart';
import 'config/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Services
  final storageService = StorageService();
  await storageService.init();

  final authService = AuthService();
  final notificationService = NotificationService();
  await notificationService.init();

  final iapService = IAPService();
  await iapService.init();

  // Initialize Repositories
  final authRepository = AuthRepository(
    authService: authService,
    storageService: storageService,
  );

  final habitRepository = HabitRepository(storageService: storageService);

  final islandRepository = IslandRepository(storageService: storageService);

  final premiumRepository = PremiumRepository(
    iapService: iapService,
    storageService: storageService,
  );

  final userRepository = UserRepository(storageService: storageService);

  // Initialize Use Cases
  final createHabit = CreateHabit(habitRepository);
  final completeHabit = CompleteHabit(habitRepository);
  final updateHabit = UpdateHabit(habitRepository);
  final deleteHabit = DeleteHabit(habitRepository);
  final getHabits = GetHabits(habitRepository);
  final useStreakShield = UseStreakShield(habitRepository);

  final awardXp = AwardXp(userRepository);
  final calculateLevel = CalculateLevel();

  final syncData = SyncData(
    habitRepository: habitRepository,
    userRepository: userRepository,
    islandRepository: islandRepository,
  );

  runApp(
    HabitIslandApp(
      authService: authService,
      authRepository: authRepository,
      habitRepository: habitRepository,
      islandRepository: islandRepository,
      premiumRepository: premiumRepository,
      createHabit: createHabit,
      completeHabit: completeHabit,
      updateHabit: updateHabit,
      deleteHabit: deleteHabit,
      getHabits: getHabits,
      useStreakShield: useStreakShield,
      awardXp: awardXp,
      calculateLevel: calculateLevel,
      syncData: syncData,
    ),
  );
}

class HabitIslandApp extends StatelessWidget {
  final AuthService authService;
  final AuthRepository authRepository;
  final HabitRepository habitRepository;
  final IslandRepository islandRepository;
  final PremiumRepository premiumRepository;
  final CreateHabit createHabit;
  final CompleteHabit completeHabit;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;
  final GetHabits getHabits;
  final UseStreakShield useStreakShield;
  final AwardXp awardXp;
  final CalculateLevel calculateLevel;
  final SyncData syncData;

  const HabitIslandApp({
    super.key,
    required this.authService,
    required this.authRepository,
    required this.habitRepository,
    required this.islandRepository,
    required this.premiumRepository,
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(authService: authService, authRepository: authRepository)
                ..add(const AuthStateChecked()),
        ),
        BlocProvider(
          create: (context) => HabitBloc(
            createHabit: createHabit,
            completeHabit: completeHabit,
            updateHabit: updateHabit,
            deleteHabit: deleteHabit,
            getHabits: getHabits,
            useStreakShield: useStreakShield,
          ),
        ),
        BlocProvider(
          create: (context) => IslandBloc(islandRepository: islandRepository),
        ),
        BlocProvider(
          create: (context) =>
              PremiumBloc(premiumRepository: premiumRepository),
        ),
        BlocProvider(create: (context) => SyncBloc(syncData: syncData)),
        BlocProvider(
          create: (context) =>
              XpBloc(awardXp: awardXp, calculateLevel: calculateLevel),
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
      ),
    );
  }
}
