import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../common/admob_helper.dart';
import '../../presentation/controllers/purchase_controller.dart';

/// Self-loading 300x250 (medium rectangle) banner.
///
/// Placed as the second section of every page so it is visible without
/// scrolling. Takes no space until an ad has actually loaded, so a slow or
/// failed request never leaves an empty grey box on the page; it also stays
/// collapsed when the user removed ads.
class MediumRectAd extends StatefulWidget {
  final EdgeInsetsGeometry padding;

  const MediumRectAd({
    super.key,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
  });

  @override
  State<MediumRectAd> createState() => _MediumRectAdState();
}

class _MediumRectAdState extends State<MediumRectAd>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _ad;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ad = await AdmobHelper.loadBannerAd(size: AdSize.mediumRectangle);
    if (!mounted) {
      ad?.dispose();
      return;
    }
    if (ad != null) setState(() => _ad = ad);
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  // Keeps the loaded ad alive when it scrolls out of a lazy list.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final removed = Get.isRegistered<PurchaseController>() &&
          Get.find<PurchaseController>().adsRemoved.value;
      final ad = _ad;
      if (removed || ad == null) return const SizedBox.shrink();
      return Padding(
        padding: widget.padding,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 300, height: 250, child: AdWidget(ad: ad)),
          ),
        ),
      );
    });
  }
}
