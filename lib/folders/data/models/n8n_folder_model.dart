class N8nFolder {
  final String id;
  final String name;
  final String? parentFolderId;
  final String? projectId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? workflowCount;
  final int? subFolderCount;

  const N8nFolder({
    required this.id,
    required this.name,
    this.parentFolderId,
    this.projectId,
    this.createdAt,
    this.updatedAt,
    this.workflowCount,
    this.subFolderCount,
  });

  factory N8nFolder.fromJson(Map<String, dynamic> json) {
    return N8nFolder(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Untitled',
      parentFolderId: json['parentFolderId']?.toString(),
      projectId: json['projectId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      workflowCount: (json['totalWorkflows'] ?? json['workflowCount']) as int?,
      subFolderCount: json['subFolderCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'parentFolderId': parentFolderId,
        'projectId': projectId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'workflowCount': workflowCount,
        'subFolderCount': subFolderCount,
      };

  bool get isRoot => parentFolderId == null || parentFolderId!.isEmpty;
}