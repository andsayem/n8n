import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import '../../core/theme/app_theme.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  static const _planFeatures = <String, List<String>>{
    'monthly': [
      'Ad-free experience',
      'Unlimited workflows',
      'Cancel anytime',
    ],
    'yearly': [
      'Everything in Monthly',
      '2 months free',
      'Priority support',
    ],
  };

  static const _planPeriod = <String, String>{
    'monthly': '/month',
    'yearly': '/year',
  };

  bool _isBestValue(dynamic p) => p.id == 'yearly';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('n8n Premium'),
        centerTitle: true,
      ),
      body: Obx(() {
        final controller = Get.find<PurchaseController>();
        final subscribed = controller.adsRemoved.value;

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              _Header(isDark: isDark),
              const SizedBox(height: 16),
              if (subscribed)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSubscribed(context, isDark),
                  ),
                )
              else ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProductList(
                        context, controller, isDark, mutedColor),
                  ),
                ),
                _buildSubscribeButton(context, controller, isDark),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSubscribed(BuildContext context, bool isDark) {
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.successColor.withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppTheme.successColor, size: 40),
            ),
            const SizedBox(height: 12),
            const Text(
              'You are Premium!',
              style: TextStyle(
                color: AppTheme.successColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enjoy an ad-free experience.',
              textAlign: TextAlign.center,
              style: TextStyle(color: subTextColor),
            ),
            const SizedBox(height: 16),
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
    );
  }

  Widget _buildProductList(
    BuildContext context,
    PurchaseController controller,
    bool isDark,
    Color mutedColor,
  ) {
    final cardBg = isDark ? AppTheme.darkCard : Colors.white;
    final border = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;

    if (controller.isLoading.value && controller.availableProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.availableProducts.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppTheme.warningColor, size: 28),
              const SizedBox(height: 8),
              Text(
                'No plans available right now.\nPlease try again later.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CHOOSE YOUR PLAN',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                letterSpacing: 1.3,
                fontWeight: FontWeight.w800,
                color: mutedColor,
              ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: controller.availableProducts.map((p) {
              final features = _planFeatures[p.id] ?? ['Ad-free experience'];
              final period = _planPeriod[p.id] ?? '';
              final bestValue = _isBestValue(p);
              final accent =
                  bestValue ? AppTheme.primaryColor : AppTheme.accentColor;

              return Obx(() {
                final selected = controller.selectedProduct.value?.id == p.id;
                return GestureDetector(
                  onTap: () => controller.selectProduct(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected ? accent : border,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: textColor,
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
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.12),
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
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              p.price,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            if (period.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 2, left: 3),
                                child: Text(
                                  period,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ...features.map(
                          (f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 15, color: accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    f,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(height: 1.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(
    BuildContext context,
    PurchaseController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final enabled = controller.selectedProduct.value != null;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: enabled
                        ? const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              Color(0xFFFF4D8D),
                            ],
                          )
                        : null,
                    color: enabled ? null : Colors.grey.withValues(alpha: 0.3),
                    boxShadow: enabled
                        ? [
                            BoxShadow(
                              color:
                                  AppTheme.primaryColor.withValues(alpha: 0.3),
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
                      onTap: enabled ? controller.purchaseProduct : null,
                      child: Center(
                        child: controller.isLoading.value
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
                onPressed: controller.restorePurchase,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  'Restore Purchase',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final mutedColor =
        isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, Color(0xFFFF4D8D)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Go Premium',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Unlock the full experience',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: mutedColor),
        ),
      ],
    );
  }
}
