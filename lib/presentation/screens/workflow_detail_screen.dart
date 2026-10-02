import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/folders/modules/folders/controllers/folder_controller.dart';
import 'package:n8n_manager/folders/modules/folders/views/folder_picker_sheet.dart';
import 'package:n8n_manager/presentation/controllers/workflow__details_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/workflow_model.dart';
import '../widgets/common_widgets.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/widgets/medium_rect_ad.dart';
import '../../tag/modules/tags/controllers/tag_controller.dart';
import '../../tools/widgets/tool_widgets.dart';

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
                    const MediumRectAd(padding: EdgeInsets.symmetric(vertical: 16)),
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
          if (wf.parentFolderId != null)
            InfoRow(
              label: 'Folder',
              value: _folderNameOf(wf.parentFolderId!) ?? wf.parentFolderId!,
            ),
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

  String? _folderNameOf(String id) {
    try {
      return Get.find<FolderController>()
          .folders
          .where((f) => f.id == id)
          .firstOrNull
          ?.name;
    } catch (_) {
      return null;
    }
  }

  Future<void> _moveToFolder(WorkflowModel wf) async {
    final result = await showFolderPickerSheet(
      context,
      currentFolderId: wf.parentFolderId,
    );
    if (result == null) return;
    await _controller.moveToFolder(
      result.root ? null : result.folder?.id,
      result.folder,
    );
  }

  Future<void> _duplicate(WorkflowModel wf) async {
    final values = await showFormSheet(
      title: 'Duplicate workflow',
      fields: [FormFieldSpec('New name', initial: '${wf.name} (copy)')],
      submit: 'Duplicate',
    );
    if (values == null) return;
    await runAction(() => _controller.duplicate(values[0]),
        success: 'Created "${values[0]}" (inactive)');
  }

  Future<void> _export() async {
    final json = await runWithProgress(_controller.exportJson);
    if (json == null) return;
    await SharePlus.instance.share(ShareParams(
        text: json, subject: '${_controller.workflow.value?.name}.json'));
  }

  Future<void> _delete(WorkflowModel wf) async {
    if (!await confirmDialog('Delete workflow',
        'Permanently delete "${wf.name}" and its execution history?')) {
      return;
    }
    final ok = await runAction(_controller.delete, success: 'Workflow deleted');
    // Navigator, not Get.back(): Get.back() would close the snackbar first.
    if (ok && mounted) Navigator.of(context).pop();
  }

  Future<void> _editTags(WorkflowModel wf) async {
    final tagCtrl = Get.find<TagController>();
    if (tagCtrl.tags.isEmpty) await tagCtrl.loadTags();
    final all = tagCtrl.tags.toList();
    if (all.isEmpty) {
      toolToast('Create tags first in Settings > Tags', error: true);
      return;
    }
    final selected = all.where((t) => wf.tags.contains(t.name)).map((t) => t.id).toSet();
    final result = await Get.bottomSheet<Set<String>>(
      StatefulBuilder(builder: (context, setSheet) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, 20 + MediaQuery.of(context).viewPadding.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Workflow tags',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: all
                    .map((t) => FilterChip(
                          label: Text(t.name),
                          selected: selected.contains(t.id),
                          selectedColor:
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                          onSelected: (v) => setSheet(() => v
                              ? selected.add(t.id)
                              : selected.remove(t.id)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(result: selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Save tags'),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
    if (result == null) return;
    final names = all.where((t) => result.contains(t.id)).map((t) => t.name).toList();
    await runAction(() => _controller.setTags(result.toList(), names),
        success: 'Tags updated');
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
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Move to Folder',
                icon: Icons.drive_file_move_rounded,
                color: AppTheme.accentColor,
                isLoading: isActing,
                onTap: () => _moveToFolder(wf),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'Edit Tags',
                icon: Icons.label_rounded,
                color: const Color(0xFF7C6CFF),
                isLoading: isActing,
                onTap: () => _editTags(wf),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Duplicate',
                icon: Icons.copy_all_rounded,
                color: const Color(0xFF2496ED),
                isLoading: isActing,
                onTap: () => _duplicate(wf),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label: 'Export JSON',
                icon: Icons.ios_share_rounded,
                color: AppTheme.successColor,
                isLoading: isActing,
                onTap: _export,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ActionButton(
          label: 'Delete Workflow',
          icon: Icons.delete_forever_rounded,
          color: AppTheme.errorColor,
          isLoading: isActing,
          onTap: () => _delete(wf),
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
