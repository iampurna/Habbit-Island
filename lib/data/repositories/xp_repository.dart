import 'package:dartz/dartz.dart';
import 'package:habbit_island/data/data_sources/local/completion_local_ds.dart';
import 'package:habbit_island/data/data_sources/remote/completion_remote_ds.dart';
import '../data_sources/local/user_local_ds.dart';
import '../data_sources/local/habit_local_ds.dart';
import '../data_sources/remote/user_remote_ds.dart';
import '../models/xp_event_model.dart';
import '../models/habit_model.dart';
import '../models/habit_completion_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';

/// XP Repository
/// Centralized XP management: awarding, tracking, analytics, and leaderboards
/// Reference: Product Documentation §3.2 (XP System)
///
/// XP Sources (Product Documentation §3.2):
/// - Habit completion: +10 XP
/// - All daily complete: +50 XP bonus
/// - 7-day milestone: +100 XP
/// - 30-day milestone: +500 XP
/// - Daily login: +5 XP
/// - Rewarded ad: +50 XP
/// - Referral bonus: +100 XP (Post-MVP)
/// - Achievement unlock: Variable (Post-MVP)

class XpRepository {
  final CompletionsLocalDataSource _completionsLocalDS;
  final CompletionsRemoteDataSource _completionsRemoteDS;
  final UserLocalDataSource _userLocalDS;
  final UserRemoteDataSource _userRemoteDS;
  final HabitLocalDataSource _habitLocalDS;

  XpRepository({
    required CompletionsLocalDataSource completionsLocalDS,
    required CompletionsRemoteDataSource completionsRemoteDS,
    required UserLocalDataSource userLocalDS,
    required UserRemoteDataSource userRemoteDS,
    required HabitLocalDataSource habitLocalDS,
  }) : _completionsLocalDS = completionsLocalDS,
       _completionsRemoteDS = completionsRemoteDS,
       _userLocalDS = userLocalDS,
       _userRemoteDS = userRemoteDS,
       _habitLocalDS = habitLocalDS;

  // ============================================================================
  // AWARD XP METHODS
  // ============================================================================

  /// Award XP for habit completion (+10 XP base + potential bonuses)
  /// Returns total XP awarded (may include bonuses)
  Future<Either<Failure, XpAwardResult>> awardHabitCompletionXp({
    required String habitId,
    required String userId,
    required DateTime completedAt,
  }) async {
    try {
      int totalXp = 0;
      final events = <XpEventModel>[];

      // 1. Base XP: +10 for habit completion
      final habitXpEvent = XpEventModel.habitCompletion(
        id: _generateId(),
        userId: userId,
        habitId: habitId,
        earnedAt: completedAt,
      );
      await _saveXpEvent(habitXpEvent);
      events.add(habitXpEvent);
      totalXp += 10;

      // 2. Check for all daily habits complete bonus (+50 XP)
      final allDailyComplete = await _checkAllDailyHabitsComplete(
        userId,
        completedAt,
      );

      if (allDailyComplete) {
        final habits = await _habitLocalDS.getActiveHabits(userId);
        final dailyHabits = habits.where((h) => h.shouldShowToday(completedAt));

        final bonusEvent = XpEventModel.allDailyComplete(
          id: _generateId(),
          userId: userId,
          habitCount: dailyHabits.length,
          earnedAt: completedAt,
        );
        await _saveXpEvent(bonusEvent);
        events.add(bonusEvent);
        totalXp += 50;
      }

      // 3. Check for streak milestone bonus (+100 or +500 XP)
      final milestoneXp = await _checkMilestoneBonus(
        habitId,
        userId,
        completedAt,
      );

      if (milestoneXp != null) {
        events.add(milestoneXp);
        totalXp += milestoneXp.xpAmount;
      }

      // 4. Add total XP to user (updates level automatically)
      await _addXpToUser(userId, totalXp);

      return Right(
        XpAwardResult(
          totalXpAwarded: totalXp,
          events: events,
          hasBonus: allDailyComplete || milestoneXp != null,
          bonusType: _determineBonusType(allDailyComplete, milestoneXp),
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Award XP for daily login (+5 XP)
  Future<Either<Failure, XpAwardResult>> awardDailyLoginXp(
    String userId,
  ) async {
    try {
      // Check if already awarded today
      final alreadyAwarded = await _hasLoginXpToday(userId);
      if (alreadyAwarded) {
        return Left(XpAlreadyClaimedFailure('Daily login XP already claimed'));
      }

      final event = XpEventModel.dailyLogin(id: _generateId(), userId: userId);

      await _saveXpEvent(event);
      await _addXpToUser(userId, 5);

      return Right(
        XpAwardResult(totalXpAwarded: 5, events: [event], hasBonus: false),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Award XP for watching rewarded ad (+50 XP)
  /// Reference: Product Documentation §6.3 (Ad System)
  Future<Either<Failure, XpAwardResult>> awardRewardedAdXp({
    required String userId,
    required String adId,
    int maxPerDay = 3, // Product Doc: Max 3 ads per day
  }) async {
    try {
      // Check daily limit
      final adsWatchedToday = await _countRewardedAdsToday(userId);
      if (adsWatchedToday >= maxPerDay) {
        return Left(
          AdLimitFailure(watchedToday: adsWatchedToday, maxPerDay: maxPerDay),
        );
      }

      final event = XpEventModel.rewardedAd(
        id: _generateId(),
        userId: userId,
        adId: adId,
      );

      await _saveXpEvent(event);
      await _addXpToUser(userId, 50);

      return Right(
        XpAwardResult(
          totalXpAwarded: 50,
          events: [event],
          hasBonus: false,
          metadata: {
            'ads_watched_today': adsWatchedToday + 1,
            'ads_remaining_today': maxPerDay - (adsWatchedToday + 1),
          },
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Award XP for milestone (called internally by habit completion)
  Future<XpEventModel?> _checkMilestoneBonus(
    String habitId,
    String userId,
    DateTime completedAt,
  ) async {
    try {
      // Get current streak from completions
      final completions = await _completionsLocalDS.getCompletions(habitId);
      final dates = completions.map((c) => c.logicalDate).toList();

      // Calculate current streak
      int currentStreak = _calculateCurrentStreak(dates);

      // Check if this is a milestone (7 or 30 days)
      if (currentStreak == 7 || currentStreak == 30) {
        return XpEventModel.streakMilestone(
          id: _generateId(),
          userId: userId,
          habitId: habitId,
          streakDays: currentStreak,
          earnedAt: completedAt,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Award manual XP (admin/promotional)
  Future<Either<Failure, XpAwardResult>> awardManualXp({
    required String userId,
    required int xpAmount,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final event = XpEventModel(
        id: _generateId(),
        userId: userId,
        type: XpEventType.manual,
        xpAmount: xpAmount,
        description: description,
        metadata: metadata,
        earnedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _saveXpEvent(event);
      await _addXpToUser(userId, xpAmount);

      return Right(
        XpAwardResult(
          totalXpAwarded: xpAmount,
          events: [event],
          hasBonus: false,
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ============================================================================
  // QUERY XP METHODS
  // ============================================================================

  /// Get XP history for user
  Future<Either<Failure, List<XpEventModel>>> getXpHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final allEvents = await _completionsLocalDS.getXpEvents(userId);

      var filtered = allEvents.where((event) {
        if (startDate != null && event.earnedAt.isBefore(startDate)) {
          return false;
        }
        if (endDate != null && event.earnedAt.isAfter(endDate)) {
          return false;
        }
        return true;
      }).toList();

      if (limit != null && filtered.length > limit) {
        filtered = filtered.take(limit).toList();
      }

      return Right(filtered);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get total XP earned today
  Future<Either<Failure, int>> getTotalXpToday(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final result = await getXpHistory(userId: userId, startDate: startOfDay);

      return result.fold(
        (failure) => Left(failure),
        (events) => Right(events.fold<int>(0, (sum, e) => sum + e.xpAmount)),
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get total XP earned this week
  Future<Either<Failure, int>> getTotalXpThisWeek(String userId) async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDay = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      final result = await getXpHistory(
        userId: userId,
        startDate: startOfWeekDay,
      );

      return result.fold(
        (failure) => Left(failure),
        (events) => Right(events.fold<int>(0, (sum, e) => sum + e.xpAmount)),
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get total XP earned this month
  Future<Either<Failure, int>> getTotalXpThisMonth(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final result = await getXpHistory(
        userId: userId,
        startDate: startOfMonth,
      );

      return result.fold(
        (failure) => Left(failure),
        (events) => Right(events.fold<int>(0, (sum, e) => sum + e.xpAmount)),
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get XP breakdown by type (analytics)
  Future<Either<Failure, Map<XpEventType, int>>> getXpBreakdown({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final result = await getXpHistory(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return result.fold((failure) => Left(failure), (events) {
        final breakdown = <XpEventType, int>{};

        for (final event in events) {
          breakdown[event.type] = (breakdown[event.type] ?? 0) + event.xpAmount;
        }

        return Right(breakdown);
      });
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get XP statistics for user
  Future<Either<Failure, XpStatistics>> getXpStatistics(String userId) async {
    try {
      final user = await _userLocalDS.getCurrentUser();
      if (user == null) {
        return Left(NotFoundFailure('User not found'));
      }

      final todayXp = await getTotalXpToday(userId);
      final weekXp = await getTotalXpThisWeek(userId);
      final monthXp = await getTotalXpThisMonth(userId);
      final breakdown = await getXpBreakdown(userId: userId);

      return todayXp.fold(
        (failure) => Left(failure),
        (today) => weekXp.fold(
          (failure) => Left(failure),
          (week) => monthXp.fold(
            (failure) => Left(failure),
            (month) => breakdown.fold(
              (failure) => Left(failure),
              (breakdownMap) => Right(
                XpStatistics(
                  totalXp: user.totalXp,
                  currentLevel: user.currentLevel,
                  xpTodayToday,
                  xpThisWeek: week,
                  xpThisMonth: month,
                  xpRequiredForNextLevel: _calculateXpForNextLevel(
                    user.currentLevel,
                  ),
                  levelProgress: _calculateLevelProgress(
                    user.totalXp,
                    user.currentLevel,
                  ),
                  breakdown: breakdownMap,
                ),
              ),
            ),
          ),
        ),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ============================================================================
  // LEVEL CALCULATION METHODS
  // ============================================================================

  /// Calculate level from total XP
  /// Formula: Level = (totalXp / 100) + 1
  /// Reference: Product Documentation §3.2
  int calculateLevel(int totalXp) {
    return (totalXp / 100).floor() + 1;
  }

  /// Get XP required for next level
  /// Reference: 100 XP per level
  int getXpRequiredForNextLevel(int currentLevel) {
    return _calculateXpForNextLevel(currentLevel);
  }

  int _calculateXpForNextLevel(int currentLevel) {
    final nextLevelXp = currentLevel * 100;
    return nextLevelXp;
  }

  /// Get XP required to reach specific level
  int getXpRequiredForLevel(int targetLevel) {
    return (targetLevel - 1) * 100;
  }

  /// Get progress to next level (0.0 to 1.0)
  double getLevelProgress(int totalXp, int currentLevel) {
    return _calculateLevelProgress(totalXp, currentLevel);
  }

  double _calculateLevelProgress(int totalXp, int currentLevel) {
    final xpForCurrentLevel = (currentLevel - 1) * 100;
    final xpInCurrentLevel = totalXp - xpForCurrentLevel;
    return (xpInCurrentLevel / 100.0).clamp(0.0, 1.0);
  }

  /// Get XP remaining until next level
  Future<Either<Failure, int>> getXpRemainingForNextLevel(String userId) async {
    try {
      final user = await _userLocalDS.getCurrentUser();
      if (user == null) {
        return Left(NotFoundFailure('User not found'));
      }

      final xpForCurrentLevel = (user.currentLevel - 1) * 100;
      final xpInCurrentLevel = user.totalXp - xpForCurrentLevel;
      final remaining = 100 - xpInCurrentLevel;

      return Right(remaining);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message, code: e.code));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ============================================================================
  // LEADERBOARD METHODS (Post-MVP)
  // ============================================================================

  /// Get leaderboard for specific period
  /// Note: Requires backend aggregation for production
  Future<Either<Failure, List<LeaderboardEntry>>> getLeaderboard({
    required LeaderboardPeriod period,
    int limit = 100,
  }) async {
    try {
      // TODO: Implement with backend aggregation
      // This is a foundation for Post-MVP feature

      // For now, return empty list
      return const Right([]);

      // Production implementation would:
      // 1. Call Supabase RPC function to get top users
      // 2. Aggregate XP by period (daily, weekly, monthly, all-time)
      // 3. Rank users by XP
      // 4. Return paginated results
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Get user's leaderboard rank
  Future<Either<Failure, int?>> getLeaderboardRank({
    required String userId,
    required LeaderboardPeriod period,
  }) async {
    try {
      // TODO: Implement with backend query
      // Production: Use Supabase window functions to calculate rank

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Save XP event locally and remotely
  Future<void> _saveXpEvent(XpEventModel event) async {
    await _completionsLocalDS.saveXpEvent(event);

    try {
      await _completionsRemoteDS.createXpEvent(event);
    } catch (e) {
      // Will sync later
    }
  }

  /// Add XP to user total and recalculate level
  Future<void> _addXpToUser(String userId, int xpAmount) async {
    final user = await _userLocalDS.getCurrentUser();
    if (user == null) return;

    final newTotalXp = user.totalXp + xpAmount;
    final newLevel = calculateLevel(newTotalXp);

    await _userLocalDS.updateUserStats(
      totalXp: newTotalXp,
      currentLevel: newLevel,
    );

    try {
      await _userRemoteDS.addXp(userId, xpAmount);
    } catch (e) {
      // Will sync later
    }
  }

  /// Check if all daily habits are complete
  Future<bool> _checkAllDailyHabitsComplete(
    String userId,
    DateTime date,
  ) async {
    final habits = await _habitLocalDS.getActiveHabits(userId);
    final dailyHabits = habits.where((h) => h.shouldShowToday(date)).toList();

    if (dailyHabits.isEmpty) return false;

    for (final habit in dailyHabits) {
      final completions = await _completionsLocalDS.getCompletionsByDate(
        habit.id,
        date,
      );
      if (completions.isEmpty) return false;
    }

    return true;
  }

  /// Calculate current streak from completion dates
  int _calculateCurrentStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates =
        dates
            .map((d) {
              return DateTime(d.year, d.month, d.day);
            })
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // Check if streak is active (completed today or yesterday)
    if (!sortedDates.contains(todayDate) && !sortedDates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime expectedDate = sortedDates.first;

    for (final date in sortedDates) {
      if (date.isAtSameMomentAs(expectedDate)) {
        streak++;
        expectedDate = expectedDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  /// Check if login XP already awarded today
  Future<bool> _hasLoginXpToday(String userId) async {
    final events = await _completionsLocalDS.getXpEvents(userId);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return events.any(
      (event) =>
          event.type == XpEventType.dailyLogin &&
          event.earnedAt.isAfter(todayStart),
    );
  }

  /// Count rewarded ads watched today
  Future<int> _countRewardedAdsToday(String userId) async {
    final events = await _completionsLocalDS.getXpEvents(userId);
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    return events
        .where(
          (event) =>
              event.type == XpEventType.rewardedAd &&
              event.earnedAt.isAfter(todayStart),
        )
        .length;
  }

  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Determine bonus type from flags
  XpBonusType? _determineBonusType(
    bool allDailyComplete,
    XpEventModel? milestone,
  ) {
    if (milestone != null) {
      if (milestone.type == XpEventType.sevenDayMilestone) {
        return XpBonusType.sevenDayMilestone;
      } else if (milestone.type == XpEventType.thirtyDayMilestone) {
        return XpBonusType.thirtyDayMilestone;
      }
    }
    if (allDailyComplete) {
      return XpBonusType.allDailyComplete;
    }
    return null;
  }
}

// ============================================================================
// RESULT CLASSES
// ============================================================================

/// Result of XP award operation
class XpAwardResult {
  final int totalXpAwarded;
  final List<XpEventModel> events;
  final bool hasBonus;
  final XpBonusType? bonusType;
  final Map<String, dynamic>? metadata;

  const XpAwardResult({
    required this.totalXpAwarded,
    required this.events,
    required this.hasBonus,
    this.bonusType,
    this.metadata,
  });
}

/// XP statistics for analytics
class XpStatistics {
  final int totalXp;
  final int currentLevel;
  final int xpToday;
  final int xpThisWeek;
  final int xpThisMonth;
  final int xpRequiredForNextLevel;
  final double levelProgress;
  final Map<XpEventType, int> breakdown;

  const XpStatistics({
    required this.totalXp,
    required this.currentLevel,
    required this.xpToday,
    required this.xpThisWeek,
    required this.xpThisMonth,
    required this.xpRequiredForNextLevel,
    required this.levelProgress,
    required this.breakdown,
  });
}

/// Leaderboard entry (Post-MVP)
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final int xp;
  final int rank;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    required this.xp,
    required this.rank,
    this.isCurrentUser = false,
  });
}

// ============================================================================
// ENUMS
// ============================================================================

/// Leaderboard period
enum LeaderboardPeriod { daily, weekly, monthly, allTime }

/// XP bonus type
enum XpBonusType { allDailyComplete, sevenDayMilestone, thirtyDayMilestone }
