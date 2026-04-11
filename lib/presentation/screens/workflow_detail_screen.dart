import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/workflow_model.dart';
import '../controllers/workflow_controller.dart';
import '../widgets/common_widgets.dart';

class WorkflowDetailScreen extends StatefulWidget {
  const WorkflowDetailScreen({super.key});

  @override
  State<WorkflowDetailScreen> createState() => _WorkflowDetailScreenState();
}

class _WorkflowDetailScreenState extends State<WorkflowDetailScreen> {
  late WorkflowDetailController _controller;
  late WorkflowModel _previewWorkflow;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(WorkflowDetailController());
    _previewWorkflow = Get.arguments as WorkflowModel;
    _controller.loadWorkflow(_previewWorkflow.id);
  }

  @override
  void dispose() {
    Get.delete<WorkflowDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final wf = _controller.workflow.value ?? _previewWorkflow;
        final isLoading = _controller.isLoading.value;
        final isActing = _controller.isActing.value;

        return CustomScrollView(
          slivers: [
            _buildAppBar(context, wf, isActing),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (isLoading)
                    const _WorkflowDetailSkeleton()
                  else ...[
                    _buildStatusBanner(context, wf),
                    const SizedBox(height: 20),
                    _buildInfoCard(context, wf),
                    const SizedBox(height: 20),
                    _buildActionButtons(context, wf, isActing),
                    const SizedBox(height: 20),
                    _buildNodesCard(context, wf),
                    const SizedBox(height: 80),
                  ],
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(BuildContext context, WorkflowModel wf, bool isActing) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          wf.name,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
      ),
    );
  }

  Widget _buildStatusBanner(BuildContext context, WorkflowModel wf) {
    final color = wf.active ? AppTheme.successColor : AppTheme.darkTextMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            wf.active
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            wf.active ? 'Workflow is Active' : 'Workflow is Inactive',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildInfoCard(BuildContext context, WorkflowModel wf) {
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
          Text('Workflow Info',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          InfoRow(label: 'ID', value: wf.id),
          InfoRow(label: 'Node Count', value: '${wf.nodeCount}'),
          InfoRow(
              label: 'Created',
              value: AppUtils.formatDate(wf.createdAt.toIso8601String())),
          InfoRow(
              label: 'Updated',
              value: AppUtils.formatDate(wf.updatedAt.toIso8601String())),
          if (wf.tags.isNotEmpty)
            InfoRow(label: 'Tags', value: wf.tags.join(', ')),
          if (wf.lastExecutionStatus != null)
            InfoRow(
              label: 'Last Execution',
              value: wf.lastExecutionStatus!,
              valueColor: AppUtils.statusColor(wf.lastExecutionStatus),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildActionButtons(
      BuildContext context, WorkflowModel wf, bool isActing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Actions',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: wf.active ? 'Deactivate' : 'Activate',
                icon: wf.active
                    ? Icons.pause_circle_rounded
                    : Icons.play_circle_rounded,
                color:
                    wf.active ? AppTheme.warningColor : AppTheme.successColor,
                isLoading: isActing,
                onTap:
                    wf.active ? _controller.deactivate : _controller.activate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'Run Now',
                icon: Icons.bolt_rounded,
                color: AppTheme.primaryColor,
                isLoading: isActing,
                onTap: _controller.runNow,
              ),
            ),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildNodesCard(BuildContext context, WorkflowModel wf) {
    if (wf.nodes.isEmpty) return const SizedBox.shrink();

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
          Text('Nodes (${wf.nodeCount})',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...wf.nodes.take(10).toList().asMap().entries.map((entry) {
            final node = entry.value;
            final nodeMap =
                node is Map<String, dynamic> ? node : <String, dynamic>{};
            final name = nodeMap['name']?.toString() ?? 'Node ${entry.key + 1}';
            final type = nodeMap['type']?.toString() ?? '';
            final shortType = type.split('.').last;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkBg
                    : AppTheme.lightBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.widgets_rounded,
                        size: 14, color: AppTheme.accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color)),
                        if (shortType.isNotEmpty)
                          Text(shortType,
                              style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (wf.nodeCount > 10)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+${wf.nodeCount - 10} more nodes',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 300.ms)
        .slideY(begin: 0.1, end: 0);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 14),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _WorkflowDetailSkeleton extends StatelessWidget {
  const _WorkflowDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonLoader(height: 48, borderRadius: 12),
        SizedBox(height: 20),
        SkeletonLoader(height: 180, borderRadius: 16),
        SizedBox(height: 20),
        SkeletonLoader(height: 80, borderRadius: 12),
        SizedBox(height: 20),
        SkeletonLoader(height: 200, borderRadius: 16),
      ],
    );
  }
}
