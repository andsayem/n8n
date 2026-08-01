import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/core/theme/app_theme.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> showPurchasePopup({bool showPreferenceButtons = true}) async {
  if (Get.isDialogOpen == true) return;

  final controller = Get.find<PurchaseController>();
  controller.selectedProduct.value = null;

  final result = await Get.dialog<String>(
    Dialog(
      backgroundColor: Colors.transparent,
      child: Obx(() {
        final isDark = Get.isDarkMode;
        final cardBg = isDark ? AppTheme.darkCard : Colors.white;
        final border = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
        final textColor =
            isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
        final mutedColor =
            isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

        final subscribed = controller.adsRemoved.value;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── HEADER ───────────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryColor, Color(0xFFFF4D8D)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Remove Ads',
                          style: Theme.of(Get.context!).textTheme.titleMedium
                              ?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ── BENEFITS ────────────────────────────────────────────
                  _benefit(Icons.block_rounded,
                      'Completely ad-free experience', isDark),
                  _benefit(Icons.bolt_rounded,
                      'No interruptions while working', isDark),
                  _benefit(Icons.lock_rounded,
                      'Safe and secure payments', isDark),
                  _benefit(Icons.autorenew_rounded,
                      'Flexible plans — cancel anytime', isDark),
                  const SizedBox(height: 16),

                  // ── BODY ────────────────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: subscribed
                        ? _success(isDark)
                        : _plans(controller, cardBg, border, textColor, mutedColor),
                  ),
                  const SizedBox(height: 16),

                  // ── FOOTER ──────────────────────────────────────────────
                  if (!subscribed)
                    _footer(controller, showPreferenceButtons, isDark, textColor)
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: () => Get.back(),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  if (result == 'later') {
    await prefs.setInt(
      'purchase_reminder_date',
      DateTime.now().millisecondsSinceEpoch,
    );
  } else if (result == 'dontask') {
    await prefs.setBool('hide_purchase_dialog', true);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SUCCESS
// ─────────────────────────────────────────────────────────────────────────────
Widget _success(bool isDark) {
  final subTextColor = isDark ? Colors.white70 : Colors.black54;
  return Column(
    key: const ValueKey('success'),
    children: [
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_circle_rounded,
            color: AppTheme.successColor, size: 40),
      ),
      const SizedBox(height: 10),
      const Text(
        'Ads Removed!',
        style: TextStyle(
          color: AppTheme.successColor,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Thank you for your support.',
        style: TextStyle(color: subTextColor),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PLANS
// ─────────────────────────────────────────────────────────────────────────────
Widget _plans(
  PurchaseController c,
  Color cardBg,
  Color border,
  Color textColor,
  Color mutedColor,
) {
  if (c.isLoading.value && c.availableProducts.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  if (c.availableProducts.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.warningColor, size: 28),
          const SizedBox(height: 8),
          Text(
            'No plans available right now.\nPlease try again later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: mutedColor),
          ),
        ],
      ),
    );
  }

  return Column(
    children: c.availableProducts.map((p) {
      final bestValue = p.id == 'yearly';
      final accent =
          bestValue ? AppTheme.primaryColor : AppTheme.accentColor;
      final period = p.id == 'yearly' ? '/year' : '/month';

      return Obx(() {
        final selected = c.selectedProduct.value?.id == p.id;
        return GestureDetector(
          onTap: () => c.selectProduct(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? accent : border,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? accent : Colors.transparent,
                    border: Border.all(
                      color: selected ? accent : border,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.title,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (bestValue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: const Text(
                                'POPULAR',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            p.price,
                            style: TextStyle(
                              color: selected ? accent : textColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (period.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 3,
                                bottom: 1,
                              ),
                              child: Text(
                                period,
                                style: TextStyle(
                                  color: mutedColor,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }).toList(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTER
// ─────────────────────────────────────────────────────────────────────────────
Widget _footer(
  PurchaseController c,
  bool showPref,
  bool isDark,
  Color textColor,
) {
  return Obx(() {
    final enabled = c.selectedProduct.value != null;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: enabled
                  ? const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFFFF4D8D)],
                    )
                  : null,
              color: enabled ? null : Colors.grey.withValues(alpha: 0.3),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: enabled ? c.purchaseProduct : null,
                child: Center(
                  child: c.isLoading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Subscribe Now',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: c.restorePurchase,
          child: Text(
            'Restore Purchase',
            style: TextStyle(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (showPref)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Get.back(result: 'later'),
                child: Text(
                  'Later',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(result: 'dontask'),
                child: Text(
                  "Don't show",
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// BENEFIT
// ─────────────────────────────────────────────────────────────────────────────
Widget _benefit(IconData icon, String text, bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              fontSize: 13,
            ),
          ),
        ),
        const Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: AppTheme.successColor,
        ),
      ],
    ),
  );
}
