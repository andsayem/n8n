import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../data/n8n_tools_service.dart';
import '../data/tools_models.dart';
import '../widgets/tool_widgets.dart';

class VariablesScreen extends StatefulWidget {
  const VariablesScreen({super.key});

  @override
  State<VariablesScreen> createState() => _VariablesScreenState();
}

class _VariablesScreenState extends State<VariablesScreen> {
  final _svc = Get.find<N8nToolsService>();
  List<N8nVariable> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _items.isEmpty;
      _error = null;
    });
    try {
      final items = await _svc.getVariables();
      items.sort((a, b) => a.key.compareTo(b.key));
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([N8nVariable? v]) async {
    final values = await showFormSheet(
      title: v == null ? 'New Variable' : 'Edit Variable',
      fields: [
        FormFieldSpec('Key', initial: v?.key ?? '', hint: 'e.g. SLACK_CHANNEL'),
        FormFieldSpec('Value', initial: v?.value ?? '', maxLines: 3),
      ],
    );
    if (values == null) return;
    final key = values[0].replaceAll(RegExp(r'\s+'), '_');
    if (!RegExp(r'^[A-Za-z0-9_]+$').hasMatch(key)) {
      toolToast('Key may only contain letters, numbers and _', error: true);
      return;
    }
    final ok = await runAction(
      () => v == null
          ? _svc.createVariable(key, values[1])
          : _svc.updateVariable(v.id, key, values[1]),
      success: v == null ? 'Variable created' : 'Variable updated',
    );
    if (ok) _load();
  }

  Future<void> _delete(N8nVariable v) async {
    if (!await confirmDialog('Delete variable', 'Delete "${v.key}"?')) return;
    final ok = await runAction(() => _svc.deleteVariable(v.id),
        success: 'Variable deleted');
    if (ok) _load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ToolState(
      loading: _loading,
      error: _error,
      empty: _items.isEmpty,
      emptyTitle: 'No variables yet',
      emptySubtitle:
          'Variables are global values you can use in any workflow as \$vars.KEY',
      emptyIcon: Icons.data_object_rounded,
      onRetry: _load,
    );
    return ToolPage(
      title: 'Variables',
      onRefresh: _load,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Variable'),
      ),
      header: ToolHeader(
        icon: Icons.data_object_rounded,
        title: _loading
            ? 'Loading variables...'
            : '${_items.length} environment variables',
        subtitle: 'Use them in expressions as {{ \$vars.KEY }}. '
            'Values are shared by every workflow on this instance.',
        color: AppTheme.accentColor,
      ),
      children: state.shows
          ? [state]
          : _items
              .map((v) => ToolCard(
                    onTap: () => _edit(v),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.key,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5)),
                              const SizedBox(height: 4),
                              Text(v.value,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      color: mutedText(context))),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copy expression',
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: '{{ \$vars.${v.key} }}'));
                            toolToast('Expression copied');
                          },
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 20, color: AppTheme.errorColor),
                          onPressed: () => _delete(v),
                        ),
                      ],
                    ),
                  ))
              .toList(),
    );
  }
}
