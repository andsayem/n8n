import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../audit/data/models/audit_entry.dart';
import '../../audit/data/services/audit_log_service.dart';
import '../../core/theme/app_theme.dart';
import '../../presentation/controllers/workflow_controller.dart';
import '../data/n8n_tools_service.dart';
import '../widgets/tool_widgets.dart';

/// Creates a workflow from pasted n8n JSON (exported from the editor,
/// copied from n8n.io/workflows, or shared by a teammate).
class ImportWorkflowScreen extends StatefulWidget {
  const ImportWorkflowScreen({super.key});

  @override
  State<ImportWorkflowScreen> createState() => _ImportWorkflowScreenState();
}

class _ImportWorkflowScreenState extends State<ImportWorkflowScreen> {
  final _svc = Get.find<N8nToolsService>();
  final _json = TextEditingController();
  final _name = TextEditingController();
  Map<String, dynamic>? _parsed;
  String? _parseError;

  static const _sample = '''{
  "name": "Hello Webhook",
  "nodes": [
    {
      "parameters": { "path": "hello", "responseMode": "lastNode" },
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 2,
      "position": [0, 0]
    },
    {
      "parameters": {
        "assignments": { "assignments": [
          { "id": "1", "name": "message", "type": "string", "value": "Hello from n8n Manager" }
        ] }
      },
      "name": "Set Message",
      "type": "n8n-nodes-base.set",
      "typeVersion": 3.4,
      "position": [220, 0]
    }
  ],
  "connections": {
    "Webhook": { "main": [[{ "node": "Set Message", "type": "main", "index": 0 }]] }
  },
  "settings": { "executionOrder": "v1" }
}''';

  void _parse(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _parsed = null;
        _parseError = null;
      });
      return;
    }
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map || decoded['nodes'] is! List) {
        throw const FormatException('JSON must contain a "nodes" array');
      }
      final map = Map<String, dynamic>.from(decoded);
      setState(() {
        _parsed = map;
        _parseError = null;
        if (_name.text.isEmpty) _name.text = (map['name'] ?? '').toString();
      });
    } catch (e) {
      setState(() {
        _parsed = null;
        _parseError = e is FormatException ? e.message : 'Invalid JSON';
      });
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    _json.text = data?.text ?? '';
    _parse(_json.text);
  }

  Future<void> _import() async {
    final wf = _parsed;
    if (wf == null) return;
    final name = _name.text.trim().isEmpty ? null : _name.text.trim();
    final id = await runWithProgress(
        () => _svc.createWorkflowFromJson(wf, nameOverride: name),
        success: 'Workflow imported');
    if (id == null) return;
    Get.find<AuditLogService>().log(
      action: AuditAction.created,
      targetType: AuditTarget.workflow,
      targetName: name ?? wf['name']?.toString() ?? 'Imported workflow',
      targetId: id,
      detail: 'Imported from JSON',
    );
    if (Get.isRegistered<WorkflowController>()) {
      Get.find<WorkflowController>().fetchWorkflows();
    }
    // Navigator, not Get.back(): Get.back() would close the snackbar first.
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _json.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = (_parsed?['nodes'] as List?) ?? const [];
    return ToolPage(
      title: 'Import Workflow',
      header: const ToolHeader(
        icon: Icons.file_download_rounded,
        title: 'Paste workflow JSON',
        subtitle: 'In the n8n editor select all nodes and copy (Ctrl+C), or '
            'download a template from n8n.io/workflows.',
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _paste,
                icon: const Icon(Icons.content_paste_rounded, size: 18),
                label: const Text('Paste'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _json.text = _sample;
                  _name.clear();
                  _parse(_sample);
                },
                icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                label: const Text('Sample'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _json,
          onChanged: _parse,
          maxLines: 10,
          minLines: 6,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: InputDecoration(
            hintText: '{ "name": "...", "nodes": [...], "connections": {...} }',
            errorText: _parseError,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Workflow name'),
        ),
        if (_parsed != null) ...[
          const SizedBox(height: 12),
          ToolCard(
            borderColor: AppTheme.successColor.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.successColor, size: 20),
                  const SizedBox(width: 8),
                  Text('Valid workflow · ${nodes.length} nodes',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: nodes
                      .whereType<Map>()
                      .map((n) => ToolChip((n['name'] ?? '').toString()))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _parsed == null ? null : _import,
          icon: const Icon(Icons.upload_rounded),
          label: const Text('Create workflow'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
