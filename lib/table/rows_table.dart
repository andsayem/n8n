import 'package:flutter/material.dart' hide TableRow;
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
import 'package:n8n_manager/presentation/widgets/common_widgets.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';

class RowsTable extends StatelessWidget {
  final DataTableDetailController ctrl;
  final DataTableModel table;
  final void Function(TableRow) onEdit;
  final void Function(TableRow) onDelete;

  const RowsTable({
    super.key,
    required this.ctrl,
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageRows = ctrl.currentPageRows;

    if (pageRows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('No rows found',
              style: TextStyle(color: AppTheme.darkTextMuted)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: ctrl.sortColIndex.value < table.columns.length
                ? ctrl.sortColIndex.value
                : null,
            sortAscending: ctrl.sortAscending.value,
            headingRowColor: WidgetStateProperty.all(
              isDark ? AppTheme.darkBg : Colors.grey.shade50,
            ),
            dividerThickness: 0.5,
            columnSpacing: 20,
            horizontalMargin: 14,
            headingTextStyle: TextStyle(
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : Colors.grey.shade700,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
            dataTextStyle: TextStyle(
              color: isDark
                  ? AppTheme.darkTextPrimary
                  : AppTheme.lightTextPrimary,
              fontSize: 13,
            ),
            columns: [
              ...table.columns.asMap().entries.map(
                    (e) => DataColumn(
                      label: Text(e.value.name.toUpperCase()),
                      onSort: (i, asc) => ctrl.setSort(i, asc),
                    ),
                  ),
              const DataColumn(label: Text('')),
            ],
            rows: pageRows
                .map(
                  (row) => DataRow(
                    cells: [
                      ...table.columns.map((col) {
                        final val = row.data[col.id];
                        return DataCell(_CellValue(col: col, value: val));
                      }),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => onEdit(row),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.edit_rounded,
                                    size: 15,
                                    color: AppTheme.primaryColor),
                              ),
                            ),
                            InkWell(
                              onTap: () => onDelete(row),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.delete_rounded,
                                    size: 15, color: AppTheme.errorColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _CellValue extends StatelessWidget {
  final TableColumn col;
  final dynamic value;
  const _CellValue({required this.col, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return const Text('—', style: TextStyle(color: AppTheme.darkTextMuted));
    }
    switch (col.type) {
      case ColumnType.boolean:
        final v = value == true || value == 'true';
        return Icon(
          v ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 18,
          color: v ? AppTheme.successColor : AppTheme.errorColor,
        );
      case ColumnType.select:
        return StatusBadge(status: value.toString(), fontSize: 10);
      case ColumnType.number:
        return Text(value.toString(),
            style: const TextStyle(fontFamily: 'monospace'));
      default:
        return Text(value.toString(),
            overflow: TextOverflow.ellipsis, maxLines: 1);
    }
  }
}
