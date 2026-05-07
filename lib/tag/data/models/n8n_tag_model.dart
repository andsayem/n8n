class N8nTag {
  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const N8nTag({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory N8nTag.fromJson(Map<String, dynamic> json) {
    return N8nTag(
      id: json['id'] as String,
      name: json['name'] as String,
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
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  N8nTag copyWith({String? id, String? name}) => N8nTag(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  @override
  String toString() => 'N8nTag(id: $id, name: $name)';
}

class N8nTagList {
  final List<N8nTag> data;
  final String? nextCursor;

  const N8nTagList({required this.data, this.nextCursor});

  factory N8nTagList.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => N8nTag.fromJson(e as Map<String, dynamic>))
        .toList();
    return N8nTagList(data: list, nextCursor: json['nextCursor'] as String?);
  }
}
