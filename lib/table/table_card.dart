import 'package:flutter/material.dart' hide TableRow;
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/data_table_model.dart';

class TableCard extends StatelessWidget {
  final DataTableModel table;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TableCard({
    super.key,
    required this.table,
    required this.index,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.accentColor,
      AppTheme.warningColor,
      const Color(0xFF9B59B6),
    ];
    final accent = colors[index % colors.length];

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: accent,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.table_chart_rounded,
                        color: accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          table.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                        ),
                        if (table.description.isNotEmpty)
                          Text(
                            table.description,
                            style:
                                Theme.of(context).textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 16),
                            SizedBox(width: 8),
                            Text('Edit Schema'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded,
                                size: 16, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Delete',
                                style:
                                    TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  _Chip(
                    icon: Icons.view_column_rounded,
                    label: '${table.columns.length} columns',
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  _Chip(
                    icon: Icons.update_rounded,
                    label: AppUtils.timeAgo(
                        table.updatedAt.toIso8601String()),
                    color: AppTheme.darkTextMuted,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Open',
                          style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 13, color: accent),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 60))
          .fadeIn(duration: 350.ms)
          .slideY(begin: 0.12, end: 0),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
