import 'package:flutter/material.dart' hide TableRow;
import 'package:get/get.dart';
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
import 'package:n8n_manager/table/field_editor.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';

class RowEditorSheet extends StatefulWidget {
  final DataTableModel table;
  final TableRow? existing;
  final DataTableDetailController ctrl;

  const RowEditorSheet({
    super.key,
    required this.table,
    required this.existing,
    required this.ctrl,
  });

  @override
  State<RowEditorSheet> createState() => _RowEditorSheetState();
}

class _RowEditorSheetState extends State<RowEditorSheet> {
  late final DataTableDetailController _ctrl;

  late Map<String, dynamic> _values;
  final Map<String, TextEditingController> _textCtrls = {};

  @override
  void initState() {
    super.initState();
    _ctrl = widget.ctrl;
    _values = {};
    for (final col in widget.table.columns) {
      _values[col.id] = widget.existing?.data[col.id];
      if (col.type == ColumnType.text ||
          col.type == ColumnType.number ||
          col.type == ColumnType.date) {
        _textCtrls[col.id] = TextEditingController(
          text: widget.existing?.data[col.id]?.toString() ?? '',
        );
      }
    }
  }

  @override
  void dispose() {
    for (final c in _textCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    for (final col in widget.table.columns) {
      if (_textCtrls.containsKey(col.id)) {
        final raw = _textCtrls[col.id]!.text.trim();
        if (col.type == ColumnType.number) {
          _values[col.id] = num.tryParse(raw) ?? raw;
        } else {
          _values[col.id] = raw.isEmpty ? null : raw;
        }
      }
    }

    bool ok;
    if (widget.existing == null) {
      ok = await _ctrl.createRow(Map.from(_values));
    } else {
      ok = await _ctrl.updateRow(widget.existing!.id, Map.from(_values));
    }

    if (ok && mounted) {
      Navigator.pop(context);
      Get.snackbar(
        widget.existing == null ? '✅ Row Added' : '✅ Row Updated',
        widget.existing == null
            ? 'New row created successfully.'
            : 'Row updated.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.successColor.withValues(alpha: 0.15),
        duration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(
              children: [
                Text(
                  isEdit ? 'Edit Row' : 'Add Row',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                Obx(
                  () => _ctrl.isSaving.value
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      : TextButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.save_rounded, size: 16),
                          label: Text(isEdit ? 'Update' : 'Save'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(20),
              children: widget.table.columns.map((col) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: FieldEditor(
                    col: col,
                    value: _values[col.id],
                    textCtrl: _textCtrls[col.id],
                    onChanged: (v) => setState(() => _values[col.id] = v),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
