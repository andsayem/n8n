import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/audit/data/models/audit_entry.dart';
import 'package:n8n_manager/core/theme/app_theme.dart';
import 'package:n8n_manager/core/utils/app_utils.dart';
import 'package:n8n_manager/presentation/widgets/common_widgets.dart';
import '../controllers/activity_controller.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late final ActivityController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(ActivityController());
  }

  @override
  void dispose() {
    Get.delete<ActivityController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            title: const Text('Activity Log'),
            actions: [
              IconButton(
                tooltip: 'Clear history',
                onPressed: _confirmClear,
                icon: const Icon(Icons.delete_sweep_rounded, size: 20),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    _SearchBar(controller: _ctrl),
                    const SizedBox(height: 8),
                    _FilterChips(controller: _ctrl),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Obx(() {
          if (_ctrl.filteredEntries.isEmpty) {
            return EmptyStateWidget(
              title: _ctrl.entries.isEmpty
                  ? 'No Activity Yet'
                  : 'No Results Found',
              subtitle: _ctrl.entries.isEmpty
                  ? 'Actions you take on workflows, folders and tables are logged here.'
                  : 'Try different filters or search terms.',
              icon: Icons.history_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _ctrl.filteredEntries.length,
            itemBuilder: (context, index) =>
                _ActivityCard(entry: _ctrl.filteredEntries[index], index: index),
          );
        }),
      ),
    );
  }

  void _confirmClear() {
    if (_ctrl.entries.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Activity Log?'),
        content: const Text('This removes the local audit history from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.clear();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ActivityController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.setSearch,
      decoration: InputDecoration(
        hintText: 'Search activity...',
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

class _FilterChips extends StatelessWidget {
  final ActivityController controller;

  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    const types = [
      ('all', 'All'),
      ('workflow', 'Workflows'),
      ('folder', 'Folders'),
      ('table', 'Tables'),
    ];

    return Obx(() {
      final selectedType = controller.filterType.value;
      return SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: types.map((t) {
            final isSelected = selectedType == t.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.setType(t.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      t.$2,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
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

class _ActivityCard extends StatelessWidget {
  final AuditEntry entry;
  final int index;

  const _ActivityCard({required this.entry, required this.index});

  (IconData, Color) get _actionStyle {
    switch (entry.action) {
      case AuditAction.activated:
        return (Icons.play_circle_rounded, AppTheme.successColor);
      case AuditAction.deactivated:
        return (Icons.pause_circle_rounded, AppTheme.warningColor);
      case AuditAction.ran:
        return (Icons.bolt_rounded, AppTheme.accentColor);
      case AuditAction.movedToFolder:
        return (Icons.drive_file_move_rounded, AppTheme.primaryColor);
      case AuditAction.created:
        return (Icons.add_circle_rounded, AppTheme.successColor);
      case AuditAction.updated:
        return (Icons.edit_rounded, AppTheme.primaryColor);
      case AuditAction.renamed:
        return (Icons.drive_file_rename_outline_rounded, AppTheme.accentColor);
      case AuditAction.deleted:
        return (Icons.delete_rounded, AppTheme.errorColor);
      default:
        return (Icons.radio_button_unchecked_rounded, AppTheme.darkTextMuted);
    }
  }

  IconData get _targetIcon {
    switch (entry.targetType) {
      case AuditTarget.folder:
        return Icons.folder_rounded;
      case AuditTarget.table:
        return Icons.table_chart_rounded;
      default:
        return Icons.account_tree_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (actionIcon, actionColor) = _actionStyle;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkBorder
              : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(actionIcon, size: 20, color: actionColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_targetIcon,
                        size: 13,
                        color: Theme.of(context).textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.title,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  entry.detail == null || entry.detail == 'Root'
                      ? entry.targetName
                      : '${entry.targetName} → ${entry.detail}',
                  style: Theme.of(context).textTheme.labelSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppUtils.timeAgo(entry.timestamp.toIso8601String()),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}