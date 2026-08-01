import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/execution_model.dart';
import '../controllers/execution_controller.dart';
import '../widgets/banner_ad_view.dart';
import '../widgets/common_widgets.dart';

// ─── Execution List ──────────────────────────────────────────────────────────
class ExecutionListScreen extends StatefulWidget {
  const ExecutionListScreen({super.key});

  @override
  State<ExecutionListScreen> createState() => _ExecutionListScreenState();
}

class _ExecutionListScreenState extends State<ExecutionListScreen> {
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    _initAdd();
  }

  Future<void> _initAdd() async {
    // ✅ SKIP all ad loading if user has subscription
    try {
      final purchaseCtrl = Get.find<PurchaseController>();
      if (purchaseCtrl.adsRemoved.value) return;
    } catch (_) {}

    AdmobHelper.loadInterstitialAd();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      // Double-check subscription after delay
      final purchaseCtrl = Get.find<PurchaseController>();
      if (purchaseCtrl.adsRemoved.value) return;

      final width = MediaQuery.of(context).size.width.toInt();

      final ad = await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 50, height: 220),
      );

      if (!mounted) return;

      setState(() {
        _bannerAd = ad;
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
    final controller = Get.find<ExecutionController>();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            title: const Text('Executions'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    _SearchBar(controller: controller),
                    const SizedBox(height: 10),
                    _FilterTabs(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Obx(() {
          if (controller.isLoading.value) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonLoader(height: 76, borderRadius: 12),
              ),
            );
          }

          if (controller.hasError.value) {
            return ErrorRetryWidget(
              message: controller.errorMessage.value,
              onRetry: controller.fetchExecutions,
            );
          }

          if (controller.filteredExecutions.isEmpty) {
            return EmptyStateWidget(
              title: controller.searchQuery.value.isNotEmpty
                  ? 'No Results Found'
                  : 'No Executions',
              subtitle: controller.searchQuery.value.isNotEmpty
                  ? 'Try a different search term.'
                  : 'Run a workflow to see executions here.',
              icon: Icons.history_rounded,
            );
          }

          return Column(
            children: [
              BannerAdView(ad: _bannerAd),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchExecutions,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.filteredExecutions.length,
                    itemBuilder: (context, i) {
                      return _ExecutionCard(
                        execution: controller.filteredExecutions[i],
                        index: i,
                      );
                    },
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

class _SearchBar extends StatelessWidget {
  final ExecutionController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.setSearch,
      decoration: InputDecoration(
        hintText: 'Search executions...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () => controller.setSearch(''),
              )
            : const SizedBox.shrink()),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final ExecutionController controller;

  const _FilterTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', 'All'),
      ('success', 'Success'),
      ('error', 'Error'),
      ('running', 'Running'),
    ];

    return Obx(() {
      final selected = controller.filterStatus.value;
      return Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: filters.map((f) {
            final isSelected = selected == f.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setFilter(f.$1),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.labelMedium?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _ExecutionCard extends StatelessWidget {
  final ExecutionModel execution;
  final int index;

  const _ExecutionCard({required this.execution, required this.index});

  @override
  Widget build(BuildContext context) {
    final statusColor = AppUtils.statusColor(execution.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.executionDetail, arguments: execution),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(AppUtils.statusIcon(execution.status),
                  color: statusColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    execution.workflowName ?? 'Unknown Workflow',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '#${execution.id}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(width: 8),
                      const Text('·'),
                      const SizedBox(width: 8),
                      Text(
                        AppUtils.timeAgo(execution.startedAt),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      if (execution.executionTime != null) ...[
                        const SizedBox(width: 8),
                        const Text('·'),
                        const SizedBox(width: 8),
                        Text(
                          AppUtils.formatDuration(execution.executionTime),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: execution.status, fontSize: 10),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 40))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.15, end: 0);
  }
}

// ─── Execution Detail ────────────────────────────────────────────────────────
class ExecutionDetailScreen extends StatefulWidget {
  const ExecutionDetailScreen({super.key});

  @override
  State<ExecutionDetailScreen> createState() => _ExecutionDetailScreenState();
}

class _ExecutionDetailScreenState extends State<ExecutionDetailScreen> {
  late ExecutionDetailController _controller;
  late ExecutionModel _preview;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ExecutionDetailController());
    _preview = Get.arguments as ExecutionModel;
    _controller.loadExecution(_preview.id);
  }

  @override
  void dispose() {
    Get.delete<ExecutionDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Execution Detail'),
            Text(
              '#${_preview.id}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final exec = _controller.execution.value ?? _preview;

        if (_controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child:
                      SkeletonLoader(height: 60 + i * 10.0, borderRadius: 12),
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(context, exec),
              const SizedBox(height: 20),
              _buildDataSection(context, exec),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ExecutionModel exec) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkBorder
              : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exec.workflowName ?? 'Unknown Workflow',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              StatusBadge(status: exec.status),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          InfoRow(label: 'Execution ID', value: exec.id),
          if (exec.workflowId != null)
            InfoRow(label: 'Workflow ID', value: exec.workflowId!),
          InfoRow(
            label: 'Status',
            value: exec.status,
            valueColor: AppUtils.statusColor(exec.status),
          ),
          if (exec.startedAt != null)
            InfoRow(
                label: 'Started', value: AppUtils.formatDate(exec.startedAt)),
          if (exec.stoppedAt != null)
            InfoRow(
                label: 'Finished', value: AppUtils.formatDate(exec.stoppedAt)),
          if (exec.executionTime != null)
            InfoRow(
                label: 'Duration',
                value: AppUtils.formatDuration(exec.executionTime)),
          if (exec.mode != null) InfoRow(label: 'Mode', value: exec.mode!),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildDataSection(BuildContext context, ExecutionModel exec) {
    if (exec.data == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.darkBorder
                : AppTheme.lightBorder,
          ),
        ),
        child: const Center(
          child: Text('No execution data available'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Execution Data',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _JsonViewer(data: exec.data!),
      ],
    ).animate().fadeIn(delay: 150.ms, duration: 300.ms);
  }
}

class _JsonViewer extends StatefulWidget {
  final Map<String, dynamic> data;

  const _JsonViewer({required this.data});

  @override
  State<_JsonViewer> createState() => _JsonViewerState();
}

class _JsonViewerState extends State<_JsonViewer> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prettyJson = const JsonEncoder.withIndent('  ').convert(widget.data);
    final preview = prettyJson.length > 300
        ? '${prettyJson.substring(0, 300)}\n...'
        : prettyJson;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkBg : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              _expanded ? prettyJson : preview,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color:
                    isDark ? AppTheme.darkTextSecondary : Colors.grey.shade800,
                height: 1.6,
              ),
            ),
          ),
          if (prettyJson.length > 300)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    _expanded ? 'Show Less' : 'Show More',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
