import 'package:uuid/uuid.dart';

// ─── Column definition ────────────────────────────────────────────────────────
enum ColumnType { text, number, boolean, date, select }

class TableColumn {
  final String id;
  final String name;
  final ColumnType type;
  final bool required;
  final List<String> options; // select type এর জন্য

  TableColumn({
    required this.id,
    required this.name,
    required this.type,
    this.required = false,
    this.options = const [],
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) => TableColumn(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ColumnType.values.firstWhere(
          (e) => e.name == (json['type'] as String? ?? 'text'),
          orElse: () => ColumnType.text,
        ),
        required: json['required'] as bool? ?? false,
        options: (json['options'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'required': required,
        'options': options,
      };

  TableColumn copyWith({
    String? id,
    String? name,
    ColumnType? type,
    bool? required,
    List<String>? options,
  }) =>
      TableColumn(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        required: required ?? this.required,
        options: options ?? this.options,
      );

  static String typeLabel(ColumnType t) {
    switch (t) {
      case ColumnType.text:    return 'Text';
      case ColumnType.number:  return 'Number';
      case ColumnType.boolean: return 'Boolean';
      case ColumnType.date:    return 'Date';
      case ColumnType.select:  return 'Select';
    }
  }
}

// ─── Table definition ─────────────────────────────────────────────────────────
class DataTableModel {
  final String id;
  String name;
  String description;
  List<TableColumn> columns;
  final DateTime createdAt;
  DateTime updatedAt;

  DataTableModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.columns,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DataTableModel.empty(String name) {
    return DataTableModel(
      id: const Uuid().v4(),
      name: name,
      description: '',
      columns: [
        TableColumn(id: const Uuid().v4(), name: 'Name', type: ColumnType.text, required: true),
        TableColumn(id: const Uuid().v4(), name: 'Status', type: ColumnType.select, options: ['Active', 'Inactive', 'Pending']),
        TableColumn(id: const Uuid().v4(), name: 'Notes', type: ColumnType.text),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory DataTableModel.fromJson(Map<String, dynamic> json) => DataTableModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String? ?? '',
        columns: (json['columns'] as List<dynamic>)
            .map((c) => TableColumn.fromJson(c as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'columns': columns.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ─── Row ──────────────────────────────────────────────────────────────────────
class TableRow {
  final String id;
  Map<String, dynamic> data; // columnId → value
  final DateTime createdAt;
  DateTime updatedAt;

  TableRow({
    required this.id,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TableRow.fromJson(Map<String, dynamic> json) => TableRow(
        id: json['id'] as String,
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
