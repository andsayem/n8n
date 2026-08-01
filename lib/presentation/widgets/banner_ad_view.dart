import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reusable banner ad widget. Renders nothing when [ad] is null.
class BannerAdView extends StatelessWidget {
  final BannerAd? ad;

  const BannerAdView({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    if (ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: ad!.size.height.toDouble(),
      child: AdWidget(ad: ad!),
    );
  }
}
