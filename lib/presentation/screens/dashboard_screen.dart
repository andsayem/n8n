import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import 'package:n8n_manager/core/services/ads_service.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import 'package:n8n_manager/settings/purchase_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/execution_model.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _initAdd();
    _handleStartupLogic();
  }

  Future<void> _handleStartupLogic() async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final prefs = await SharedPreferences.getInstance();
      final removed = prefs.getBool('ads_removed') ?? false;

      final ads = Get.find<AdsService>(); // replace ref.read
      ads.loadAppOpenAd(
        adsShow: true,
        hasSubscription: removed,
      );
    } catch (_) {}

    await _handlePurchaseDialog();
  }

  Future<void> _handlePurchaseDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final removed = prefs.getBool('ads_removed') ?? false;
      final hideDialog = prefs.getBool('hide_purchase_dialog') ?? false;

      // ✅ SUBSCRIPTION CHECK (IMPORTANT)
      final controller = Get.find<PurchaseController>();
      final isSubscribed = controller.adsRemoved.value;

      if (hideDialog || removed || isSubscribed) return;

      final reminderDate = prefs.getInt('purchase_reminder_date');

      if (reminderDate != null) {
        final lastReminder = DateTime.fromMillisecondsSinceEpoch(reminderDate);

        final daysSinceReminder =
            DateTime.now().difference(lastReminder).inDays;

        if (daysSinceReminder < 7) return;

        await prefs.remove('purchase_reminder_date');
      }

      showPurchasePopup();
    } catch (_) {}
  }

  Future<void> _initAdd() async {
    AdmobHelper.loadInterstitialAd();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      final width = MediaQuery.of(context).size.width.toInt();

      final ad = await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 50, height: 220),
      );

      if (!mounted) return;

      setState(() {
        _bannerAd = ad; // শুধু এটুকুই যথেষ্ট
      });
    } catch (e) {
      debugPrint("Banner load error: $e");

      setState(() {
        _bannerAd = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    final auth = Get.find<AuthController>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.fetchDashboard,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.activeInstance.value?.name ?? 'Dashboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        auth.activeInstance.value?.baseUrl ?? '',
                        style: Theme.of(context).textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: controller.fetchDashboard,
                ),
              ],
            ),
            Obx(() {
              if (controller.hasError.value) {
                return SliverFillRemaining(
                  child: ErrorRetryWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchDashboard,
                  ),
                );
              }

              final stats = controller.stats.value;
              return SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildChartSection(context, stats),
                    const SizedBox(height: 8),
                    Obx(() {
                      final controller = Get.find<PurchaseController>();

                      final showBanner =
                          _bannerAd != null && !controller.adsRemoved.value;

                      if (!showBanner) return const SizedBox();

                      return SizedBox(
                        width: double.infinity,
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      );
                    }),
                    const SizedBox(height: 10),
                    _buildStatsGrid(context, stats),
                    const SizedBox(height: 10),
                    _buildSectionHeader(context, 'Recent Executions'),
                    const SizedBox(height: 12),
                    ...controller.recentExecutions
                        .asMap()
                        .entries
                        .map((e) => _ExecutionTile(
                              execution: e.value,
                              index: e.key,
                            )),
                    if (controller.recentExecutions.isEmpty)
                      const EmptyStateWidget(
                        title: 'No Recent Executions',
                        subtitle:
                            'Executions will appear here after workflows run.',
                        icon: Icons.history_rounded,
                      ),
                    const SizedBox(height: 80),
                  ]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, stats) {
    final cards = [
      _StatCard(
        title: 'Total Workflows',
        value: '${stats.totalWorkflows}',
        icon: Icons.account_tree_rounded,
        color: AppTheme.accentColor,
        index: 0,
      ),
      _StatCard(
        title: 'Active Workflows',
        value: '${stats.activeWorkflows}',
        icon: Icons.play_circle_rounded,
        color: AppTheme.successColor,
        index: 1,
      ),
      _StatCard(
        title: 'Failed Executions',
        value: '${stats.failedExecutions}',
        icon: Icons.cancel_rounded,
        color: AppTheme.errorColor,
        index: 2,
      ),
      _StatCard(
        title: 'Executions Today',
        value: '${stats.totalExecutionsToday}',
        icon: Icons.bolt_rounded,
        color: AppTheme.warningColor,
        index: 3,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: cards,
    );
  }

  Widget _buildChartSection(BuildContext context, stats) {
    if (stats.totalExecutionsToday == 0 && stats.failedExecutions == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkBorder
              : AppTheme.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, 'Execution Status Overview'),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: AppTheme.successColor,
                    value: stats.totalExecutionsToday > 0
                        ? stats.totalExecutionsToday.toDouble()
                        : 1,
                    title: 'Success\n${stats.totalExecutionsToday}',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppTheme.errorColor,
                    value: stats.failedExecutions > 0
                        ? stats.failedExecutions.toDouble()
                        : 0.1, // Show a sliver if 0 just for design
                    title: 'Failed\n${stats.failedExecutions}',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final int index;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

class _ExecutionTile extends StatelessWidget {
  final ExecutionModel execution;
  final int index;

  const _ExecutionTile({required this.execution, required this.index});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.statusColor(execution.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkBorder
              : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(AppUtils.statusIcon(execution.status),
              color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  execution.workflowName ?? 'Unknown Workflow',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '#${execution.id} · ${AppUtils.timeAgo(execution.startedAt)}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          StatusBadge(status: execution.status),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          children: List.generate(
              4, (_) => const SkeletonLoader(height: 120, borderRadius: 16)),
        ),
        const SizedBox(height: 24),
        const SkeletonLoader(height: 20, width: 150),
        const SizedBox(height: 12),
        ...List.generate(
            5,
            (_) => const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SkeletonLoader(height: 64, borderRadius: 12),
                )),
      ],
    );
  }
}
