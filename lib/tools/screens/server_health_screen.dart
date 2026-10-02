import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../presentation/controllers/auth_controller.dart';
import '../data/n8n_tools_service.dart';
import '../data/tools_models.dart';
import '../widgets/tool_widgets.dart';

/// Connection diagnostics for the active instance plus Git (source control)
/// pull.
class ServerHealthScreen extends StatefulWidget {
  const ServerHealthScreen({super.key});

  @override
  State<ServerHealthScreen> createState() => _ServerHealthScreenState();
}

class _ServerHealthScreenState extends State<ServerHealthScreen> {
  final _svc = Get.find<N8nToolsService>();
  ServerHealth? _health;
  bool _checking = false;
  String? _pullResult;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final h = await _svc.checkHealth();
    if (mounted) {
      setState(() {
        _health = h;
        _checking = false;
      });
    }
  }

  Future<void> _pull({bool force = false}) async {
    if (force &&
        !await confirmDialog('Force pull',
            'Overwrite local changes on the server with the Git branch?',
            confirm: 'Force pull')) {
      return;
    }
    final r = await runWithProgress(() => _svc.pullSourceControl(force: force));
    if (r != null && mounted) setState(() => _pullResult = r);
  }

  @override
  Widget build(BuildContext context) {
    final h = _health;
    final instance = Get.find<AuthController>().activeInstance.value;
    final good = h?.allGood ?? false;
    final color = h == null
        ? AppTheme.accentColor
        : good
            ? AppTheme.successColor
            : AppTheme.errorColor;

    return ToolPage(
      title: 'Server Health',
      onRefresh: _check,
      actions: [
        IconButton(
            onPressed: _checking ? null : _check,
            icon: const Icon(Icons.refresh_rounded)),
      ],
      header: ToolHeader(
        icon: good ? Icons.cloud_done_rounded : Icons.monitor_heart_rounded,
        title: _checking
            ? 'Checking server...'
            : h == null
                ? 'Server status'
                : h.message,
        subtitle: instance == null
            ? 'No active instance'
            : _svc.isDemo
                ? 'Demo instance'
                : instance.baseUrl,
        color: color,
        trailing: _checking
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2))
            : null,
      ),
      children: [
        if (h != null) ...[
          Row(
            children: [
              _Metric(
                  label: 'Latency',
                  value: '${h.latencyMs} ms',
                  color: h.latencyMs < 400
                      ? AppTheme.successColor
                      : h.latencyMs < 1200
                          ? AppTheme.warningColor
                          : AppTheme.errorColor),
              const SizedBox(width: 10),
              _Metric(
                  label: 'Workflows',
                  value: h.workflowCount?.toString() ?? '-',
                  color: AppTheme.accentColor),
            ],
          ),
          const SizedBox(height: 10),
          _CheckRow('Server reachable', h.reachable),
          _CheckRow('Health endpoint (/healthz)', h.healthy),
          _CheckRow('Public API + API key', h.apiOk),
        ],
        const SizedBox(height: 18),
        const Text('Source control (Git)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
            'Pull workflows, tags and variables from the Git branch connected '
            'in n8n > Settings > Environments. Requires an Enterprise licence.',
            style: TextStyle(
                fontSize: 12.5, height: 1.4, color: mutedText(context))),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pull(),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Pull'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pull(force: true),
                icon: const Icon(Icons.sync_problem_rounded),
                label: const Text('Force pull'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (_pullResult != null) ...[
          const SizedBox(height: 10),
          ToolCard(
            borderColor: AppTheme.successColor.withValues(alpha: 0.5),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.successColor),
              const SizedBox(width: 10),
              Expanded(child: Text(_pullResult!)),
            ]),
          ),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Metric(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ToolCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String label;
  final bool ok;
  const _CheckRow(this.label, this.ok);

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: ok ? AppTheme.successColor : AppTheme.errorColor,
              size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(ok ? 'OK' : 'Failed',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ok ? AppTheme.successColor : AppTheme.errorColor)),
        ],
      ),
    );
  }
}
