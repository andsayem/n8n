import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';

/// Reusable Banner Ad widget that uses the shared AdsService.
/// It manages the BannerAd lifecycle and displays a small area when loaded.
class BannerAdWidget extends ConsumerStatefulWidget {
  final AdSize size;
  final String? overrideUnitId;
  const BannerAdWidget({super.key, this.size = AdSize.banner, this.overrideUnitId});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  bool _loading = false;
  bool? _lastRemoved;

  @override
  void initState() {
    super.initState();
    // Delay creation until after first frame for adaptive size computation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createAndLoadIfNeeded();
    });
  }

  Future<void> _createAndLoadIfNeeded() async {
    if (_loading || _loaded) return;
    _loading = true;
    
    // Check persisted flag directly to avoid race with provider async load.
    final prefs = await SharedPreferences.getInstance();
    final removedFlag = prefs.getBool('ads_removed') ?? ref.read(adsRemovedProvider);
    if (removedFlag == true) {
      _loading = false;
      return;
    }
    
    try {
      final ads = ref.read(adsServiceProvider);
      
      // Compute adaptive size based on device width and orientation
      final width = MediaQuery.of(context).size.width.toInt();
      final orientation = MediaQuery.of(context).orientation;
      AdSize adSize = widget.size;
      
      try {
        final adaptive = await AdSize.getAnchoredAdaptiveBannerAdSize(orientation, width);
        if (adaptive != null) {
          adSize = adaptive;
        }
      } catch (_) {
        // Fall back to widget.size if adaptive sizing fails
      }
      
      // Create the BannerAd but don't store it into state until it is loaded.
      final BannerAd created = ads.createBannerAd(
        size: adSize,
        overrideUnitId: widget.overrideUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (!mounted) return;
            setState(() {
              _bannerAd = ad as BannerAd;
              _loaded = true;
            });
            _loading = false;
          },
          onAdFailedToLoad: (ad, err) {
            try {
              ad.dispose();
            } catch (_) {}
            if (!mounted) return;
            // ignore: avoid_print
            print('❌ BannerAd failed to load: Code ${err.code} - ${err.message}');
            setState(() {
              _loaded = false;
              _bannerAd = null;
            });
            _loading = false;
          },
        ),
      );
      // Call load; AdWidget will only be inserted after onAdLoaded sets _bannerAd and _loaded.
      await created.load();
    } catch (_) {
      // don't crash app if ads fail
      _bannerAd = null;
      _loaded = false;
      _loading = false;
    }
  }

  @override
  void dispose() {
    try {
      _bannerAd?.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // React to adsRemovedProvider changes safely by scheduling side-effects
    final removed = ref.watch(adsRemovedProvider);
    if (_lastRemoved != removed) {
      _lastRemoved = removed;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (removed == true) {
          try {
            _bannerAd?.dispose();
          } catch (_) {}
          _bannerAd = null;
          setState(() {
            _loaded = false;
            _loading = false;
          });
        } else {
          if (_bannerAd == null && !_loading) {
            Future.microtask(() => _createAndLoadIfNeeded());
          }
        }
      });
    }
    if (!_loaded || _bannerAd == null) return const SizedBox.shrink();
    final height = _bannerAd!.size.height.toDouble();
    return SizedBox(
      height: height,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
