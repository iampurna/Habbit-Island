/// Core exceptions for Habit Island
/// These are throwable exceptions used in the data layer.
/// Convert to Failures in repositories for clean architecture.
library;

/// Base exception class
class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() =>
      'AppException: $message ${code != null ? '(Code: $code)' : ''}';
}

// ============================================================================
// INFRASTRUCTURE EXCEPTIONS (from your original code)
// ============================================================================

/// Server exception (API errors)
class ServerException extends AppException {
  const ServerException(super.message, {super.code});

  @override
  String toString() =>
      'ServerException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Cache exception (local storage errors)
class CacheException extends AppException {
  const CacheException(super.message, {super.code});

  @override
  String toString() =>
      'CacheException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Network exception (connectivity issues)
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});

  @override
  String toString() =>
      'NetworkException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  @override
  String toString() =>
      'AuthException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Validation exception (input validation errors)
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});

  @override
  String toString() =>
      'ValidationException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Database exception (Supabase/PostgreSQL errors)
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});

  @override
  String toString() =>
      'DatabaseException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Permission exception (access denied)
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});

  @override
  String toString() =>
      'PermissionException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Not found exception (resource not found)
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});

  @override
  String toString() =>
      'NotFoundException: $message ${code != null ? '(Code: $code)' : ''}';
}

/// Timeout exception (operation timeout)
class TimeoutException extends AppException {
  const TimeoutException(super.message, {super.code});

  @override
  String toString() =>
      'TimeoutException: $message ${code != null ? '(Code: $code)' : ''}';
}

// ============================================================================
// HABIT ISLAND BUSINESS LOGIC EXCEPTIONS
// Reference: Product Documentation v1.0, Technical Addendum v1.0
// ============================================================================

/// Habit limit exceeded (Product Documentation §3.1)
/// Thrown when user tries to create more habits than allowed
class HabitLimitException extends AppException {
  final int currentCount;
  final int maxAllowed;
  final bool isPremium;

  const HabitLimitException({
    required this.currentCount,
    required this.maxAllowed,
    required this.isPremium,
  }) : super(
         'Habit limit exceeded: $currentCount/$maxAllowed habits',
         code: 'HABIT_LIMIT_EXCEEDED',
       );

  @override
  String toString() =>
      'HabitLimitException: $currentCount/$maxAllowed habits (Premium: $isPremium)';
}

/// Zone capacity exceeded (Product Documentation §4.3)
/// Thrown when trying to add habit to a full zone
class ZoneCapacityException extends AppException {
  final String zoneName;
  final int maxHabits;

  const ZoneCapacityException({required this.zoneName, required this.maxHabits})
    : super(
        'Zone capacity exceeded: $zoneName is full ($maxHabits habits)',
        code: 'ZONE_CAPACITY_EXCEEDED',
      );

  @override
  String toString() =>
      'ZoneCapacityException: $zoneName full ($maxHabits habits)';
}

/// Premium feature required (Product Documentation §6)
/// Thrown when free user tries to access premium feature
class PremiumRequiredException extends AppException {
  final String featureName;

  const PremiumRequiredException(this.featureName)
    : super(
        'Premium subscription required for: $featureName',
        code: 'PREMIUM_REQUIRED',
      );

  @override
  String toString() =>
      'PremiumRequiredException: $featureName requires Premium';
}

/// Zone locked (Product Documentation §4.3)
/// Thrown when user tries to access zone without sufficient XP
class ZoneLockedException extends AppException {
  final String zoneName;
  final int requiredXp;
  final int currentXp;

  const ZoneLockedException({
    required this.zoneName,
    required this.requiredXp,
    required this.currentXp,
  }) : super(
         'Zone locked: $zoneName requires $requiredXp XP (current: $currentXp)',
         code: 'ZONE_LOCKED',
       );

  @override
  String toString() =>
      'ZoneLockedException: $zoneName needs ${requiredXp - currentXp} more XP';
}

/// Habit already completed today
/// Thrown when trying to complete the same habit twice in one day
class AlreadyCompletedException extends AppException {
  final String habitId;
  final DateTime completionDate;

  const AlreadyCompletedException({
    required this.habitId,
    required this.completionDate,
  }) : super('Habit already completed today', code: 'ALREADY_COMPLETED');

  @override
  String toString() =>
      'AlreadyCompletedException: Habit $habitId already completed on ${completionDate.toIso8601String()}';
}

/// Duplicate habit name
/// Thrown when creating habit with existing name
class DuplicateHabitException extends AppException {
  final String habitName;

  const DuplicateHabitException(this.habitName)
    : super(
        'Habit with name "$habitName" already exists',
        code: 'DUPLICATE_HABIT',
      );

  @override
  String toString() => 'DuplicateHabitException: "$habitName" already exists';
}

/// Sync conflict (Technical Addendum §2.4)
/// Thrown when local and server data conflict
class SyncConflictException extends AppException {
  final String resourceType;
  final String resourceId;
  final DateTime localTimestamp;
  final DateTime serverTimestamp;

  const SyncConflictException({
    required this.resourceType,
    required this.resourceId,
    required this.localTimestamp,
    required this.serverTimestamp,
  }) : super(
         'Sync conflict for $resourceType:$resourceId',
         code: 'SYNC_CONFLICT',
       );

  @override
  String toString() =>
      'SyncConflictException: $resourceType:$resourceId (local: $localTimestamp, server: $serverTimestamp)';
}

/// Offline queue full
/// Thrown when offline queue exceeds maximum size
class OfflineQueueFullException extends AppException {
  final int currentSize;
  final int maxSize;

  const OfflineQueueFullException({
    required this.currentSize,
    required this.maxSize,
  }) : super(
         'Offline queue full: $currentSize/$maxSize operations',
         code: 'QUEUE_FULL',
       );

  @override
  String toString() =>
      'OfflineQueueFullException: $currentSize/$maxSize operations queued';
}

/// Streak shield not available (Product Documentation §6.2)
/// Thrown when user has no streak shields remaining
class StreakShieldUnavailableException extends AppException {
  final int shieldsRemaining;
  final bool isPremium;

  const StreakShieldUnavailableException({
    required this.shieldsRemaining,
    required this.isPremium,
  }) : super(
         'No streak shields available ($shieldsRemaining remaining)',
         code: 'NO_STREAK_SHIELDS',
       );

  @override
  String toString() =>
      'StreakShieldUnavailableException: $shieldsRemaining shields left (Premium: $isPremium)';
}

/// Vacation mode unavailable (Product Documentation §6.2)
/// Thrown when user has no vacation days remaining
class VacationModeUnavailableException extends AppException {
  final int daysRemaining;

  const VacationModeUnavailableException(this.daysRemaining)
    : super(
        'No vacation days available ($daysRemaining remaining)',
        code: 'NO_VACATION_DAYS',
      );

  @override
  String toString() =>
      'VacationModeUnavailableException: $daysRemaining days remaining';
}

/// Ad limit reached (Product Documentation §6.1)
/// Thrown when daily ad limit is exceeded
class AdLimitException extends AppException {
  final int adsWatchedToday;
  final int maxAdsPerDay;

  const AdLimitException({
    required this.adsWatchedToday,
    required this.maxAdsPerDay,
  }) : super(
         'Daily ad limit reached: $adsWatchedToday/$maxAdsPerDay',
         code: 'AD_LIMIT_REACHED',
       );

  @override
  String toString() =>
      'AdLimitException: $adsWatchedToday/$maxAdsPerDay ads watched today';
}

/// XP already claimed
/// Thrown when trying to claim the same XP reward twice
class XpAlreadyClaimedException extends AppException {
  final String rewardType;
  final DateTime claimedAt;

  const XpAlreadyClaimedException({
    required this.rewardType,
    required this.claimedAt,
  }) : super('XP already claimed for $rewardType', code: 'XP_ALREADY_CLAIMED');

  @override
  String toString() =>
      'XpAlreadyClaimedException: $rewardType claimed at ${claimedAt.toIso8601String()}';
}

/// Invalid frequency
/// Thrown when habit frequency is invalid
class InvalidFrequencyException extends AppException {
  final String reason;

  const InvalidFrequencyException(this.reason)
    : super('Invalid habit frequency: $reason', code: 'INVALID_FREQUENCY');

  @override
  String toString() => 'InvalidFrequencyException: $reason';
}

/// Storage quota exceeded
/// Thrown when device storage is full
class StorageQuotaException extends AppException {
  final int currentSizeBytes;
  final int limitBytes;

  const StorageQuotaException({
    required this.currentSizeBytes,
    required this.limitBytes,
  }) : super(
         'Storage quota exceeded: ${currentSizeBytes ~/ 1048576}MB / ${limitBytes ~/ 1048576}MB',
         code: 'STORAGE_QUOTA_EXCEEDED',
       );

  @override
  String toString() =>
      'StorageQuotaException: ${currentSizeBytes ~/ 1048576}MB / ${limitBytes ~/ 1048576}MB used';
}
