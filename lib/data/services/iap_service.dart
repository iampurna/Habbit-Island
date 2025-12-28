import 'package:flutter/services.dart';
import 'package:habbit_island/core/utils/app_logger.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../models/premium_entitlement_model.dart';
import 'analytics_service.dart';
import 'dart:io';

/// In-App Purchase Service
/// Manages premium subscriptions using RevenueCat
/// Reference: Product Documentation §6.2 (Premium System)
///
/// Premium Tiers:
/// - Monthly: $4.99/month
/// - Annual: $39.99/year
/// - Lifetime: $49.99 one-time

class IAPService {
  final AnalyticsService _analytics;

  bool _isInitialized = false;
  CustomerInfo? _customerInfo;

  // RevenueCat API Keys (replace with your actual keys)
  static const String _androidApiKey = 'YOUR_ANDROID_API_KEY';
  static const String _iosApiKey = 'YOUR_IOS_API_KEY';

  // Product IDs
  static const String monthlyProductId = 'premium_monthly';
  static const String annualProductId = 'premium_annual';
  static const String lifetimeProductId = 'premium_lifetime';

  // Entitlement ID
  static const String premiumEntitlementId = 'premium';

  IAPService({required AnalyticsService analytics}) : _analytics = analytics;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize RevenueCat
  Future<void> initialize({required String userId}) async {
    if (_isInitialized) return;

    try {
      AppLogger.debug('Initializing IAP service for user: $userId');

      final configuration = PurchasesConfiguration(
        Platform.isAndroid ? _androidApiKey : _iosApiKey,
      );

      await Purchases.configure(configuration);
      await Purchases.logIn(userId);

      // Get initial customer info
      _customerInfo = await Purchases.getCustomerInfo();

      IAPLogger.initialized();
      _isInitialized = true;
    } catch (e, stackTrace) {
      IAPLogger.initializationFailed(e);
      AppLogger.error('IAP initialization failed', e, stackTrace);
    }
  }

  /// Set user ID (call after authentication)
  Future<void> setUserId(String userId) async {
    try {
      AppLogger.debug('Setting IAP user ID: $userId');
      await Purchases.logIn(userId);
      _customerInfo = await Purchases.getCustomerInfo();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set user ID', e, stackTrace);
    }
  }

  /// Log out user (call on sign out)
  Future<void> logOut() async {
    try {
      AppLogger.debug('Logging out IAP user');
      _customerInfo = await Purchases.logOut();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to log out', e, stackTrace);
    }
  }

  // ============================================================================
  // PRODUCT OFFERINGS
  // ============================================================================

  /// Get available products
  Future<List<Package>> getAvailableProducts() async {
    try {
      AppLogger.debug('Fetching available products...');
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        AppLogger.warning('No current offerings available');
        return [];
      }

      final packages = offerings.current!.availablePackages;
      IAPLogger.productsLoaded(packages.length);
      return packages;
    } catch (e, stackTrace) {
      IAPLogger.productsFailed(e);
      AppLogger.error('Failed to get products', e, stackTrace);
      return [];
    }
  }

  /// Get specific package
  Future<Package?> getPackage(String identifier) async {
    try {
      final offerings = await Purchases.getOfferings();

      if (offerings.current == null) {
        return null;
      }

      return offerings.current!.availablePackages.firstWhere(
        (package) => package.identifier == identifier,
        orElse: () => throw Exception('Package not found'),
      );
    } catch (e, stackTrace) {
      AppLogger.warning('Failed to get package: $identifier', e, stackTrace);
      return null;
    }
  }

  // ============================================================================
  // PURCHASE
  // ============================================================================

  /// Purchase premium subscription
  Future<PremiumEntitlementModel?> purchasePremium({
    required Package package,
  }) async {
    try {
      IAPLogger.purchaseStarted(package.storeProduct.identifier);

      // Track purchase started
      await _analytics.logPurchaseStarted(
        productId: package.storeProduct.identifier,
        tier: _getTierFromProductId(package.storeProduct.identifier),
        price: package.storeProduct.price,
        currency: package.storeProduct.currencyCode,
      );

      // Make purchase
      final purchaserInfo = await Purchases.purchasePackage(package);

      // Check entitlement
      if (purchaserInfo.entitlements.active.containsKey(premiumEntitlementId)) {
        final entitlement =
            purchaserInfo.entitlements.active[premiumEntitlementId]!;

        // Create premium entitlement model
        final premium = _createPremiumEntitlement(entitlement, package);

        IAPLogger.purchaseCompleted(
          package.storeProduct.identifier,
          entitlement.originalPurchaseDate,
        );

        // Track purchase completed
        await _analytics.logPurchaseCompleted(
          productId: package.storeProduct.identifier,
          tier: premium.tier,
          price: package.storeProduct.price,
          currency: package.storeProduct.currencyCode,
          transactionId: entitlement.originalPurchaseDate,
        );

        return premium;
      }

      return null;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);

      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        IAPLogger.purchaseCancelled(package.storeProduct.identifier);
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        IAPLogger.purchaseFailed(
          package.storeProduct.identifier,
          'Purchase not allowed',
        );
      } else {
        IAPLogger.purchaseFailed(package.storeProduct.identifier, e.message);
      }

      return null;
    } catch (e, stackTrace) {
      IAPLogger.purchaseFailed(package.storeProduct.identifier, e);
      AppLogger.error('Purchase failed', e, stackTrace);
      return null;
    }
  }

  /// Restore purchases
  Future<PremiumEntitlementModel?> restorePurchases() async {
    try {
      IAPLogger.restoreStarted();

      final customerInfo = await Purchases.restorePurchases();
      _customerInfo = customerInfo;

      if (customerInfo.entitlements.active.containsKey(premiumEntitlementId)) {
        final entitlement =
            customerInfo.entitlements.active[premiumEntitlementId]!;
        IAPLogger.restoreCompleted(true);
        return _createPremiumEntitlementFromEntitlement(entitlement);
      }

      IAPLogger.restoreCompleted(false);
      return null;
    } catch (e, stackTrace) {
      IAPLogger.restoreFailed(e);
      AppLogger.error('Restore failed', e, stackTrace);
      return null;
    }
  }

  // ============================================================================
  // SUBSCRIPTION MANAGEMENT
  // ============================================================================

  /// Check if user has active premium
  Future<bool> isPremiumActive() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.active.containsKey(premiumEntitlementId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check premium status', e, stackTrace);
      return false;
    }
  }

  /// Get premium entitlement
  Future<PremiumEntitlementModel?> getPremiumEntitlement() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      if (customerInfo.entitlements.active.containsKey(premiumEntitlementId)) {
        final entitlement =
            customerInfo.entitlements.active[premiumEntitlementId]!;
        return _createPremiumEntitlementFromEntitlement(entitlement);
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get premium entitlement', e, stackTrace);
      return null;
    }
  }

  /// Check subscription status
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      if (!customerInfo.entitlements.active.containsKey(premiumEntitlementId)) {
        return SubscriptionStatus.notSubscribed;
      }

      final entitlement =
          customerInfo.entitlements.active[premiumEntitlementId]!;

      if (entitlement.willRenew) {
        return SubscriptionStatus.active;
      } else if (entitlement.unsubscribeDetectedAt != null) {
        return SubscriptionStatus.cancelled;
      } else {
        return SubscriptionStatus.expired;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get subscription status', e, stackTrace);
      return SubscriptionStatus.unknown;
    }
  }

  /// Get subscription expiry date
  Future<DateTime?> getSubscriptionExpiryDate() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();

      if (customerInfo.entitlements.active.containsKey(premiumEntitlementId)) {
        final entitlement =
            customerInfo.entitlements.active[premiumEntitlementId]!;
        return DateTime.parse(entitlement.expirationDate ?? '');
      }

      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get expiry date', e, stackTrace);
      return null;
    }
  }

  // ============================================================================
  // PROMO CODES
  // ============================================================================

  /// Present promo code redemption sheet (iOS only)
  Future<void> presentCodeRedemptionSheet() async {
    if (Platform.isIOS) {
      AppLogger.debug('Presenting promo code redemption sheet');
      await Purchases.presentCodeRedemptionSheet();
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Create premium entitlement from package and entitlement
  PremiumEntitlementModel _createPremiumEntitlement(
    EntitlementInfo entitlement,
    Package package,
  ) {
    return PremiumEntitlementModel(
      id: entitlement.identifier,
      userId: _customerInfo?.originalAppUserId ?? '',
      tier: _getTierFromProductId(package.storeProduct.identifier),
      platform: Platform.isIOS ? PremiumPlatform.ios : PremiumPlatform.android,
      transactionId: entitlement.originalPurchaseDate,
      productId: package.storeProduct.identifier,
      purchasedAt: DateTime.parse(entitlement.originalPurchaseDate),
      expiresAt: entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : null,
      isActive: entitlement.isActive,
      autoRenews: entitlement.willRenew,
      streakShieldsTotal: 3,
      streakShieldsUsed: 0,
      streakShieldsResetAt: DateTime.now().add(const Duration(days: 30)),
      vacationDaysTotal: 30,
      vacationDaysUsed: 0,
      vacationDaysResetAt: DateTime.now().add(const Duration(days: 365)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Create premium entitlement from entitlement only
  PremiumEntitlementModel _createPremiumEntitlementFromEntitlement(
    EntitlementInfo entitlement,
  ) {
    return PremiumEntitlementModel(
      id: entitlement.identifier,
      userId: _customerInfo?.originalAppUserId ?? '',
      tier: _getTierFromProductId(entitlement.productIdentifier),
      platform: Platform.isIOS ? PremiumPlatform.ios : PremiumPlatform.android,
      transactionId: entitlement.originalPurchaseDate,
      productId: entitlement.productIdentifier,
      purchasedAt: DateTime.parse(entitlement.originalPurchaseDate),
      expiresAt: entitlement.expirationDate != null
          ? DateTime.parse(entitlement.expirationDate!)
          : null,
      isActive: entitlement.isActive,
      autoRenews: entitlement.willRenew,
      streakShieldsTotal: 3,
      streakShieldsUsed: 0,
      streakShieldsResetAt: DateTime.now().add(const Duration(days: 30)),
      vacationDaysTotal: 30,
      vacationDaysUsed: 0,
      vacationDaysResetAt: DateTime.now().add(const Duration(days: 365)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Get tier from product ID
  PremiumTier _getTierFromProductId(String productId) {
    if (productId.contains('monthly')) return PremiumTier.monthly;
    if (productId.contains('annual')) return PremiumTier.annual;
    if (productId.contains('lifetime')) return PremiumTier.lifetime;
    return PremiumTier.free;
  }

  // ============================================================================
  // LISTENER
  // ============================================================================

  /// Listen to customer info updates
  void listenToCustomerInfo(Function(CustomerInfo) callback) {
    Purchases.addCustomerInfoUpdateListener(callback);
  }

  Future<void> init() async {}
}

/// Subscription status
enum SubscriptionStatus { notSubscribed, active, cancelled, expired, unknown }
