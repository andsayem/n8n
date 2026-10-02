class N8nVariable {
  final String id;
  final String key;
  final String value;

  const N8nVariable({required this.id, required this.key, required this.value});

  factory N8nVariable.fromJson(Map<String, dynamic> json) => N8nVariable(
        id: json['id'].toString(),
        key: (json['key'] ?? '').toString(),
        value: (json['value'] ?? '').toString(),
      );
}

class N8nProject {
  final String id;
  final String name;

  /// "personal" or "team".
  final String type;

  const N8nProject({required this.id, required this.name, required this.type});

  bool get isPersonal => type == 'personal';

  factory N8nProject.fromJson(Map<String, dynamic> json) => N8nProject(
        id: json['id'].toString(),
        name: (json['name'] ?? 'Untitled').toString(),
        type: (json['type'] ?? 'team').toString(),
      );
}

class N8nUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;

  /// e.g. "global:owner", "global:admin", "global:member".
  final String role;
  final bool isPending;

  const N8nUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.role,
    this.isPending = false,
  });

  String get displayName {
    final n = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    return n.isEmpty ? email : n;
  }

  String get roleLabel {
    final r = role.split(':').last;
    return r.isEmpty ? 'member' : r[0].toUpperCase() + r.substring(1);
  }

  bool get isOwner => role == 'global:owner';

  N8nUser copyWith({String? role}) => N8nUser(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role ?? this.role,
        isPending: isPending,
      );

  factory N8nUser.fromJson(Map<String, dynamic> json) => N8nUser(
        id: json['id'].toString(),
        email: (json['email'] ?? '').toString(),
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        role: (json['role'] ?? 'global:member').toString(),
        isPending: json['isPending'] == true,
      );
}

/// One category of n8n's security audit (credentials, database, nodes,
/// filesystem, instance).
class AuditReport {
  final String title;
  final String risk;
  final List<AuditSection> sections;

  const AuditReport(
      {required this.title, required this.risk, required this.sections});

  int get issueCount => sections.fold(
      0, (sum, s) => sum + (s.locations.isEmpty ? 1 : s.locations.length));

  factory AuditReport.fromJson(String title, Map<String, dynamic> json) =>
      AuditReport(
        title: title,
        risk: (json['risk'] ?? '').toString(),
        sections: ((json['sections'] as List?) ?? [])
            .whereType<Map>()
            .map((s) => AuditSection.fromJson(Map<String, dynamic>.from(s)))
            .toList(),
      );
}

class AuditSection {
  final String title;
  final String description;
  final String recommendation;
  final List<String> locations;

  const AuditSection({
    required this.title,
    required this.description,
    required this.recommendation,
    this.locations = const [],
  });

  factory AuditSection.fromJson(Map<String, dynamic> json) {
    final locs = ((json['location'] as List?) ?? [])
        .whereType<Map>()
        .map((l) {
          final wf = l['workflowName'] ?? l['name'];
          final node = l['nodeName'];
          if (wf != null && node != null) return '$wf > $node';
          return (wf ?? l['id'] ?? l['kind'] ?? '').toString();
        })
        .where((s) => s.isNotEmpty)
        .toList();
    return AuditSection(
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      recommendation: (json['recommendation'] ?? '').toString(),
      locations: locs,
    );
  }
}

class ServerHealth {
  final bool reachable;
  final bool healthy;
  final bool apiOk;
  final int latencyMs;
  final int? workflowCount;
  final String message;

  const ServerHealth({
    required this.reachable,
    required this.healthy,
    required this.apiOk,
    required this.latencyMs,
    this.workflowCount,
    required this.message,
  });

  bool get allGood => reachable && healthy && apiOk;
}
