import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import '../../ads_config.dart';

/// Lightweight AdsService to initialize the Google Mobile Ads SDK,
/// expose a simple AppOpenAd loader/show, and provide BannerAd creation.
class AdsService {
  bool _initialized = false;
  AppOpenAd? _appOpenAd;
  bool _appOpenAdLoading = false;
  InterstitialAd? _interstitialAd;
  bool _interstitialLoading = false;

  Future<void> initialize() async {
    if (_initialized) return;
    // When debugging, configure test device ids to increase chance of test fills
    try {
      if (adsConfig.debug) {
        await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(testDeviceIds: ['EMULATOR']));
      }
    } catch (_) {}
    await MobileAds.instance.initialize();
    _initialized = true;
    // Optionally pre-load an app open ad.
    // loadAppOpenAd();
  }

  String get _appOpenUnitId => adsConfig.effectiveAppOpenAdUnitId;
  String get _bannerUnitId => adsConfig.effectiveBannerAdUnitId;
  String get _interstitialUnitId => adsConfig.effectiveInterstitialAdUnitId;
  String get _nativeUnitId => adsConfig.effectiveNativeAdUnitId;

  /// Load an AppOpenAd (keeps a single cached ad).
  /// If [hasSubscription] is true, skips loading to avoid showing ads to paying users.
  Future<void> loadAppOpenAd({bool adsShow = false, bool hasSubscription = false}) async {
    // Skip loading if user has subscription (paid users shouldn't see ads)
    if (hasSubscription) return;
    
    // print('AdsService: loadAppOpenAd called, adsShow=$adsShow');
    if (!_initialized) return;
    if (_appOpenAd != null || _appOpenAdLoading) return;
    _appOpenAdLoading = true;
    try {
      await AppOpenAd.load(
        adUnitId: _appOpenUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            _appOpenAdLoading = false;
            print('AdsService: AppOpenAd showed full screen content. ${adsShow}');
            if (adsShow) {
              showAppOpenAd();
              print('AdsService: AppOpenAd showed full screen content.');
            }
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _appOpenAd = null;
                // reload for next time
                loadAppOpenAd();
              },
              onAdFailedToShowFullScreenContent: (ad, err) {
                _appOpenAd = null;
                loadAppOpenAd();
              },
              // load success
            );
          },
          onAdFailedToLoad: (err) {
            _appOpenAdLoading = false;
            _appOpenAd = null;
            // log for debugging
            // err.code: 0 internal, 1 invalid request, 2 network, 3 no fill
            try {
              // ignore: avoid_print
              print('❌ AppOpenAd failed to load: Code ${err.code} - ${err.message}');
            } catch (_) {}
          },
        ),
      );
    } catch (_) {
      _appOpenAdLoading = false;
      _appOpenAd = null;
    }
  }

  /// Load an interstitial ad and optionally show it when ready.
  Future<void> loadInterstitial({bool adsShow = false}) async {
    if (!_initialized) return;
    if (_interstitialAd != null || _interstitialLoading) return;
    _interstitialLoading = true;
    try {
      await InterstitialAd.load(
        adUnitId: _interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialLoading = false;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                _interstitialAd = null;
                // reload for next time
                loadInterstitial();
              },
              onAdFailedToShowFullScreenContent: (ad, err) {
                _interstitialAd = null;
                loadInterstitial();
              },
            );
            if (adsShow) {
              try {
                ad.show();
              } catch (_) {}
            }
          },
          onAdFailedToLoad: (err) {
            _interstitialLoading = false;
            _interstitialAd = null;
            try {
              // ignore: avoid_print
              print('❌ Interstitial failed to load: Code ${err.code} - ${err.message}');
            } catch (_) {}
          },
        ),
      );
    } catch (_) {
      _interstitialLoading = false;
      _interstitialAd = null;
    }
  }

  /// Show cached interstitial ad if available.
  Future<void> showInterstitial() async {
    if (_interstitialAd == null) return;
    try {
      _interstitialAd!.show();
    } catch (_) {}
  }

  /// Show the cached AppOpenAd if available.
  /// If [hasSubscription] is true, skips showing to avoid ads for paying users.
  Future<void> showAppOpenAd({bool hasSubscription = false}) async {
    // Skip showing if user has subscription (paid users shouldn't see ads)
    if (hasSubscription) return;
    
    // print('AdsService: showAppOpenAd called, appOpenAd=$_appOpenAd');
    if (_appOpenAd == null) return;
    try {
      _appOpenAd!.show();
      // after show, the callbacks above will reload.
    } catch (_) {}
  }

  /// Create a BannerAd instance. Caller must call `load()` and manage lifecycle.
  BannerAd createBannerAd({
    AdSize size = AdSize.banner,
    String? overrideUnitId,
    BannerAdListener? listener,
  }) {
    final id = overrideUnitId ?? _bannerUnitId;
    return BannerAd(
      adUnitId: id,
      size: size,
      request: const AdRequest(),
      listener:
          listener ??
          BannerAdListener(onAdFailedToLoad: (ad, err) => ad.dispose()),
    );
  }

  /// Load a Native Advanced Ad.
  Future<NativeAd?> loadNativeAd({
    required NativeAdListener listener,
  }) async {
    if (!_initialized) return null;
    try {
      final nativeAd = NativeAd(
        adUnitId: _nativeUnitId,
        listener: listener,
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          cornerRadius: 10.0,
        ),
      );
      await nativeAd.load();
      return nativeAd;
    } catch (_) {
      return null;
    }
  }
}
