import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class NativeAdWidget extends ConsumerStatefulWidget {
  final double height;
  final EdgeInsets padding;

  const NativeAdWidget({
    super.key,
    this.height = 320,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  Future<void> _loadNativeAd() async {
    try {
      // Check if user has purchased (ads removed)
      final purchaseService = ref.read(purchaseServiceProvider);
      final adsRemoved = await purchaseService.getAdsRemovedLocal();
      print('Ads removed: $adsRemoved');
      
      if (adsRemoved) {
        // User purchased, don't load ads
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true; // Treat as error so it doesn't show
          });
        }
        return;
      }
      
      final adsService = ref.read(adsServiceProvider);
      final nativeAd = await adsService.loadNativeAd(
        listener: NativeAdListener(
          onAdLoaded: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onAdClicked: (_) {},
          onAdImpression: (_) {},
          onAdOpened: (_) {},
          onAdClosed: (_) {},
        ),
      );
      if (mounted) {
        setState(() {
          _nativeAd = nativeAd;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: widget.padding,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_hasError || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: AdWidget(ad: _nativeAd!),
      ),
    );
  }
}
