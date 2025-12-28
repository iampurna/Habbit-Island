import 'package:equatable/equatable.dart';

/// Core failures for Habit Island
/// These are non-throwable failures returned via Either Failure or Success.
/// Used in the domain/repository layer for clean architecture.

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];

  /// Convert failure to user-friendly message
  String toUserMessage() => message;
}

// ============================================================================
// INFRASTRUCTURE FAILURES (from your original code)
// ============================================================================

/// Server failure (API errors)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});

  @override
  String toUserMessage() => 'Server error. Please try again later.';
}

/// Cache failure (local storage errors)
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});

  @override
  String toUserMessage() => 'Failed to load data. Please restart the app.';
}

/// Network failure (connectivity issues)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});

  @override
  String toUserMessage() =>
      'No internet connection. Please check your network.';
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  @override
  String toUserMessage() => 'Authentication failed. Please sign in again.';
}

/// Validation failure (input validation errors)
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});

  @override
  String toUserMessage() => message; // Keep original validation message
}

/// Database failure (Supabase/PostgreSQL errors)
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});

  @override
  String toUserMessage() => 'Database error. Please try again.';
}

/// Permission failure (access denied)
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});

  @override
  String toUserMessage() =>
      'Permission denied. Please check your access rights.';
}

/// Not found failure (resource not found)
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});

  @override
  String toUserMessage() => 'Resource not found. It may have been deleted.';
}

/// Timeout failure (operation timeout)
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.code});

  @override
  String toUserMessage() =>
      'Request timed out. Please check your connection and try again.';
}

/// Unknown failure (unexpected errors)
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.code});

  @override
  String toUserMessage() => 'An unexpected error occurred. Please try again.';
}

// ============================================================================
// HABIT ISLAND BUSINESS LOGIC FAILURES
// Reference: Product Documentation v1.0, Technical Addendum v1.0
// ============================================================================

/// Habit limit exceeded (Product Documentation §3.1)
/// Returned when user tries to create more habits than allowed
class HabitLimitFailure extends Failure {
  final int currentCount;
  final int maxAllowed;
  final bool isPremium;

  const HabitLimitFailure({
    required this.currentCount,
    required this.maxAllowed,
    required this.isPremium,
  }) : super(
         'Habit limit exceeded: $currentCount/$maxAllowed habits',
         code: 'HABIT_LIMIT_EXCEEDED',
       );

  @override
  List<Object?> get props => [
    message,
    code,
    currentCount,
    maxAllowed,
    isPremium,
  ];

  @override
  String toUserMessage() {
    if (isPremium) {
      return 'Maximum habit limit ($maxAllowed) reached.';
    }
    return 'Free tier limit ($maxAllowed habits) reached. Upgrade to Premium for unlimited habits!';
  }
}

/// Zone capacity exceeded (Product Documentation §4.3)
/// Returned when trying to add habit to a full zone
class ZoneCapacityFailure extends Failure {
  final String zoneName;
  final int maxHabits;

  const ZoneCapacityFailure({required this.zoneName, required this.maxHabits})
    : super(
        'Zone capacity exceeded: $zoneName is full ($maxHabits habits)',
        code: 'ZONE_CAPACITY_EXCEEDED',
      );

  @override
  List<Object?> get props => [message, code, zoneName, maxHabits];

  @override
  String toUserMessage() =>
      '$zoneName is full ($maxHabits habits). Unlock more zones by earning XP!';
}

/// Premium feature required (Product Documentation §6)
/// Returned when free user tries to access premium feature
class PremiumRequiredFailure extends Failure {
  final String featureName;
  final double monthlyPrice;

  const PremiumRequiredFailure({
    required this.featureName,
    this.monthlyPrice = 4.99,
  }) : super(
         'Premium subscription required for: $featureName',
         code: 'PREMIUM_REQUIRED',
       );

  @override
  List<Object?> get props => [message, code, featureName, monthlyPrice];

  @override
  String toUserMessage() =>
      '$featureName is a Premium feature. Upgrade now for \$$monthlyPrice/month!';
}

/// Zone locked (Product Documentation §4.3)
/// Returned when user tries to access zone without sufficient XP
class ZoneLockedFailure extends Failure {
  final String zoneName;
  final int requiredXp;
  final int currentXp;

  const ZoneLockedFailure({
    required this.zoneName,
    required this.requiredXp,
    required this.currentXp,
  }) : super(
         'Zone locked: $zoneName requires $requiredXp XP (current: $currentXp)',
         code: 'ZONE_LOCKED',
       );

  @override
  List<Object?> get props => [message, code, zoneName, requiredXp, currentXp];

  @override
  String toUserMessage() {
    final xpNeeded = requiredXp - currentXp;
    return '$zoneName requires $requiredXp XP. You need $xpNeeded more XP to unlock!';
  }
}

/// Habit already completed today
/// Returned when trying to complete the same habit twice in one day
class AlreadyCompletedFailure extends Failure {
  final String habitName;
  final DateTime completionDate;

  const AlreadyCompletedFailure({
    required this.habitName,
    required this.completionDate,
  }) : super('Habit already completed today', code: 'ALREADY_COMPLETED');

  @override
  List<Object?> get props => [message, code, habitName, completionDate];

  @override
  String toUserMessage() =>
      'You\'ve already completed "$habitName" today. Great job! 🎉';
}

/// Duplicate habit name
/// Returned when creating habit with existing name
class DuplicateHabitFailure extends Failure {
  final String habitName;

  const DuplicateHabitFailure(this.habitName)
    : super(
        'Habit with name "$habitName" already exists',
        code: 'DUPLICATE_HABIT',
      );

  @override
  List<Object?> get props => [message, code, habitName];

  @override
  String toUserMessage() =>
      'You already have a habit named "$habitName". Please choose a different name.';
}

/// Sync conflict (Technical Addendum §2.4)
/// Returned when local and server data conflict
class SyncConflictFailure extends Failure {
  final String resourceType;
  final String resourceId;
  final DateTime localTimestamp;
  final DateTime serverTimestamp;

  const SyncConflictFailure({
    required this.resourceType,
    required this.resourceId,
    required this.localTimestamp,
    required this.serverTimestamp,
  }) : super(
         'Sync conflict for $resourceType:$resourceId',
         code: 'SYNC_CONFLICT',
       );

  @override
  List<Object?> get props => [
    message,
    code,
    resourceType,
    resourceId,
    localTimestamp,
    serverTimestamp,
  ];

  @override
  String toUserMessage() =>
      'Your data conflicts with the server. Using most recent version.';
}

/// Offline queue full
/// Returned when offline queue exceeds maximum size
class OfflineQueueFullFailure extends Failure {
  final int currentSize;
  final int maxSize;

  const OfflineQueueFullFailure({
    required this.currentSize,
    required this.maxSize,
  }) : super(
         'Offline queue full: $currentSize/$maxSize operations',
         code: 'QUEUE_FULL',
       );

  @override
  List<Object?> get props => [message, code, currentSize, maxSize];

  @override
  String toUserMessage() =>
      'Too many pending operations. Please connect to sync your data.';
}

/// Streak shield not available (Product Documentation §6.2)
/// Returned when user has no streak shields remaining
class StreakShieldUnavailableFailure extends Failure {
  final int shieldsRemaining;
  final bool isPremium;

  const StreakShieldUnavailableFailure(
    String s, {
    required this.shieldsRemaining,
    required this.isPremium,
  }) : super(
         'No streak shields available ($shieldsRemaining remaining)',
         code: 'NO_STREAK_SHIELDS',
       );

  @override
  List<Object?> get props => [message, code, shieldsRemaining, isPremium];

  @override
  String toUserMessage() {
    if (shieldsRemaining > 0) {
      return 'You have $shieldsRemaining streak shield${shieldsRemaining > 1 ? 's' : ''} left this month.';
    }
    if (isPremium) {
      return 'No streak shields available. You get 3 per month with Premium!';
    }
    return 'Streak shields are a Premium feature. Upgrade now!';
  }
}

/// Vacation mode unavailable (Product Documentation §6.2)
/// Returned when user has no vacation days remaining
class VacationModeUnavailableFailure extends Failure {
  final int daysRemaining;

  const VacationModeUnavailableFailure(this.daysRemaining)
    : super(
        'No vacation days available ($daysRemaining remaining)',
        code: 'NO_VACATION_DAYS',
      );

  @override
  List<Object?> get props => [message, code, daysRemaining];

  @override
  String toUserMessage() {
    if (daysRemaining > 0) {
      return 'You have $daysRemaining vacation days remaining this year.';
    }
    return 'No vacation days available. Premium users get 30 days per year!';
  }
}

/// Ad limit reached (Product Documentation §6.1)
/// Returned when daily ad limit is exceeded
class AdLimitFailure extends Failure {
  final int adsWatchedToday;
  final int maxAdsPerDay;

  const AdLimitFailure({
    required this.adsWatchedToday,
    required this.maxAdsPerDay,
  }) : super(
         'Daily ad limit reached: $adsWatchedToday/$maxAdsPerDay',
         code: 'AD_LIMIT_REACHED',
       );

  @override
  List<Object?> get props => [message, code, adsWatchedToday, maxAdsPerDay];

  @override
  String toUserMessage() =>
      'You\'ve reached the daily limit of $maxAdsPerDay ads. Come back tomorrow!';
}

/// XP already claimed
/// Returned when trying to claim the same XP reward twice
class XpAlreadyClaimedFailure extends Failure {
  final String rewardType;
  final DateTime claimedAt;

  const XpAlreadyClaimedFailure(
    String s, {
    required this.rewardType,
    required this.claimedAt,
  }) : super('XP already claimed for $rewardType', code: 'XP_ALREADY_CLAIMED');

  @override
  List<Object?> get props => [message, code, rewardType, claimedAt];

  @override
  String toUserMessage() =>
      'You\'ve already claimed this $rewardType reward today.';
}

/// Invalid frequency
/// Returned when habit frequency is invalid
class InvalidFrequencyFailure extends Failure {
  final String reason;

  const InvalidFrequencyFailure(this.reason)
    : super('Invalid habit frequency: $reason', code: 'INVALID_FREQUENCY');

  @override
  List<Object?> get props => [message, code, reason];

  @override
  String toUserMessage() => reason;
}

/// Storage quota exceeded
/// Returned when device storage is full
class StorageQuotaFailure extends Failure {
  final int currentSizeBytes;
  final int limitBytes;

  const StorageQuotaFailure({
    required this.currentSizeBytes,
    required this.limitBytes,
  }) : super(
         'Storage quota exceeded: ${currentSizeBytes ~/ 1048576}MB / ${limitBytes ~/ 1048576}MB',
         code: 'STORAGE_QUOTA_EXCEEDED',
       );

  @override
  List<Object?> get props => [message, code, currentSizeBytes, limitBytes];

  @override
  String toUserMessage() =>
      'Device storage is full. Please free up space and try again.';
}

/// Habit not found
/// Returned when habit doesn't exist
class HabitNotFoundFailure extends Failure {
  final String habitId;

  const HabitNotFoundFailure(this.habitId)
    : super('Habit not found: $habitId', code: 'HABIT_NOT_FOUND');

  @override
  List<Object?> get props => [message, code, habitId];

  @override
  String toUserMessage() => 'Habit not found. It may have been deleted.';
}

/// Cannot delete last habit
/// Returned when trying to delete the only remaining habit
class CannotDeleteLastHabitFailure extends Failure {
  const CannotDeleteLastHabitFailure()
    : super('Cannot delete last habit', code: 'CANNOT_DELETE_LAST');

  @override
  String toUserMessage() =>
      'You must have at least one active habit. Create a new one before deleting this.';
}

/// Notification limit reached (Technical Addendum §7.1)
/// Returned when daily notification limit is exceeded
class NotificationLimitFailure extends Failure {
  final int sentToday;
  final int maxPerDay;

  const NotificationLimitFailure({
    required this.sentToday,
    required this.maxPerDay,
  }) : super(
         'Notification limit reached: $sentToday/$maxPerDay',
         code: 'NOTIFICATION_LIMIT',
       );

  @override
  List<Object?> get props => [message, code, sentToday, maxPerDay];

  @override
  String toUserMessage() =>
      'Daily notification limit ($maxPerDay) reached to avoid spam.';
}
