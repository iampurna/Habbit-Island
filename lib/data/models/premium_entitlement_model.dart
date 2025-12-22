import 'package:equatable/equatable.dart';

/// Premium Entitlement Model (Data Layer)
/// Reference: Product Documentation v1.0 §6 (Premium System)
///
/// Tracks premium subscription entitlements, usage, and benefits.
/// Used for enforcing premium limits and features.

class PremiumEntitlementModel extends Equatable {
  final String id;
  final String userId;
  final PremiumTier tier;
  final PremiumPlatform platform; // iOS, Android, Web, Promo
  final String? transactionId; // Platform transaction ID
  final String? productId; // Platform product ID
  final DateTime purchasedAt;
  final DateTime? expiresAt;
  final DateTime? cancelledAt;
  final bool isActive;
  final bool autoRenews;

  // Premium benefits usage tracking
  final int streakShieldsTotal; // 3 per month for premium
  final int streakShieldsUsed;
  final DateTime? streakShieldsResetAt; // Monthly reset
  final int vacationDaysTotal; // 30 per year for premium
  final int vacationDaysUsed;
  final DateTime? vacationDaysResetAt; // Annual reset

  // Metadata
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PremiumEntitlementModel({
    required this.id,
    required this.userId,
    required this.tier,
    required this.platform,
    this.transactionId,
    this.productId,
    required this.purchasedAt,
    this.expiresAt,
    this.cancelledAt,
    this.isActive = true,
    this.autoRenews = false,
    this.streakShieldsTotal = 3,
    this.streakShieldsUsed = 0,
    this.streakShieldsResetAt,
    this.vacationDaysTotal = 30,
    this.vacationDaysUsed = 0,
    this.vacationDaysResetAt,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    tier,
    platform,
    transactionId,
    productId,
    purchasedAt,
    expiresAt,
    cancelledAt,
    isActive,
    autoRenews,
    streakShieldsTotal,
    streakShieldsUsed,
    streakShieldsResetAt,
    vacationDaysTotal,
    vacationDaysUsed,
    vacationDaysResetAt,
    metadata,
    createdAt,
    updatedAt,
  ];

  // ============================================================================
  // JSON SERIALIZATION (for Supabase & Hive)
  // ============================================================================

  factory PremiumEntitlementModel.fromJson(Map<String, dynamic> json) {
    return PremiumEntitlementModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tier: PremiumTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => PremiumTier.free,
      ),
      platform: PremiumPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => PremiumPlatform.web,
      ),
      transactionId: json['transaction_id'] as String?,
      productId: json['product_id'] as String?,
      purchasedAt: DateTime.parse(json['purchased_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
      autoRenews: json['auto_renews'] as bool? ?? false,
      streakShieldsTotal: json['streak_shields_total'] as int? ?? 3,
      streakShieldsUsed: json['streak_shields_used'] as int? ?? 0,
      streakShieldsResetAt: json['streak_shields_reset_at'] != null
          ? DateTime.parse(json['streak_shields_reset_at'] as String)
          : null,
      vacationDaysTotal: json['vacation_days_total'] as int? ?? 30,
      vacationDaysUsed: json['vacation_days_used'] as int? ?? 0,
      vacationDaysResetAt: json['vacation_days_reset_at'] != null
          ? DateTime.parse(json['vacation_days_reset_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tier': tier.name,
      'platform': platform.name,
      'transaction_id': transactionId,
      'product_id': productId,
      'purchased_at': purchasedAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'is_active': isActive,
      'auto_renews': autoRenews,
      'streak_shields_total': streakShieldsTotal,
      'streak_shields_used': streakShieldsUsed,
      'streak_shields_reset_at': streakShieldsResetAt?.toIso8601String(),
      'vacation_days_total': vacationDaysTotal,
      'vacation_days_used': vacationDaysUsed,
      'vacation_days_reset_at': vacationDaysResetAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ============================================================================
  // COPY WITH
  // ============================================================================

  PremiumEntitlementModel copyWith({
    String? id,
    String? userId,
    PremiumTier? tier,
    PremiumPlatform? platform,
    String? transactionId,
    String? productId,
    DateTime? purchasedAt,
    DateTime? expiresAt,
    DateTime? cancelledAt,
    bool? isActive,
    bool? autoRenews,
    int? streakShieldsTotal,
    int? streakShieldsUsed,
    DateTime? streakShieldsResetAt,
    int? vacationDaysTotal,
    int? vacationDaysUsed,
    DateTime? vacationDaysResetAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PremiumEntitlementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      platform: platform ?? this.platform,
      transactionId: transactionId ?? this.transactionId,
      productId: productId ?? this.productId,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      isActive: isActive ?? this.isActive,
      autoRenews: autoRenews ?? this.autoRenews,
      streakShieldsTotal: streakShieldsTotal ?? this.streakShieldsTotal,
      streakShieldsUsed: streakShieldsUsed ?? this.streakShieldsUsed,
      streakShieldsResetAt: streakShieldsResetAt ?? this.streakShieldsResetAt,
      vacationDaysTotal: vacationDaysTotal ?? this.vacationDaysTotal,
      vacationDaysUsed: vacationDaysUsed ?? this.vacationDaysUsed,
      vacationDaysResetAt: vacationDaysResetAt ?? this.vacationDaysResetAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if premium is currently active
  bool get isPremiumActive {
    if (!isActive) return false;
    if (tier == PremiumTier.lifetime) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Check if subscription is cancelled but still valid
  bool get isCancelledButActive {
    return cancelledAt != null && isPremiumActive;
  }

  /// Days until expiry
  int? get daysUntilExpiry {
    if (!isPremiumActive) return null;
    if (tier == PremiumTier.lifetime) return null;
    if (expiresAt == null) return null;
    return expiresAt!.difference(DateTime.now()).inDays;
  }

  /// Check if subscription will renew
  bool get willRenew => isActive && autoRenews && cancelledAt == null;

  /// Streak shields remaining
  int get streakShieldsRemaining => streakShieldsTotal - streakShieldsUsed;

  /// Check if has streak shields available
  bool get hasStreakShields => streakShieldsRemaining > 0;

  /// Vacation days remaining
  int get vacationDaysRemaining => vacationDaysTotal - vacationDaysUsed;

  /// Check if has vacation days available
  bool get hasVacationDays => vacationDaysRemaining > 0;

  /// Check if streak shields need reset (monthly)
  bool get needsStreakShieldsReset {
    if (streakShieldsResetAt == null) return true;
    final now = DateTime.now();
    return now.isAfter(streakShieldsResetAt!);
  }

  /// Check if vacation days need reset (annual)
  bool get needsVacationDaysReset {
    if (vacationDaysResetAt == null) return true;
    final now = DateTime.now();
    return now.isAfter(vacationDaysResetAt!);
  }

  /// Get next streak shields reset date
  DateTime get nextStreakShieldsReset {
    if (streakShieldsResetAt == null) {
      final now = DateTime.now();
      return DateTime(now.year, now.month + 1, 1);
    }
    return streakShieldsResetAt!;
  }

  /// Get next vacation days reset date
  DateTime get nextVacationDaysReset {
    if (vacationDaysResetAt == null) {
      final now = DateTime.now();
      return DateTime(now.year + 1, 1, 1);
    }
    return vacationDaysResetAt!;
  }
}

// ============================================================================
// ENUMS
// ============================================================================

/// Premium tier (Product Documentation §6.2)
enum PremiumTier {
  free, // Free tier
  monthly, // $4.99/month
  annual, // $39.99/year
  lifetime, // $49.99 one-time
}

/// Premium platform (where purchase was made)
enum PremiumPlatform {
  ios, // Apple App Store
  android, // Google Play Store
  web, // Web payment (Stripe)
  promo, // Promotional/gifted
}

extension PremiumPlatformExtension on PremiumPlatform {
  String get displayName {
    switch (this) {
      case PremiumPlatform.ios:
        return 'iOS';
      case PremiumPlatform.android:
        return 'Android';
      case PremiumPlatform.web:
        return 'Web';
      case PremiumPlatform.promo:
        return 'Promotional';
    }
  }
}
