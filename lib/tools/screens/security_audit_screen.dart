import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../common/admob_helper.dart';
import '../../core/theme/app_theme.dart';
import '../data/n8n_tools_service.dart';
import '../data/tools_models.dart';
import '../widgets/tool_widgets.dart';

class SecurityAuditScreen extends StatefulWidget {
  const SecurityAuditScreen({super.key});

  @override
  State<SecurityAuditScreen> createState() => _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends State<SecurityAuditScreen> {
  final _svc = Get.find<N8nToolsService>();
  List<AuditReport>? _reports;
  bool _running = false;
  String? _error;
  int _days = 90;

  Future<void> _run() async {
    setState(() {
      _running = true;
      _error = null;
    });
    try {
      final r = await _svc.runSecurityAudit(daysAbandonedWorkflow: _days);
      if (mounted) setState(() => _reports = r);
      AdmobHelper.maybeShowInterstitial();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  static IconData _iconFor(String risk) => switch (risk) {
        'credentials' => Icons.key_rounded,
        'database' => Icons.storage_rounded,
        'nodes' => Icons.hub_rounded,
        'filesystem' => Icons.folder_open_rounded,
        'instance' => Icons.dns_rounded,
        _ => Icons.shield_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final reports = _reports;
    final issues = reports?.fold<int>(0, (s, r) => s + r.issueCount) ?? 0;
    final clean = reports != null && reports.isEmpty;

    return ToolPage(
      title: 'Security Audit',
      header: ToolHeader(
        icon: Icons.shield_rounded,
        title: reports == null
            ? 'Scan your n8n instance'
            : clean
                ? 'No risks found'
                : '$issues potential risks found',
        subtitle: 'Checks credentials, database queries, risky nodes, '
            'filesystem access and instance settings.',
        color: reports == null
            ? AppTheme.accentColor
            : clean
                ? AppTheme.successColor
                : AppTheme.errorColor,
      ),
      children: [
        ToolCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Abandoned workflow threshold',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Flag workflows not run in the last $_days days',
                  style: TextStyle(fontSize: 12, color: mutedText(context))),
              Slider(
                value: _days.toDouble(),
                min: 7,
                max: 365,
                divisions: 51,
                activeColor: AppTheme.primaryColor,
                label: '$_days days',
                onChanged: (v) => setState(() => _days = v.round()),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _running ? null : _run,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _running
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.radar_rounded),
                  label: Text(_running
                      ? 'Scanning...'
                      : reports == null
                          ? 'Run security audit'
                          : 'Run again'),
                ),
              ),
            ],
          ),
        ),
        if (_error != null)
          ToolState(
              loading: false,
              error: _error,
              empty: false,
              emptyTitle: '',
              emptySubtitle: '',
              emptyIcon: Icons.shield,
              onRetry: _run),
        if (clean)
          const ToolState(
              loading: false,
              empty: true,
              emptyTitle: 'Your instance looks secure',
              emptySubtitle: 'n8n did not report any risk in any category.',
              emptyIcon: Icons.verified_user_rounded),
        ...?reports?.asMap().entries.map((e) => _ReportCard(
              report: e.value,
              icon: _iconFor(e.value.risk),
            ).animate().fadeIn(delay: (e.key * 90).ms).slideY(begin: 0.08)),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final AuditReport report;
  final IconData icon;
  const _ReportCard({required this.report, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ToolCard(
      padding: EdgeInsets.zero,
      borderColor: AppTheme.errorColor.withValues(alpha: 0.35),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Icon(icon, color: AppTheme.errorColor),
          title: Text(report.title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${report.issueCount} findings',
              style: const TextStyle(fontSize: 12)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          children: report.sections
              .map((s) => Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13.5)),
                        const SizedBox(height: 4),
                        Text(s.description,
                            style:
                                const TextStyle(fontSize: 12.5, height: 1.4)),
                        if (s.locations.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: s.locations
                                .map((l) =>
                                    ToolChip(l, color: AppTheme.warningColor))
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded,
                                size: 16, color: AppTheme.successColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(s.recommendation,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.4,
                                      color: AppTheme.successColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
