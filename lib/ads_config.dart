/// Centralized AdMob configuration for n8n Manager app.
library;
import 'package:flutter/foundation.dart';

class AdsConfig { 
  final bool debug;

  /// Real AdMob Banner Ad Unit ID (replace with your real ID for production).
  static const String realBannerAdUnitId =
      'ca-app-pub-1195883693665145/9026463491'; // Google test ID

  /// Test AdMob Banner Ad Unit ID (Google official test ID).
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/9214589741';

  // appOpenAdUnitId
  /// Real AdMob App Open Ad Unit ID (replace with your real ID for production).
  static const String realAppOpenAdUnitId =
      'ca-app-pub-1195883693665145/4291568600'; // Google test ID
  /// Test AdMob App Open Ad Unit ID (Google official test ID).
  static const String testAppOpenAdUnitId =
      'ca-app-pub-3940256099942544/9257395921';

  // interstitialAdUnitId
  /// Real AdMob Interstitial Ad Unit ID (replace with your real ID for production).
  static const String realInterstitialAdUnitId =
      'ca-app-pub-1195883693665145/5604650274'; // Google test ID
  /// Test AdMob Interstitial Ad Unit ID (Google official test ID).
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  // nativeAdUnitId
  /// Real AdMob Native Advanced Ad Unit ID (replace with your real ID for production).
  static const String realNativeAdUnitId =
      'ca-app-pub-1195883693665145/2171400201'; // Google test ID
  /// Test AdMob Native Advanced Ad Unit ID (Google official test ID).
  static const String testNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';

  const AdsConfig({this.debug = true});

  /// Returns the effective Banner Ad Unit ID based on debug flag.
  String get effectiveBannerAdUnitId =>
      debug ? testBannerAdUnitId : realBannerAdUnitId;

  String get effectiveInterstitialAdUnitId =>
      debug ? testInterstitialAdUnitId : realInterstitialAdUnitId;

  /// Returns the effective App Open Ad Unit ID based on debug flag.
  String get effectiveAppOpenAdUnitId =>
      debug ? testAppOpenAdUnitId : realAppOpenAdUnitId;

  /// Returns the effective Native Ad Unit ID based on debug flag.
  String get effectiveNativeAdUnitId =>
      debug ? testNativeAdUnitId : realNativeAdUnitId;
}

/// Global adsConfig instance (automatically uses test IDs in debug, real IDs in release).
const adsConfig = AdsConfig(debug: kDebugMode);
