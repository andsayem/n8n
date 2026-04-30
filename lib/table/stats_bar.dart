import 'package:flutter/material.dart' hide TableRow;
import 'package:get/get.dart';
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';

class StatsBar extends StatelessWidget {
  final DataTableDetailController ctrl;
  final DataTableModel table;
  const StatsBar({super.key, required this.ctrl, required this.table});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Total Rows',
              value: '${ctrl.rows.length}',
              color: AppTheme.primaryColor,
            ),
            Container(width: 1, height: 30, color: AppTheme.darkBorder),
            _StatItem(
              label: 'Filtered',
              value: '${ctrl.filteredRows.length}',
              color: AppTheme.accentColor,
            ),
            Container(width: 1, height: 30, color: AppTheme.darkBorder),
            _StatItem(
              label: 'Columns',
              value: '${table.columns.length}',
              color: AppTheme.warningColor,
            ),
            Container(width: 1, height: 30, color: AppTheme.darkBorder),
            _StatItem(
              label: 'Page',
              value: '${ctrl.currentPage.value + 1}/${ctrl.totalPages}',
              color: AppTheme.darkTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          Text(label,
              style: const TextStyle(
                  color: AppTheme.darkTextMuted, fontSize: 10)),
        ],
      );
}
