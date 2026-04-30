import 'package:flutter/material.dart' hide TableRow;
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';

class ColumnEditorSheet extends StatefulWidget {
  final TableColumn? existing;
  final ValueChanged<TableColumn> onSave;

  const ColumnEditorSheet({
    super.key,
    required this.existing,
    required this.onSave,
  });

  @override
  State<ColumnEditorSheet> createState() => _ColumnEditorSheetState();
}

class _ColumnEditorSheetState extends State<ColumnEditorSheet> {
  final _nameCtrl = TextEditingController();
  final _optionCtrl = TextEditingController();
  ColumnType _type = ColumnType.text;
  bool _required = false;
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _nameCtrl.text = widget.existing!.name;
      _type = widget.existing!.type;
      _required = widget.existing!.required;
      _options = List.from(widget.existing!.options);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _optionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Column name is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    widget.onSave(
      TableColumn(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        type: _type,
        required: _required,
        options: _options,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.darkBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                widget.existing == null ? 'Add Column' : 'Edit Column',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              ElevatedButton(onPressed: _save, child: const Text('Save')),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Column Name',
              hintText: 'e.g. Email, Status...',
              prefixIcon: Icon(Icons.text_fields_rounded),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Type',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ColumnType.values
                .map(
                  (t) => ChoiceChip(
                    label: Text(TableColumn.typeLabel(t)),
                    selected: _type == t,
                    onSelected: (_) => setState(() {
                      _type = t;
                      if (t != ColumnType.select) _options = [];
                    }),
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: _type == t ? Colors.white : null,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: _type == t
                          ? AppTheme.primaryColor
                          : AppTheme.darkBorder,
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                  ),
                )
                .toList(),
          ),

          if (_type == ColumnType.select) ...[
            const SizedBox(height: 14),
            Text(
              'Options',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if (_options.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _options
                    .map(
                      (opt) => Chip(
                        label:
                            Text(opt, style: const TextStyle(fontSize: 12)),
                        deleteIcon:
                            const Icon(Icons.close_rounded, size: 14),
                        onDeleted: () =>
                            setState(() => _options.remove(opt)),
                        backgroundColor:
                            AppTheme.primaryColor.withValues(alpha: 0.1),
                        side: const BorderSide(
                            color: AppTheme.primaryColor, width: 0.5),
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _optionCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add option...',
                      isDense: true,
                      prefixIcon: Icon(Icons.add_rounded, size: 16),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() {
                          _options.add(v.trim());
                          _optionCtrl.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_optionCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _options.add(_optionCtrl.text.trim());
                        _optionCtrl.clear();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Required field',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(
                value: _required,
                onChanged: (v) => setState(() => _required = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
