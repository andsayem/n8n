class N8nInstance {
  final String id;
  final String name;
  final String baseUrl;
  final String apiKey;
  final DateTime createdAt;

  N8nInstance({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.apiKey,
    required this.createdAt,
  });

  factory N8nInstance.fromJson(Map<String, dynamic> json) {
    return N8nInstance(
      id: json['id'] as String,
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      apiKey: json['apiKey'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseUrl': baseUrl,
        'apiKey': apiKey,
        'createdAt': createdAt.toIso8601String(),
      };

  N8nInstance copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? apiKey,
    DateTime? createdAt,
  }) {
    return N8nInstance(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
