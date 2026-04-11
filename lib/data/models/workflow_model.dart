class WorkflowModel {
  final String id;
  final String name;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final List<dynamic> nodes;
  final Map<String, dynamic>? settings;
  final String? lastExecutionStatus;
  final String? lastExecutionAt;

  WorkflowModel({
    required this.id,
    required this.name,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.nodes = const [],
    this.settings,
    this.lastExecutionStatus,
    this.lastExecutionAt,
  });

  factory WorkflowModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    if (json['tags'] is List) {
      parsedTags = (json['tags'] as List)
          .map((t) => t is Map ? (t['name'] as String? ?? '') : t.toString())
          .where((t) => t.isNotEmpty)
          .toList();
    }

    return WorkflowModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Untitled',
      active: json['active'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      tags: parsedTags,
      nodes: json['nodes'] as List<dynamic>? ?? [],
      settings: json['settings'] as Map<String, dynamic>?,
      lastExecutionStatus: json['lastExecutionStatus'] as String?,
      lastExecutionAt: json['lastExecutionAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'active': active,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'tags': tags,
        'nodes': nodes,
        'settings': settings,
        'lastExecutionStatus': lastExecutionStatus,
        'lastExecutionAt': lastExecutionAt,
      };

  int get nodeCount => nodes.length;

  WorkflowModel copyWith({
    String? id,
    String? name,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    List<dynamic>? nodes,
    Map<String, dynamic>? settings,
    String? lastExecutionStatus,
    String? lastExecutionAt,
  }) {
    return WorkflowModel(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      nodes: nodes ?? this.nodes,
      settings: settings ?? this.settings,
      lastExecutionStatus:
          lastExecutionStatus ?? this.lastExecutionStatus,
      lastExecutionAt: lastExecutionAt ?? this.lastExecutionAt,
    );
  }
}