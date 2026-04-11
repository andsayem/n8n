import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/execution_model.dart';
import '../controllers/execution_controller.dart';
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
     AdmobHelper.loadInterstitialAd();

      // ⚠️ delay banner load (important)
      Future.delayed(const Duration(seconds: 1), () async {
        if (!mounted) return;

        final width = MediaQuery.of(context).size.width.toInt();
        final ad = await AdmobHelper.loadBannerAd(
          size: AdSize(width: width - 27, height: 220),
        );
        if (!mounted) return;

        setState(() {
          _bannerAd = ad;
        });
      });
 
  }
  Widget build(BuildContext context) {
    final controller = Get.find<ExecutionController>();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Executions'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: _FilterRow(controller: controller),
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

          if (controller.executions.isEmpty) {
            return const EmptyStateWidget(
              title: 'No Executions',
              subtitle: 'Run a workflow to see executions here.',
              icon: Icons.history_rounded,
            );
          }

          return Column(
            children: [
                  if (_bannerAd != null)
                Container(
                  width: double.infinity,
                  height: _bannerAd!.size.height.toDouble(),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _bannerAd!),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchExecutions,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.executions.length,
                    itemBuilder: (context, i) {
                      return _ExecutionCard(
                        execution: controller.executions[i],
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

class _FilterRow extends StatelessWidget {
  final ExecutionController controller;

  const _FilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'success', 'error', 'running'];
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters
                .map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f.capitalize!),
                        selected: controller.filterStatus.value == f,
                        onSelected: (_) => controller.setFilter(f),
                        selectedColor: AppUtils.statusColor(f == 'all' ? 'running' : f),
                        labelStyle: TextStyle(
                          color: controller.filterStatus.value == f
                              ? Colors.white
                              : Theme.of(context).textTheme.labelMedium?.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: controller.filterStatus.value == f
                              ? AppUtils.statusColor(f == 'all' ? 'running' : f)
                              : AppTheme.darkBorder,
                        ),
                        backgroundColor: Theme.of(context).cardColor,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                    ))
                .toList(),
          ),
        ));
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(AppUtils.statusIcon(execution.status), color: statusColor, size: 20),
            ),
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
                  const SizedBox(height: 3),
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
        .slideX(begin: 0.1, end: 0);
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
                  child: SkeletonLoader(height: 60 + i * 10.0, borderRadius: 12),
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
            InfoRow(label: 'Started', value: AppUtils.formatDate(exec.startedAt)),
          if (exec.stoppedAt != null)
            InfoRow(label: 'Finished', value: AppUtils.formatDate(exec.stoppedAt)),
          if (exec.executionTime != null)
            InfoRow(label: 'Duration', value: AppUtils.formatDuration(exec.executionTime)),
          if (exec.mode != null)
            InfoRow(label: 'Mode', value: exec.mode!),
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
                color: isDark ? AppTheme.darkTextSecondary : Colors.grey.shade800,
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
