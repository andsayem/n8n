class AuditAction {
  static const activated = 'activated';
  static const deactivated = 'deactivated';
  static const ran = 'ran';
  static const movedToFolder = 'moved_to_folder';
  static const created = 'created';
  static const updated = 'updated';
  static const deleted = 'deleted';
  static const renamed = 'renamed';

  static const List<String> all = [
    activated,
    deactivated,
    ran,
    movedToFolder,
    created,
    updated,
    renamed,
    deleted,
  ];
}

class AuditTarget {
  static const workflow = 'workflow';
  static const folder = 'folder';
  static const table = 'table';

  static const List<String> all = [workflow, folder, table];
}

class AuditEntry {
  final String id;
  final String action;
  final String targetType;
  final String targetName;
  final String? targetId;
  final String? detail;
  final String? actor;
  final DateTime timestamp;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.targetType,
    required this.targetName,
    this.targetId,
    this.detail,
    this.actor,
    required this.timestamp,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        id: json['id'] as String,
        action: json['action'] as String,
        targetType: json['targetType'] as String,
        targetName: json['targetName'] as String,
        targetId: json['targetId'] as String?,
        detail: json['detail'] as String?,
        actor: json['actor'] as String?,
        timestamp:
            DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'targetType': targetType,
        'targetName': targetName,
        'targetId': targetId,
        'detail': detail,
        'actor': actor,
        'timestamp': timestamp.toIso8601String(),
      };

  String get actionLabel {
    switch (action) {
      case AuditAction.activated:
        return 'Activated';
      case AuditAction.deactivated:
        return 'Deactivated';
      case AuditAction.ran:
        return 'Ran';
      case AuditAction.movedToFolder:
        return 'Moved to folder';
      case AuditAction.created:
        return 'Created';
      case AuditAction.updated:
        return 'Updated';
      case AuditAction.renamed:
        return 'Renamed';
      case AuditAction.deleted:
        return 'Deleted';
      default:
        return action;
    }
  }

  String get title => '$actionLabel $targetType';
}