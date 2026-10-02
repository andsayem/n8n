import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../common/admob_helper.dart';
import '../../presentation/controllers/purchase_controller.dart';

/// Self-loading 300x250 (medium rectangle) banner.
///
/// Placed as the second section of every page so it is visible without
/// scrolling. Collapses when the user removed ads or the request failed.
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
  bool _loading = true;

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
    setState(() {
      _ad = ad;
      _loading = false;
    });
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
      if (removed || (!_loading && _ad == null)) {
        return const SizedBox.shrink();
      }
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Padding(
        padding: widget.padding,
        child: Center(
          child: Container(
            width: 300,
            height: 250,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C22) : const Color(0xFFF4F4F5),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: _ad == null
                ? const Center(
                    child: Text('Ad',
                        style: TextStyle(fontSize: 11, color: Colors.grey)))
                : AdWidget(ad: _ad!),
          ),
        ),
      );
    });
  }
}
