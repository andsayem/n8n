import 'package:flutter/material.dart' hide TableRow;
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';

class ColumnTile extends StatelessWidget {
  final TableColumn col;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ColumnTile({
    super.key,
    required this.col,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const typeColors = {
      ColumnType.text: AppTheme.accentColor,
      ColumnType.number: AppTheme.warningColor,
      ColumnType.boolean: AppTheme.successColor,
      ColumnType.date: AppTheme.primaryColor,
      ColumnType.select: Color(0xFF9B59B6),
    };
    final color = typeColors[col.type] ?? AppTheme.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _colTypeIcon(col.type, color),
        ),
        title: Row(
          children: [
            Text(
              col.name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color,
                  ),
            ),
            if (col.required) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'required',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          col.type == ColumnType.select
              ? 'Select: ${col.options.take(3).join(", ")}${col.options.length > 3 ? "..." : ""}'
              : TableColumn.typeLabel(col.type),
          style: const TextStyle(
              fontSize: 11, color: AppTheme.darkTextMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_rounded,
                  size: 16, color: AppTheme.primaryColor),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded,
                  size: 16, color: AppTheme.errorColor),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const Icon(Icons.drag_handle_rounded,
                color: AppTheme.darkTextMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _colTypeIcon(ColumnType t, Color color) {
    const icons = {
      ColumnType.text: Icons.text_fields_rounded,
      ColumnType.number: Icons.numbers_rounded,
      ColumnType.boolean: Icons.toggle_on_rounded,
      ColumnType.date: Icons.calendar_today_rounded,
      ColumnType.select: Icons.list_rounded,
    };
    return Icon(icons[t] ?? Icons.text_fields_rounded,
        size: 16, color: color);
  }
}
