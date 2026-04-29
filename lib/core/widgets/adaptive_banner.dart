import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';

/// Adaptive Banner Ad widget for Dashboard.
/// Automatically computes optimal size based on device width and orientation.
/// Fixed height of 250 for consistent layout.
/// Respects ads_removed flag (hidden for purchased users).
class AdaptiveBanner extends ConsumerStatefulWidget {
  final String? overrideUnitId;
  const AdaptiveBanner({super.key, this.overrideUnitId});

  @override
  ConsumerState<AdaptiveBanner> createState() => _AdaptiveBannerState();
}

class _AdaptiveBannerState extends ConsumerState<AdaptiveBanner> {
  BannerAd? _bannerAd;
  bool _loaded = false;
  bool _loading = false;
  bool? _lastRemoved;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createAndLoadIfNeeded();
    });
  }

  Future<void> _createAndLoadIfNeeded() async {
    if (_loading || _loaded) return;
    _loading = true;

    final prefs = await SharedPreferences.getInstance();
    final removedFlag =
        prefs.getBool('ads_removed') ?? ref.read(adsRemovedProvider);
    if (removedFlag == true) {
      _loading = false;
      return;
    }

    try {
      final ads = ref.read(adsServiceProvider);
      final width = MediaQuery.of(context).size.width.toInt() - 40;
      AdSize? adSize;

      try {
        adSize = AdSize(width: width, height: 250);
      } catch (_) {
        adSize = AdSize.mediumRectangle;
      }

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
            print('❌ AdaptiveBanner failed: Code ${err.code} - ${err.message}');
            setState(() {
              _loaded = false;
              _bannerAd = null;
            });
            _loading = false;
          },
        ),
      );

      await created.load();
    } catch (e) {
      print('❌ AdaptiveBanner error: $e');
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
    return SizedBox(height: 250, child: AdWidget(ad: _bannerAd!));
  }
}
