import '../../data/mock_data.dart';
import 'tools_models.dart';

/// In-memory data behind the demo account for the n8n tools screens.
/// Changes live until the app restarts.
class DemoToolsData {
  final List<N8nVariable> variables = [
    const N8nVariable(id: 'v1', key: 'SLACK_CHANNEL', value: '#ops-alerts'),
    const N8nVariable(
        id: 'v2', key: 'API_BASE_URL', value: 'https://api.acme.io/v2'),
    const N8nVariable(id: 'v3', key: 'REPORT_EMAIL', value: 'reports@acme.io'),
    const N8nVariable(id: 'v4', key: 'RETRY_LIMIT', value: '3'),
  ];

  final List<N8nProject> projects = [
    const N8nProject(
        id: 'p0', name: 'Alex Morgan <alex@acme.io>', type: 'personal'),
    const N8nProject(id: 'p1', name: 'Marketing Automation', type: 'team'),
    const N8nProject(id: 'p2', name: 'DevOps & Alerts', type: 'team'),
    const N8nProject(id: 'p3', name: 'Sales CRM Sync', type: 'team'),
  ];

  final List<N8nUser> users = [
    const N8nUser(
        id: 'u1',
        email: 'alex@acme.io',
        firstName: 'Alex',
        lastName: 'Morgan',
        role: 'global:owner'),
    const N8nUser(
        id: 'u2',
        email: 'priya@acme.io',
        firstName: 'Priya',
        lastName: 'Shah',
        role: 'global:admin'),
    const N8nUser(
        id: 'u3',
        email: 'daniel@acme.io',
        firstName: 'Daniel',
        lastName: 'Kim',
        role: 'global:member'),
    const N8nUser(
        id: 'u4',
        email: 'sofia@acme.io',
        role: 'global:member',
        isPending: true),
  ];

  List<AuditReport> auditReports() => const [
        AuditReport(
            title: 'Credentials Risk Report',
            risk: 'credentials',
            sections: [
              AuditSection(
                title: 'Credentials not used in any workflow',
                description: 'These credentials are not used in any workflow.',
                recommendation:
                    'Consider deleting these credentials if you no longer need them.',
                locations: ['Old Stripe Key', 'Test SMTP'],
              ),
            ]),
        AuditReport(title: 'Nodes Risk Report', risk: 'nodes', sections: [
          AuditSection(
            title: 'Official risky nodes',
            description:
                'These nodes are part of n8n\'s official nodes and may be used to fetch and run any arbitrary code in the host system.',
            recommendation:
                'Consider reviewing the parameters in these nodes, replacing them with more specific nodes, or disabling them via NODES_EXCLUDE.',
            locations: [
              'Lead Enrichment Pipeline > Code',
              'Server Backup Job > Execute Command'
            ],
          ),
        ]),
        AuditReport(title: 'Instance Risk Report', risk: 'instance', sections: [
          AuditSection(
            title: 'Unprotected webhooks in instance',
            description:
                'These webhook nodes have the "Authentication" field set to "None" and are not directly connected to a node to validate the payload.',
            recommendation:
                'Consider setting the "Authentication" field to an option other than "None", or validating the payload with one of the following nodes.',
            locations: ['Slack Notification Pipeline > Webhook'],
          ),
          AuditSection(
            title: 'Outdated instance',
            description: 'This n8n instance is outdated.',
            recommendation:
                'Consider updating this n8n instance to the latest version to prevent security vulnerabilities.',
          ),
        ]),
      ];

  Map<String, dynamic> workflowJson(String id) {
    final list = (MockData.data['workflows_response']['data'] as List);
    final wf = list.cast<Map>().firstWhere((w) => w['id'].toString() == id,
        orElse: () => list.first as Map);
    return {
      ...Map<String, dynamic>.from(wf),
      'connections': <String, dynamic>{},
      'settings': {'executionOrder': 'v1'},
    };
  }
}
