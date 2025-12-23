import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/habit_model.dart';
import '../models/xp_event_model.dart';
import '../models/premium_entitlement_model.dart';

/// Analytics Service
/// Tracks user behavior and app events using Firebase Analytics
/// Reference: Technical Specification Addendum §6 (Analytics & Tracking)

class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseAnalyticsObserver _observer;

  AnalyticsService()
    : _analytics = FirebaseAnalytics.instance,
      _observer = FirebaseAnalyticsObserver(
        analytics: FirebaseAnalytics.instance,
      );

  /// Get analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer => _observer;

  // ============================================================================
  // USER PROPERTIES
  // ============================================================================

  /// Set user ID (call after authentication)
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Set user properties
  Future<void> setUserProperties({
    required bool isPremium,
    required PremiumTier premiumTier,
    required int totalHabits,
    required int activeHabits,
    required int currentLevel,
    required int totalXp,
    required int currentStreak,
  }) async {
    await _analytics.setUserProperty(
      name: 'is_premium',
      value: isPremium.toString(),
    );
    await _analytics.setUserProperty(
      name: 'premium_tier',
      value: premiumTier.name,
    );
    await _analytics.setUserProperty(
      name: 'total_habits',
      value: totalHabits.toString(),
    );
    await _analytics.setUserProperty(
      name: 'active_habits',
      value: activeHabits.toString(),
    );
    await _analytics.setUserProperty(
      name: 'user_level',
      value: currentLevel.toString(),
    );
    await _analytics.setUserProperty(
      name: 'total_xp',
      value: totalXp.toString(),
    );
    await _analytics.setUserProperty(
      name: 'current_streak',
      value: currentStreak.toString(),
    );
  }

  // ============================================================================
  // AUTHENTICATION EVENTS
  // ============================================================================

  /// Track sign up
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Track login
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Track logout
  Future<void> logLogout() async {
    await _analytics.logEvent(name: 'logout');
  }

  // ============================================================================
  // HABIT EVENTS
  // ============================================================================

  /// Track habit creation
  Future<void> logHabitCreated({
    required String habitId,
    required HabitCategory category,
    required HabitFrequency frequency,
    required String zoneId,
  }) async {
    await _analytics.logEvent(
      name: 'habit_created',
      parameters: {
        'habit_id': habitId,
        'category': category.name,
        'frequency': frequency.name,
        'zone_id': zoneId,
      },
    );
  }

  /// Track habit completion
  Future<void> logHabitCompleted({
    required String habitId,
    required HabitCategory category,
    required int currentStreak,
    required int xpEarned,
    required bool hadBonus,
  }) async {
    await _analytics.logEvent(
      name: 'habit_completed',
      parameters: {
        'habit_id': habitId,
        'category': category.name,
        'current_streak': currentStreak,
        'xp_earned': xpEarned,
        'had_bonus': hadBonus,
      },
    );
  }

  /// Track habit deleted
  Future<void> logHabitDeleted({
    required String habitId,
    required int totalCompletions,
    required int longestStreak,
  }) async {
    await _analytics.logEvent(
      name: 'habit_deleted',
      parameters: {
        'habit_id': habitId,
        'total_completions': totalCompletions,
        'longest_streak': longestStreak,
      },
    );
  }

  /// Track all daily habits completed (bonus trigger)
  Future<void> logAllDailyHabitsCompleted({
    required int habitCount,
    required int bonusXp,
  }) async {
    await _analytics.logEvent(
      name: 'all_daily_completed',
      parameters: {'habit_count': habitCount, 'bonus_xp': bonusXp},
    );
  }

  // ============================================================================
  // STREAK EVENTS
  // ============================================================================

  /// Track streak milestone
  Future<void> logStreakMilestone({
    required String habitId,
    required int streakDays,
    required int xpEarned,
  }) async {
    await _analytics.logEvent(
      name: 'streak_milestone',
      parameters: {
        'habit_id': habitId,
        'streak_days': streakDays,
        'xp_earned': xpEarned,
        'milestone_type': streakDays == 7 ? 'seven_day' : 'thirty_day',
      },
    );
  }

  /// Track streak broken
  Future<void> logStreakBroken({
    required String habitId,
    required int brokenStreak,
    required bool shieldUsed,
  }) async {
    await _analytics.logEvent(
      name: 'streak_broken',
      parameters: {
        'habit_id': habitId,
        'broken_streak': brokenStreak,
        'shield_used': shieldUsed,
      },
    );
  }

  /// Track streak shield used
  Future<void> logStreakShieldUsed({
    required String habitId,
    required int savedStreak,
    required int shieldsRemaining,
  }) async {
    await _analytics.logEvent(
      name: 'streak_shield_used',
      parameters: {
        'habit_id': habitId,
        'saved_streak': savedStreak,
        'shields_remaining': shieldsRemaining,
      },
    );
  }

  // ============================================================================
  // XP & LEVEL EVENTS
  // ============================================================================

  /// Track XP earned
  Future<void> logXpEarned({
    required XpEventType type,
    required int xpAmount,
    String? habitId,
  }) async {
    await _analytics.logEvent(
      name: 'xp_earned',
      parameters: {
        'xp_type': type.name,
        'xp_amount': xpAmount,
        if (habitId != null) 'habit_id': habitId,
      },
    );
  }

  /// Track level up
  Future<void> logLevelUp({
    required int oldLevel,
    required int newLevel,
    required int totalXp,
  }) async {
    await _analytics.logEvent(
      name: 'level_up',
      parameters: {
        'old_level': oldLevel,
        'new_level': newLevel,
        'total_xp': totalXp,
      },
    );
  }

  // ============================================================================
  // PREMIUM EVENTS
  // ============================================================================

  /// Track premium purchase viewed
  Future<void> logPremiumViewed({required String source}) async {
    await _analytics.logEvent(
      name: 'premium_viewed',
      parameters: {'source': source},
    );
  }

  /// Track premium purchase started
  Future<void> logPurchaseStarted({
    required String productId,
    required PremiumTier tier,
    required double price,
    required String currency,
  }) async {
    await _analytics.logEvent(
      name: 'begin_checkout',
      parameters: {
        'items': [
          {'item_id': productId, 'item_name': tier.name, 'price': price},
        ],
        'currency': currency,
        'value': price,
      },
    );
  }

  /// Track premium purchase completed
  Future<void> logPurchaseCompleted({
    required String productId,
    required PremiumTier tier,
    required double price,
    required String currency,
    required String transactionId,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      transactionId: transactionId,
      parameters: {
        'items': [
          {'item_id': productId, 'item_name': tier.name, 'price': price},
        ],
      },
    );

    // Also log as ecommerce_purchase
    await _analytics.logEvent(
      name: 'ecommerce_purchase',
      parameters: {
        'transaction_id': transactionId,
        'value': price,
        'currency': currency,
        'tier': tier.name,
      },
    );
  }

  /// Track premium cancelled
  Future<void> logPremiumCancelled({
    required PremiumTier tier,
    required int daysUsed,
  }) async {
    await _analytics.logEvent(
      name: 'premium_cancelled',
      parameters: {'tier': tier.name, 'days_used': daysUsed},
    );
  }

  // ============================================================================
  // AD EVENTS
  // ============================================================================

  /// Track ad impression
  Future<void> logAdImpression({
    required String adType,
    required String adId,
  }) async {
    await _analytics.logAdImpression(
      adPlatform: 'admob',
      adFormat: adType,
      adSource: adId,
    );
  }

  /// Track rewarded ad watched
  Future<void> logRewardedAdWatched({
    required String adId,
    required int xpEarned,
    required int adsWatchedToday,
  }) async {
    await _analytics.logEvent(
      name: 'rewarded_ad_watched',
      parameters: {
        'ad_id': adId,
        'xp_earned': xpEarned,
        'ads_watched_today': adsWatchedToday,
      },
    );
  }

  /// Track ad clicked
  Future<void> logAdClicked({
    required String adType,
    required String adId,
  }) async {
    await _analytics.logEvent(
      name: 'ad_click',
      parameters: {'ad_type': adType, 'ad_id': adId},
    );
  }

  // ============================================================================
  // ENGAGEMENT EVENTS
  // ============================================================================

  /// Track app open
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  /// Track screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  /// Track tutorial begin
  Future<void> logTutorialBegin() async {
    await _analytics.logTutorialBegin();
  }

  /// Track tutorial complete
  Future<void> logTutorialComplete() async {
    await _analytics.logTutorialComplete();
  }

  /// Track feature used
  Future<void> logFeatureUsed({
    required String featureName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature_name': featureName, ...?parameters},
    );
  }

  // ============================================================================
  // RETENTION EVENTS
  // ============================================================================

  /// Track daily login
  Future<void> logDailyLogin({required int consecutiveDays}) async {
    await _analytics.logEvent(
      name: 'daily_login',
      parameters: {'consecutive_days': consecutiveDays},
    );
  }

  /// Track session start
  Future<void> logSessionStart() async {
    await _analytics.logEvent(name: 'session_start');
  }

  /// Track session end
  Future<void> logSessionEnd({required int durationSeconds}) async {
    await _analytics.logEvent(
      name: 'session_end',
      parameters: {'duration_seconds': durationSeconds},
    );
  }

  // ============================================================================
  // ERROR EVENTS
  // ============================================================================

  /// Track error
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (stackTrace != null) 'stack_trace': stackTrace,
      },
    );
  }

  /// Track crash
  Future<void> logCrash({
    required String crashType,
    required String crashMessage,
  }) async {
    await _analytics.logEvent(
      name: 'app_crash',
      parameters: {'crash_type': crashType, 'crash_message': crashMessage},
    );
  }

  // ============================================================================
  // CUSTOM EVENTS
  // ============================================================================

  /// Log custom event
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Enable/disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    await _analytics.setAnalyticsCollectionEnabled(enabled);
  }

  /// Reset analytics data
  Future<void> resetAnalyticsData() async {
    await _analytics.resetAnalyticsData();
  }
}
