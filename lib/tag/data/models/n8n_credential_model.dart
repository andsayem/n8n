class N8nCredential {
  final String id;
  final String name;
  final String type;
  final bool isManaged;
  final List<String> scopes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const N8nCredential({
    required this.id,
    required this.name,
    required this.type,
    this.isManaged = false,
    this.scopes = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory N8nCredential.fromJson(Map<String, dynamic> json) {
    return N8nCredential(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isManaged: json['isManaged'] as bool? ?? false,
      scopes: (json['scopes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'isManaged': isManaged,
        'scopes': scopes,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  bool get canEdit => scopes.contains('credential:update');
  bool get canDelete => scopes.contains('credential:delete');

  @override
  String toString() => 'N8nCredential(id: $id, name: $name, type: $type)';
}

class N8nCredentialList {
  final List<N8nCredential> data;
  final String? nextCursor;

  const N8nCredentialList({required this.data, this.nextCursor});

  factory N8nCredentialList.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => N8nCredential.fromJson(e as Map<String, dynamic>))
        .toList();
    return N8nCredentialList(
        data: list, nextCursor: json['nextCursor'] as String?);
  }
}

class CreateCredentialRequest {
  final String name;
  final String type;
  final Map<String, dynamic> data;

  const CreateCredentialRequest({
    required this.name,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'data': data,
      };
}
