import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/ads_config.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';

class AdmobHelper with WidgetsBindingObserver {
  // ---------------- Ad Unit IDs ----------------
  // Debug builds use Google's test IDs so real ads are never served while
  // testing on our own devices (see ads_config.dart).
  static String get bannerAdUnitId => adsConfig.effectiveBannerAdUnitId;
  static String get interstitialAdUnitId =>
      adsConfig.effectiveInterstitialAdUnitId;
  static String get appOpenAdUnitId => adsConfig.effectiveAppOpenAdUnitId;
  static String get nativeAdUnitId => adsConfig.effectiveNativeAdUnitId;

  /// True when the user bought "Remove Ads".
  static bool get adsRemoved {
    try {
      return Get.find<PurchaseController>().adsRemoved.value;
    } catch (_) {
      return false;
    }
  }

  // ================= Interstitial =================
  static InterstitialAd? _interstitialAd;
  static bool suppressAppOpen = false;

  // Frequency control for action-triggered interstitials.
  static DateTime? _lastInterstitialAt;
  static int _actionCount = 0;
  static const Duration interstitialCooldown = Duration(seconds: 60);
  static const int actionsPerInterstitial = 3;

  /// Counts a user action (opening a detail page, running a workflow, ...)
  /// and shows an interstitial every [actionsPerInterstitial] actions, never
  /// more often than [interstitialCooldown]. [then] always runs.
  static void maybeShowInterstitial({VoidCallback? then}) {
    if (adsRemoved) {
      then?.call();
      return;
    }
    _actionCount++;
    final last = _lastInterstitialAt;
    final cooledDown =
        last == null || DateTime.now().difference(last) > interstitialCooldown;
    if (_actionCount >= actionsPerInterstitial &&
        cooledDown &&
        _interstitialAd != null) {
      _actionCount = 0;
      _lastInterstitialAt = DateTime.now();
      showInterstitialAd(onAdDismissed: then);
      return;
    }
    loadInterstitialAd();
    then?.call();
  }

  static bool _isInterstitialLoading = false;

  /// LOAD
  static void loadInterstitialAd() {
    if (adsRemoved) return;
    if (_isInterstitialLoading || _interstitialAd != null) return;

    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;

              // reload immediately (important)
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;

              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;

          // 🔥 smart retry (exponential delay)
          Future.delayed(const Duration(seconds: 10), () {
            loadInterstitialAd();
          });
        },
      ),
    );
  }

  static void showInterstitialAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd == null) {
      debugPrint("Ad not ready");

      // 👉 fallback flow continue
      if (onAdDismissed != null) {
        onAdDismissed();
      }

      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;

        if (onAdDismissed != null) {
          onAdDismissed();
        }

        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;

        if (onAdDismissed != null) {
          onAdDismissed();
        }

        loadInterstitialAd();
      },
    );

    // show() can fail (e.g. app went to background); never crash on it.
    _interstitialAd!
        .show()
        .catchError((e) => debugPrint("Interstitial show failed: $e"));
  }

  // ================= Rewarded =================
  static RewardedAd? _rewardedAd;

  // static void loadRewardedAd() {
  //   RewardedAd.load(
  //     adUnitId: rewardedAdUnitId,
  //     request: const AdRequest(),
  //     rewardedAdLoadCallback: RewardedAdLoadCallback(
  //       onAdLoaded: (ad) => _rewardedAd = ad,
  //       onAdFailedToLoad: (error) {
  //         debugPrint("Rewarded failed: $error");
  //         _rewardedAd = null;

  //         Future.delayed(const Duration(seconds: 10), () {
  //           loadRewardedAd();
  //         });
  //       },
  //     ),
  //   );
  // }

  /// ✅ FIXED: always navigate even if ad not loaded
  // static void showRewardedAd(Function(RewardItem) onEarnedReward) {
  //   if (_rewardedAd != null) {
  //     _rewardedAd!.fullScreenContentCallback =
  //         FullScreenContentCallback(
  //       onAdDismissedFullScreenContent: (ad) {
  //         ad.dispose();
  //         _rewardedAd = null;
  //         loadRewardedAd();
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         ad.dispose();
  //         _rewardedAd = null;
  //         loadRewardedAd();
  //       },
  //     );

  //     _rewardedAd!.show(
  //       onUserEarnedReward: (ad, reward) {
  //         onEarnedReward(reward);
  //       },
  //     );

  //     _rewardedAd = null;
  //   } else {
  //     // 🔥 গুরুত্বপূর্ণ fix (না থাকলে click এ কিছুই হবে না)
  //     loadRewardedAd();
  //   }
  // }

  // ================= Banner =================
  static BannerAd? _bannerAd;
  static final Map<String, BannerAd> _bannerAdCache = {};

  static String _bannerAdKey({String? adUnitId, required AdSize size}) {
    return '${adUnitId ?? bannerAdUnitId}_${size.width}x${size.height}';
  }

  static Future<BannerAd?> loadAdaptiveBanner(BuildContext context) async {
    final width = MediaQuery.of(context).size.width.toInt();

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);

    if (size == null) return null;

    BannerAd banner = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Adaptive Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed: $error');
        },
      ),
    );

    await banner.load();
    return banner;
  }

  /// Loads a banner and completes with it once filled, or with null when the
  /// request fails (so callers never render a disposed ad).
  static Future<BannerAd?> loadBannerAd({
    String? adUnitId,
    AdSize size = const AdSize(width: 320, height: 50),
  }) async {
    if (adsRemoved) return null;
    final completer = Completer<BannerAd?>();
    final banner = BannerAd(
      adUnitId: adUnitId ?? bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner loaded');
          if (!completer.isCompleted) completer.complete(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed: $error');
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    await banner.load();
    return completer.future;
  }

  static BannerAd getBannerAdInstance(
      {String? adUnitId, AdSize size = const AdSize(width: 320, height: 50)}) {
    return BannerAd(
      adUnitId: adUnitId ?? bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => debugPrint('Banner loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Banner failed: $error');
        },
      ),
    );
  }

  static Widget getBannerAdWidget(
      {String? adUnitId, AdSize size = const AdSize(width: 320, height: 50)}) {
    final key = _bannerAdKey(adUnitId: adUnitId, size: size);
    final bannerAd = _bannerAdCache.putIfAbsent(
      key,
      () => getBannerAdInstance(adUnitId: adUnitId, size: size)..load(),
    );

    return SizedBox(
      width: bannerAd.size.width.toDouble(),
      height: bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  static Widget bannerAdWidget(BannerAd bannerAd,
      {double? width, double? height}) {
    return SizedBox(
      width: width ?? bannerAd.size.width.toDouble(),
      height: height ?? bannerAd.size.height.toDouble(),
      child: AdWidget(ad: bannerAd),
    );
  }

  // ================= App Open =================
  static AppOpenAd? _appOpenAd;
  static DateTime? _appOpenLoadTime;
  static bool _isShowingAppOpen = false;
  static const Duration maxCacheDuration = Duration(hours: 4);

  void loadAppOpenAd({Function()? onLoaded}) {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          if (onLoaded != null) onLoaded();
        },
        onAdFailedToLoad: (error) => debugPrint("AppOpenAd failed: $error"),
      ),
    );
  }

  static void showAppOpenAd() {
    if (suppressAppOpen || _appOpenAd == null || _isShowingAppOpen) return;

    if (_appOpenLoadTime != null &&
        DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      _appOpenAd!.dispose();
      _appOpenAd = null;
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => _isShowingAppOpen = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpen = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpen = false;
        ad.dispose();
        _appOpenAd = null;
      },
    );

    _appOpenAd!.show().catchError((e) => debugPrint("AppOpen show failed: $e"));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ Don't show app open ad if user has subscription
      try {
        final controller = Get.find<PurchaseController>();
        if (controller.adsRemoved.value) return;
      } catch (_) {}
      showAppOpenAd();
    }
  }

  // ================= Adaptive Banner =================
  static AdManagerBannerAd? _adaptiveBannerAd;
  static bool _isAdaptiveLoaded = false;

  static Future<Widget> getAdaptiveBannerWidget(double adWidth,
      {String? adUnitId}) async {
    if (_adaptiveBannerAd != null && _isAdaptiveLoaded) {
      return SizedBox(
        width: adWidth,
        height: _adaptiveBannerAd!.sizes.first.height.toDouble(),
        child: AdWidget(ad: _adaptiveBannerAd!),
      );
    }

    final completer = Completer<Widget>();

    final AdSize size = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(
        adWidth.truncate());

    _adaptiveBannerAd = AdManagerBannerAd(
      adUnitId: adUnitId ?? bannerAdUnitId,
      sizes: [size],
      request: const AdManagerAdRequest(),
      listener: AdManagerBannerAdListener(
        onAdLoaded: (ad) {
          _isAdaptiveLoaded = true;

          completer.complete(
            SizedBox(
              width: adWidth,
              height: size.height.toDouble(),
              child: AdWidget(ad: ad as AdManagerBannerAd),
            ),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _adaptiveBannerAd = null;
          _isAdaptiveLoaded = false;

          debugPrint('Adaptive Banner Failed: $error');

          completer.complete(const SizedBox());
        },
      ),
    );

    _adaptiveBannerAd!.load();

    return completer.future;
  }

  // ================= Dispose =================
  static void disposeAds() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd?.dispose();
    _appOpenAd?.dispose();
  }
}
