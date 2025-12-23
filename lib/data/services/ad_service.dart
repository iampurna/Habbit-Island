import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:habbit_island/core/utils/app_logger.dart';
import 'analytics_service.dart';

/// Ad Service
/// Manages AdMob ads: banners, interstitials, and rewarded ads
/// Reference: Product Documentation §6.3 (Ad System)
///
/// Rules:
/// - Free users see ads
/// - Premium users: No ads
/// - Rewarded ads: +50 XP, max 3/day
/// - Banner ads: Bottom of main screens
/// - Interstitial ads: Between major actions

class AdService {
  final AnalyticsService _analytics;

  // Ad Unit IDs (replace with your actual IDs in config)
  static const String _androidBannerAdId =
      'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String _iosBannerAdId =
      'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String _androidInterstitialAdId =
      'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String _iosInterstitialAdId =
      'ca-app-pub-3940256099942544/4411468910'; // Test ID
  static const String _androidRewardedAdId =
      'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String _iosRewardedAdId =
      'ca-app-pub-3940256099942544/1712485313'; // Test ID

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Ad state
  bool _isBannerAdLoaded = false;
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  bool _isInitialized = false;
  bool _isPremium = false;

  AdService({required AnalyticsService analytics}) : _analytics = analytics;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize Mobile Ads SDK
  Future<void> initialize({required bool isPremium}) async {
    if (_isInitialized) return;

    _isPremium = isPremium;

    // Premium users don't need ads
    if (_isPremium) {
      AdLogger.premiumUserSkipped();
      _isInitialized = true;
      return;
    }

    try {
      AppLogger.debug('Initializing AdMob...');
      await MobileAds.instance.initialize();

      // Set request configuration
      final configuration = RequestConfiguration(
        testDeviceIds: [
          // Add your test device IDs here
        ],
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);

      AdLogger.initialized();
      _isInitialized = true;
    } catch (e, stackTrace) {
      AdLogger.initializationFailed(e);
      AppLogger.error('AdMob initialization failed', e, stackTrace);
    }
  }

  /// Update premium status (call when user upgrades/downgrades)
  void updatePremiumStatus(bool isPremium) {
    final previousStatus = _isPremium;
    _isPremium = isPremium;

    if (_isPremium && !previousStatus) {
      AppLogger.info('User upgraded to premium - disposing ads');
      // Hide and dispose all ads
      disposeBannerAd();
      disposeInterstitialAd();
      disposeRewardedAd();
    }
  }

  // ============================================================================
  // BANNER ADS
  // ============================================================================

  /// Load banner ad
  Future<void> loadBannerAd({
    required Function(BannerAd) onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (_isPremium || !_isInitialized) return;

    AppLogger.debug('Loading banner ad...');

    _bannerAd = BannerAd(
      adUnitId: _getBannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdLoaded = true;
          AdLogger.adLoaded('banner');
          _analytics.logAdImpression(adType: 'banner', adId: ad.adUnitId);
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdLoaded = false;
          AdLogger.adFailedToLoad('banner', error);
          ad.dispose();
          _bannerAd = null;
          onAdFailedToLoad?.call(error);
        },
        onAdClicked: (ad) {
          AdLogger.adClicked('banner');
          _analytics.logAdClicked(adType: 'banner', adId: ad.adUnitId);
        },
      ),
    );

    await _bannerAd?.load();
  }

  /// Get banner ad widget
  BannerAd? get bannerAd => _isBannerAdLoaded ? _bannerAd : null;

  /// Dispose banner ad
  void disposeBannerAd() {
    if (_bannerAd != null) {
      AppLogger.debug('Disposing banner ad');
      _bannerAd?.dispose();
      _bannerAd = null;
      _isBannerAdLoaded = false;
    }
  }

  // ============================================================================
  // INTERSTITIAL ADS
  // ============================================================================

  /// Load interstitial ad
  Future<void> loadInterstitialAd({
    Function()? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (_isPremium || !_isInitialized) return;

    AppLogger.debug('Loading interstitial ad...');

    await InterstitialAd.load(
      adUnitId: _getInterstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoaded = true;
          AdLogger.adLoaded('interstitial');
          _analytics.logAdImpression(adType: 'interstitial', adId: ad.adUnitId);
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoaded = false;
          _interstitialAd = null;
          AdLogger.adFailedToLoad('interstitial', error);
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Show interstitial ad
  Future<bool> showInterstitialAd({
    Function()? onAdDismissed,
    Function()? onAdShowFailed,
  }) async {
    if (_isPremium || !_isInterstitialAdLoaded || _interstitialAd == null) {
      return false;
    }

    AppLogger.debug('Showing interstitial ad');

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdLogger.adShown('interstitial');
      },
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.debug('Interstitial ad dismissed');
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        onAdDismissed?.call();
        // Preload next ad
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning('Failed to show interstitial ad', error);
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialAdLoaded = false;
        onAdShowFailed?.call();
      },
      onAdClicked: (ad) {
        AdLogger.adClicked('interstitial');
        _analytics.logAdClicked(adType: 'interstitial', adId: ad.adUnitId);
      },
    );

    await _interstitialAd!.show();
    return true;
  }

  /// Dispose interstitial ad
  void disposeInterstitialAd() {
    if (_interstitialAd != null) {
      AppLogger.debug('Disposing interstitial ad');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      _isInterstitialAdLoaded = false;
    }
  }

  // ============================================================================
  // REWARDED ADS (XP System)
  // ============================================================================

  /// Load rewarded ad
  Future<void> loadRewardedAd({
    Function()? onAdLoaded,
    Function(LoadAdError)? onAdFailedToLoad,
  }) async {
    if (!_isInitialized) return;

    AppLogger.debug('Loading rewarded ad...');

    await RewardedAd.load(
      adUnitId: _getRewardedAdUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoaded = true;
          AdLogger.adLoaded('rewarded');
          onAdLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoaded = false;
          _rewardedAd = null;
          AdLogger.adFailedToLoad('rewarded', error);
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Show rewarded ad
  /// Returns true if reward was earned, false otherwise
  Future<bool> showRewardedAd({
    required Function(RewardItem) onUserEarnedReward,
    Function()? onAdDismissed,
    Function()? onAdShowFailed,
  }) async {
    if (!_isRewardedAdLoaded || _rewardedAd == null) {
      AppLogger.warning('Attempted to show rewarded ad but none is loaded');
      onAdShowFailed?.call();
      return false;
    }

    AppLogger.debug('Showing rewarded ad');
    bool rewardEarned = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        AdLogger.adShown('rewarded');
      },
      onAdDismissedFullScreenContent: (ad) {
        AppLogger.debug('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        onAdDismissed?.call();
        // Preload next ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning('Failed to show rewarded ad', error);
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoaded = false;
        onAdShowFailed?.call();
      },
      onAdClicked: (ad) {
        AdLogger.adClicked('rewarded');
        _analytics.logAdClicked(adType: 'rewarded', adId: ad.adUnitId);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardEarned = true;
        AdLogger.rewardEarned(reward.amount.toInt());
        AppLogger.info('User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward(reward);
      },
    );

    return rewardEarned;
  }

  /// Check if rewarded ad is ready
  bool get isRewardedAdReady => _isRewardedAdLoaded;

  /// Dispose rewarded ad
  void disposeRewardedAd() {
    if (_rewardedAd != null) {
      AppLogger.debug('Disposing rewarded ad');
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _isRewardedAdLoaded = false;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get banner ad unit ID for current platform
  String _getBannerAdUnitId() {
    if (Platform.isAndroid) {
      return _androidBannerAdId;
    } else if (Platform.isIOS) {
      return _iosBannerAdId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Get interstitial ad unit ID for current platform
  String _getInterstitialAdUnitId() {
    if (Platform.isAndroid) {
      return _androidInterstitialAdId;
    } else if (Platform.isIOS) {
      return _iosInterstitialAdId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Get rewarded ad unit ID for current platform
  String _getRewardedAdUnitId() {
    if (Platform.isAndroid) {
      return _androidRewardedAdId;
    } else if (Platform.isIOS) {
      return _iosRewardedAdId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  /// Dispose all ads
  void dispose() {
    AppLogger.debug('Disposing all ads');
    disposeBannerAd();
    disposeInterstitialAd();
    disposeRewardedAd();
  }
}

/// Ad display strategy helper
class AdDisplayStrategy {
  /// Check if should show interstitial ad
  /// Show every 3 habit completions for free users
  static bool shouldShowInterstitial({
    required bool isPremium,
    required int completionCount,
  }) {
    if (isPremium) return false;
    return completionCount % 3 == 0 && completionCount > 0;
  }

  /// Check if should show banner ad
  static bool shouldShowBanner({
    required bool isPremium,
    required String screenName,
  }) {
    if (isPremium) return false;

    // Show banners on main screens
    const bannedScreens = ['home', 'habits', 'island', 'profile'];

    return bannedScreens.contains(screenName);
  }
}
