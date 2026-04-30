// ── field_editor.dart ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart' hide TableRow;
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';
  
class FieldEditor extends StatelessWidget {
  final TableColumn col;
  final dynamic value;
  final TextEditingController? textCtrl;
  final ValueChanged<dynamic> onChanged;

  const FieldEditor({
    super.key,
    required this.col,
    required this.value,
    required this.textCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              const SizedBox(width: 4),
              const Text('*',
                  style: TextStyle(
                      color: AppTheme.errorColor, fontSize: 14)),
            ],
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                TableColumn.typeLabel(col.type),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildInput(context),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    switch (col.type) {
      case ColumnType.boolean:
        final v = value == true || value == 'true';
        return GestureDetector(
          onTap: () => onChanged(!v),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: v
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: v
                    ? AppTheme.successColor.withValues(alpha: 0.4)
                    : AppTheme.darkBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  v
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: v
                      ? AppTheme.successColor
                      : AppTheme.darkTextMuted,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  v ? 'True' : 'False',
                  style: TextStyle(
                    color: v
                        ? AppTheme.successColor
                        : AppTheme.darkTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Switch(value: v, onChanged: onChanged),
              ],
            ),
          ),
        );

      case ColumnType.select:
        return DropdownButtonFormField<String>(
          initialValue: col.options.contains(value?.toString())
              ? value?.toString()
              : null,
          hint: Text('Select ${col.name}...'),
          decoration: const InputDecoration(isDense: true),
          dropdownColor: Theme.of(context).cardColor,
          items: col.options
              .map((opt) =>
                  DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: onChanged,
        );

      case ColumnType.date:
        return GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  DateTime.tryParse(textCtrl?.text ?? '') ??
                      DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              final formatted =
                  picked.toIso8601String().substring(0, 10);
              textCtrl?.text = formatted;
              onChanged(formatted);
            }
          },
          child: AbsorbPointer(
            child: TextFormField(
              controller: textCtrl,
              decoration: const InputDecoration(
                hintText: 'YYYY-MM-DD',
                prefixIcon:
                    Icon(Icons.calendar_today_rounded, size: 18),
              ),
            ),
          ),
        );

      case ColumnType.number:
        return TextFormField(
          controller: textCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter ${col.name}...',
            prefixIcon: const Icon(Icons.numbers_rounded, size: 18),
          ),
        );

      default:
        return TextFormField(
          controller: textCtrl,
          maxLines: col.name.toLowerCase().contains('note') ||
                  col.name.toLowerCase().contains('desc')
              ? 3
              : 1,
          decoration: InputDecoration(
            hintText: 'Enter ${col.name}...',
            prefixIcon:
                const Icon(Icons.text_fields_rounded, size: 18),
          ),
        );
    }
  }
}
