import 'package:equatable/equatable.dart';

/// XP Event Model (Data Layer)
/// Reference: Product Documentation v1.0 §3.2 (XP System)
///
/// Tracks individual XP earning events for history and analytics.
/// Used to calculate total XP and level progression.

class XpEventModel extends Equatable {
  final String id;
  final String userId;
  final XpEventType type;
  final int xpAmount;
  final String? habitId; // If XP is from habit completion
  final String? relatedId; // Generic ID for related entity
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime earnedAt;
  final DateTime createdAt;

  const XpEventModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.xpAmount,
    this.habitId,
    this.relatedId,
    this.description,
    this.metadata,
    required this.earnedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    xpAmount,
    habitId,
    relatedId,
    description,
    metadata,
    earnedAt,
    createdAt,
  ];

  // ============================================================================
  // JSON SERIALIZATION (for Supabase & Hive)
  // ============================================================================

  factory XpEventModel.fromJson(Map<String, dynamic> json) {
    return XpEventModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: XpEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => XpEventType.habitCompletion,
      ),
      xpAmount: json['xp_amount'] as int,
      habitId: json['habit_id'] as String?,
      relatedId: json['related_id'] as String?,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'xp_amount': xpAmount,
      'habit_id': habitId,
      'related_id': relatedId,
      'description': description,
      'metadata': metadata,
      'earned_at': earnedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  XpEventModel copyWith({
    String? id,
    String? userId,
    XpEventType? type,
    int? xpAmount,
    String? habitId,
    String? relatedId,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? earnedAt,
    DateTime? createdAt,
  }) {
    return XpEventModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      xpAmount: xpAmount ?? this.xpAmount,
      habitId: habitId ?? this.habitId,
      relatedId: relatedId ?? this.relatedId,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      earnedAt: earnedAt ?? this.earnedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if event is from today
  bool get isToday {
    final now = DateTime.now();
    return earnedAt.year == now.year &&
        earnedAt.month == now.month &&
        earnedAt.day == now.day;
  }

  /// Check if event is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return earnedAt.isAfter(weekStart);
  }

  /// Check if event is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return earnedAt.year == now.year && earnedAt.month == now.month;
  }

  /// Get formatted XP amount
  String get formattedXp => '+$xpAmount XP';
}

// ============================================================================
// ENUMS
// ============================================================================

/// XP Event Type (Product Documentation §3.2)
enum XpEventType {
  habitCompletion, // +10 XP per habit
  allDailyComplete, // +50 XP bonus for completing all daily habits
  sevenDayMilestone, // +100 XP for 7-day streak
  thirtyDayMilestone, // +500 XP for 30-day streak
  dailyLogin, // +5 XP for logging in
  rewardedAd, // +50 XP for watching ad
  referralBonus, // Future: +100 XP for successful referral
  achievementUnlock, // Future: Variable XP for achievements
  zoneUnlock, // Future: Variable XP for unlocking zones
  manual, // Manual XP adjustment (admin/promo)
}

// ============================================================================
// EXTENSIONS
// ============================================================================

extension XpEventTypeExtension on XpEventType {
  String get displayName {
    switch (this) {
      case XpEventType.habitCompletion:
        return 'Habit Completed';
      case XpEventType.allDailyComplete:
        return 'All Daily Habits';
      case XpEventType.sevenDayMilestone:
        return '7-Day Streak';
      case XpEventType.thirtyDayMilestone:
        return '30-Day Streak';
      case XpEventType.dailyLogin:
        return 'Daily Login';
      case XpEventType.rewardedAd:
        return 'Watched Ad';
      case XpEventType.referralBonus:
        return 'Referral Bonus';
      case XpEventType.achievementUnlock:
        return 'Achievement';
      case XpEventType.zoneUnlock:
        return 'Zone Unlocked';
      case XpEventType.manual:
        return 'Bonus XP';
    }
  }

  int get defaultXp {
    switch (this) {
      case XpEventType.habitCompletion:
        return 10;
      case XpEventType.allDailyComplete:
        return 50;
      case XpEventType.sevenDayMilestone:
        return 100;
      case XpEventType.thirtyDayMilestone:
        return 500;
      case XpEventType.dailyLogin:
        return 5;
      case XpEventType.rewardedAd:
        return 50;
      case XpEventType.referralBonus:
        return 100;
      case XpEventType.achievementUnlock:
        return 0; // Variable
      case XpEventType.zoneUnlock:
        return 0; // Variable
      case XpEventType.manual:
        return 0; // Variable
    }
  }

  String get emoji {
    switch (this) {
      case XpEventType.habitCompletion:
        return '✅';
      case XpEventType.allDailyComplete:
        return '🎉';
      case XpEventType.sevenDayMilestone:
        return '🔥';
      case XpEventType.thirtyDayMilestone:
        return '🏆';
      case XpEventType.dailyLogin:
        return '👋';
      case XpEventType.rewardedAd:
        return '📺';
      case XpEventType.referralBonus:
        return '🤝';
      case XpEventType.achievementUnlock:
        return '🏅';
      case XpEventType.zoneUnlock:
        return '🗺️';
      case XpEventType.manual:
        return '⭐';
    }
  }

  String get description {
    switch (this) {
      case XpEventType.habitCompletion:
        return 'Completed a habit';
      case XpEventType.allDailyComplete:
        return 'Completed all daily habits!';
      case XpEventType.sevenDayMilestone:
        return 'Reached 7-day streak milestone!';
      case XpEventType.thirtyDayMilestone:
        return 'Reached 30-day streak milestone!';
      case XpEventType.dailyLogin:
        return 'Logged in today';
      case XpEventType.rewardedAd:
        return 'Watched a rewarded ad';
      case XpEventType.referralBonus:
        return 'Referred a friend';
      case XpEventType.achievementUnlock:
        return 'Unlocked an achievement';
      case XpEventType.zoneUnlock:
        return 'Unlocked a new zone';
      case XpEventType.manual:
        return 'Bonus XP awarded';
    }
  }

  bool get isMilestone =>
      this == XpEventType.sevenDayMilestone ||
      this == XpEventType.thirtyDayMilestone;

  bool get isBonus =>
      this == XpEventType.allDailyComplete ||
      this == XpEventType.referralBonus ||
      this == XpEventType.manual;
}

// ============================================================================
// FACTORY METHODS
// ============================================================================

extension XpEventModelFactory on XpEventModel {
  /// Create XP event for habit completion (+10 XP)
  static XpEventModel habitCompletion({
    required String id,
    required String userId,
    required String habitId,
    DateTime? earnedAt,
  }) {
    return XpEventModel(
      id: id,
      userId: userId,
      type: XpEventType.habitCompletion,
      xpAmount: 10,
      habitId: habitId,
      description: 'Completed a habit',
      earnedAt: earnedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create XP event for all daily habits complete (+50 XP)
  static XpEventModel allDailyComplete({
    required String id,
    required String userId,
    required int habitCount,
    DateTime? earnedAt,
  }) {
    return XpEventModel(
      id: id,
      userId: userId,
      type: XpEventType.allDailyComplete,
      xpAmount: 50,
      description: 'Completed all $habitCount daily habits',
      metadata: {'habit_count': habitCount},
      earnedAt: earnedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create XP event for streak milestone (+100 or +500 XP)
  static XpEventModel streakMilestone({
    required String id,
    required String userId,
    required String habitId,
    required int streakDays,
    DateTime? earnedAt,
  }) {
    final is7Day = streakDays == 7;
    final is30Day = streakDays == 30;

    return XpEventModel(
      id: id,
      userId: userId,
      type: is7Day
          ? XpEventType.sevenDayMilestone
          : XpEventType.thirtyDayMilestone,
      xpAmount: is7Day ? 100 : 500,
      habitId: habitId,
      description: 'Reached $streakDays-day streak milestone',
      metadata: {'streak_days': streakDays},
      earnedAt: earnedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create XP event for daily login (+5 XP)
  static XpEventModel dailyLogin({
    required String id,
    required String userId,
    DateTime? earnedAt,
  }) {
    return XpEventModel(
      id: id,
      userId: userId,
      type: XpEventType.dailyLogin,
      xpAmount: 5,
      description: 'Daily login bonus',
      earnedAt: earnedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create XP event for watching rewarded ad (+50 XP)
  static XpEventModel rewardedAd({
    required String id,
    required String userId,
    String? adId,
    DateTime? earnedAt,
  }) {
    return XpEventModel(
      id: id,
      userId: userId,
      type: XpEventType.rewardedAd,
      xpAmount: 50,
      relatedId: adId,
      description: 'Watched rewarded ad',
      earnedAt: earnedAt ?? DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
}
