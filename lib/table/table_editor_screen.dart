import 'package:flutter/material.dart' hide TableRow;
import 'package:get/get.dart';
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
import 'package:n8n_manager/table/column_tile.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';
import 'column_editor_sheet.dart';

class TableEditorScreen extends StatefulWidget {
  final DataTableModel? existing;
  const TableEditorScreen({super.key, this.existing});

  @override
  State<TableEditorScreen> createState() => _TableEditorScreenState();
}

class _TableEditorScreenState extends State<TableEditorScreen> {
  late final DataTableEditController _ctrl;

  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(DataTableEditController());
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _descCtrl.text = widget.existing!.description;
      _ctrl.loadFromTable(widget.existing!);
    } else {
      _ctrl.columns.value = [
        TableColumn(
          id: const Uuid().v4(),
          name: 'Name',
          type: ColumnType.text,
          required: true,
        ),
        TableColumn(
          id: const Uuid().v4(),
          name: 'Status',
          type: ColumnType.select,
          options: ['Active', 'Inactive'],
        ),
      ];
    }
  }

  @override
  void dispose() {
    Get.delete<DataTableEditController>();
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    DataTableModel? result;
    if (widget.existing == null) {
      result = await _ctrl.createTable(_nameCtrl.text, _descCtrl.text);
    } else {
      result = await _ctrl.updateTable(
        widget.existing!,
        _nameCtrl.text,
        _descCtrl.text,
      );
    }

    if (result != null && mounted) {
      Get.back(result: true);
      Get.snackbar(
        widget.existing == null ? '✅ Table Created' : '✅ Table Updated',
        '"${result.name}" saved successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.successColor.withValues(alpha: 0.15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.existing == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Table' : 'Edit Schema'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => _ctrl.isSaving.value
                ? const Padding(
                    padding: EdgeInsets.all(14),
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
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text('Save'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Error banner
            Obx(() {
              if (_ctrl.errorMessage.value.isEmpty)
                return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _ctrl.errorMessage.value,
                  style:
                      const TextStyle(color: AppTheme.errorColor, fontSize: 13),
                ),
              );
            }),

            // Table info card
            _SchemaCard(
              title: 'Table Info',
              icon: Icons.info_outline_rounded,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Table Name',
                    hintText: 'e.g. Customers, Orders...',
                    prefixIcon: Icon(Icons.table_chart_rounded),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'What is this table for?',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  maxLines: 2,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  'Columns',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showAddColumnSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Column'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(
              () => ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _ctrl.columns.length,
                onReorder: _ctrl.reorderColumns,
                itemBuilder: (ctx, i) {
                  final col = _ctrl.columns[i];
                  return ColumnTile(
                    key: ValueKey(col.id),
                    col: col,
                    index: i,
                    onEdit: () => _showEditColumnSheet(context, col),
                    onDelete: () => _ctrl.removeColumn(col.id),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showAddColumnSheet(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        color: AppTheme.primaryColor, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Add Column',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showAddColumnSheet(BuildContext context) =>
      _showColumnSheet(context, null);

  void _showEditColumnSheet(BuildContext context, TableColumn col) =>
      _showColumnSheet(context, col);

  void _showColumnSheet(BuildContext context, TableColumn? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ColumnEditorSheet(
          existing: existing,
          onSave: (col) {
            if (existing == null) {
              _ctrl.addColumn(col);
            } else {
              _ctrl.updateColumn(col);
            }
          },
        ),
      ),
    );
  }
}

// ── Shared card wrapper ───────────────────────────────────────────────────────
class _SchemaCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SchemaCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}
