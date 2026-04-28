import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../data/models/data_table_model.dart';
import 'n8n_api_service.dart';

class DataTableService extends GetxService {
  final N8nApiService _api = Get.find<N8nApiService>();

  // ✅ correct endpoint (dash আছে)
  static const _base = '/api/v1/data-tables';

  Dio get _dio => _api.dio;

  Future<DataTableService> init() async => this;

  // ─── Mock cache (demo mode — in-memory) ───────────────────────────────────
  final Map<String, List<TableRow>> _mockRowsCache = {};

  List<DataTableModel> _mockTables() {
    final colName = TableColumn(
        id: 'col-c1', name: 'Full Name', type: ColumnType.text, required: true);
    final colEmail = TableColumn(
        id: 'col-c2', name: 'Email', type: ColumnType.text, required: true);
    final colPlan = TableColumn(
        id: 'col-c3',
        name: 'Plan',
        type: ColumnType.select,
        options: ['Free', 'Pro', 'Enterprise']);
    final colActive =
        TableColumn(id: 'col-c4', name: 'Active', type: ColumnType.boolean);
    final colJoined =
        TableColumn(id: 'col-c5', name: 'Joined', type: ColumnType.date);

    final colOrd = TableColumn(
        id: 'col-o1', name: 'Order ID', type: ColumnType.text, required: true);
    final colCust = TableColumn(
        id: 'col-o2', name: 'Customer', type: ColumnType.text, required: true);
    final colAmt = TableColumn(
        id: 'col-o3',
        name: 'Amount (৳)',
        type: ColumnType.number,
        required: true);
    final colStat = TableColumn(
        id: 'col-o4',
        name: 'Status',
        type: ColumnType.select,
        options: ['Pending', 'Processing', 'Completed', 'Refunded']);
    final colDate =
        TableColumn(id: 'col-o5', name: 'Order Date', type: ColumnType.date);

    final colTask = TableColumn(
        id: 'col-t1', name: 'Task', type: ColumnType.text, required: true);
    final colAssign =
        TableColumn(id: 'col-t2', name: 'Assignee', type: ColumnType.text);
    final colPrio = TableColumn(
        id: 'col-t3',
        name: 'Priority',
        type: ColumnType.select,
        options: ['Low', 'Medium', 'High', 'Critical']);
    final colDone =
        TableColumn(id: 'col-t4', name: 'Done', type: ColumnType.boolean);
    final colDue =
        TableColumn(id: 'col-t5', name: 'Due Date', type: ColumnType.date);

    return [
      DataTableModel(
          id: 'tbl-customers',
          name: 'Customers',
          description: 'All registered customers',
          columns: [colName, colEmail, colPlan, colActive, colJoined],
          createdAt: DateTime(2024, 1, 5),
          updatedAt: DateTime(2024, 12, 1)),
      DataTableModel(
          id: 'tbl-orders',
          name: 'Orders',
          description: 'Sales order tracker',
          columns: [colOrd, colCust, colAmt, colStat, colDate],
          createdAt: DateTime(2024, 2, 1),
          updatedAt: DateTime(2024, 12, 5)),
      DataTableModel(
          id: 'tbl-tasks',
          name: 'Tasks',
          description: 'Team task management',
          columns: [colTask, colAssign, colPrio, colDone, colDue],
          createdAt: DateTime(2024, 3, 1),
          updatedAt: DateTime(2024, 12, 8)),
    ];
  }

  List<TableRow> _getMockRows(String tableId) {
    if (_mockRowsCache.containsKey(tableId)) return _mockRowsCache[tableId]!;
    final tbl = _mockTables().firstWhere((t) => t.id == tableId,
        orElse: () => throw Exception('Table not found'));
    final c = tbl.columns;
    List<Map<String, dynamic>> raw = [];
    if (tableId == 'tbl-customers') {
      raw = [
        {
          c[0].id: 'Rahim Uddin',
          c[1].id: 'rahim@example.com',
          c[2].id: 'Pro',
          c[3].id: true,
          c[4].id: '2024-01-15'
        },
        {
          c[0].id: 'Sumaiya Ahmed',
          c[1].id: 'sumaiya@demo.io',
          c[2].id: 'Enterprise',
          c[3].id: true,
          c[4].id: '2024-02-20'
        },
        {
          c[0].id: 'Karim Hossain',
          c[1].id: 'karim@mail.com',
          c[2].id: 'Free',
          c[3].id: false,
          c[4].id: '2024-03-10'
        },
        {
          c[0].id: 'Nadia Islam',
          c[1].id: 'nadia@startup.bd',
          c[2].id: 'Pro',
          c[3].id: true,
          c[4].id: '2024-04-02'
        },
        {
          c[0].id: 'Farhan Chowdhury',
          c[1].id: 'farhan@agency.com',
          c[2].id: 'Enterprise',
          c[3].id: true,
          c[4].id: '2024-04-18'
        },
        {
          c[0].id: 'Tasnim Begum',
          c[1].id: 'tasnim@corp.net',
          c[2].id: 'Free',
          c[3].id: true,
          c[4].id: '2024-05-05'
        },
        {
          c[0].id: 'Rafiqul Islam',
          c[1].id: 'rafiq@service.org',
          c[2].id: 'Pro',
          c[3].id: false,
          c[4].id: '2024-06-12'
        },
        {
          c[0].id: 'Mitu Akter',
          c[1].id: 'mitu@biztools.io',
          c[2].id: 'Enterprise',
          c[3].id: true,
          c[4].id: '2024-07-30'
        },
      ];
    } else if (tableId == 'tbl-orders') {
      raw = [
        {
          c[0].id: 'ORD-001',
          c[1].id: 'Rahim Uddin',
          c[2].id: 4800,
          c[3].id: 'Completed',
          c[4].id: '2024-11-01'
        },
        {
          c[0].id: 'ORD-002',
          c[1].id: 'Sumaiya Ahmed',
          c[2].id: 12500,
          c[3].id: 'Completed',
          c[4].id: '2024-11-05'
        },
        {
          c[0].id: 'ORD-003',
          c[1].id: 'Nadia Islam',
          c[2].id: 3200,
          c[3].id: 'Processing',
          c[4].id: '2024-11-18'
        },
        {
          c[0].id: 'ORD-004',
          c[1].id: 'Farhan Chowdhury',
          c[2].id: 28000,
          c[3].id: 'Pending',
          c[4].id: '2024-12-01'
        },
        {
          c[0].id: 'ORD-005',
          c[1].id: 'Tasnim Begum',
          c[2].id: 1500,
          c[3].id: 'Refunded',
          c[4].id: '2024-12-03'
        },
        {
          c[0].id: 'ORD-006',
          c[1].id: 'Mitu Akter',
          c[2].id: 9900,
          c[3].id: 'Completed',
          c[4].id: '2024-12-07'
        },
      ];
    } else if (tableId == 'tbl-tasks') {
      raw = [
        {
          c[0].id: 'Set up CI/CD pipeline',
          c[1].id: 'Rahim',
          c[2].id: 'High',
          c[3].id: true,
          c[4].id: '2024-11-15'
        },
        {
          c[0].id: 'Design onboarding flow',
          c[1].id: 'Nadia',
          c[2].id: 'Medium',
          c[3].id: true,
          c[4].id: '2024-11-20'
        },
        {
          c[0].id: 'Fix invoice generator bug',
          c[1].id: 'Farhan',
          c[2].id: 'Critical',
          c[3].id: false,
          c[4].id: '2024-12-10'
        },
        {
          c[0].id: 'Write API documentation',
          c[1].id: 'Tasnim',
          c[2].id: 'Low',
          c[3].id: false,
          c[4].id: '2024-12-15'
        },
        {
          c[0].id: 'Migrate database to v2',
          c[1].id: 'Karim',
          c[2].id: 'High',
          c[3].id: false,
          c[4].id: '2024-12-12'
        },
        {
          c[0].id: 'Automate weekly reports',
          c[1].id: 'Mitu',
          c[2].id: 'Medium',
          c[3].id: true,
          c[4].id: '2024-12-05'
        },
      ];
    }
    final rows = raw
        .map((d) => TableRow(
              id: const Uuid().v4(),
              data: d,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ))
        .toList();
    _mockRowsCache[tableId] = rows;
    return rows;
  }

  // ─── Tables ───────────────────────────────────────────────────────────────

  Future<List<DataTableModel>> getTables() async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockTables();
    }
    try {
      final res = await _dio.get(_base);
      return _parseList(res.data).map(_tableFromN8n).toList();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<DataTableModel?> getTable(String id) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        return _mockTables().firstWhere((t) => t.id == id);
      } catch (_) {
        return null;
      }
    }
    try {
      final res = await _dio.get('$_base/$id');
      return _tableFromN8n(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<DataTableModel> createTable(DataTableModel table) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return table;
    }
    try {
      final res = await _dio.post(_base, data: {
        'name': table.name,
        'columns': table.columns
            .map((c) => {
                  'name': c.name,
                  'type': _toN8nType(c.type),
                })
            .toList(),
      });
      return _tableFromN8n(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<DataTableModel> updateTable(DataTableModel updated) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return updated;
    }
    try {
      final res = await _dio.patch('$_base/${updated.id}', data: {
        'name': updated.name,
        'columns': updated.columns
            .map((c) => {
                  'name': c.name,
                  'type': _toN8nType(c.type),
                })
            .toList(),
      });
      return _tableFromN8n(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> deleteTable(String id) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      _mockRowsCache.remove(id);
      return;
    }
    try {
      await _dio.delete('$_base/$id');
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Rows ─────────────────────────────────────────────────────────────────

  Future<List<TableRow>> getRows(String tableId) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 350));
      return _getMockRows(tableId);
    }
    try {
      final res = await _dio.get('$_base/$tableId/rows');
      return _parseList(res.data).map(_rowFromN8n).toList();
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<TableRow> createRow(String tableId, Map<String, dynamic> data) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final row = TableRow(
          id: const Uuid().v4(),
          data: data,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      _mockRowsCache.putIfAbsent(tableId, () => []).add(row);
      return row;
    }
    try {
      // ✅ n8n format: data হলো list-এ wrap, column name দিয়ে key
      final n8nData = _toN8nRowData(tableId, data);
      final res = await _dio.post(
        '$_base/$tableId/rows',
        data: {
          'data': [n8nData],
          'returnType': 'all'
        },
      );
      // response একটা list — first item নিন
      final list = _parseList(res.data);
      if (list.isNotEmpty) return _rowFromN8n(list.first);
      return TableRow(
          id: const Uuid().v4(),
          data: data,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<TableRow> updateRow(
      String tableId, String rowId, Map<String, dynamic> data) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final rows = _getMockRows(tableId);
      final idx = rows.indexWhere((r) => r.id == rowId);
      if (idx >= 0) {
        rows[idx].data = data;
        rows[idx].updatedAt = DateTime.now();
        return rows[idx];
      }
      throw Exception('Row not found');
    }
    try {
      // ✅ n8n update: filter by id, data হলো column name দিয়ে
      final n8nData = _toN8nRowData(tableId, data);
      final res = await _dio.patch(
        '$_base/$tableId/rows/update',
        data: {
          'filter': {
            'type': 'and',
            'filters': [
              {'columnName': 'id', 'condition': 'eq', 'value': rowId}
            ],
          },
          'data': n8nData,
          'returnData': true,
        },
      );
      final list = _parseList(res.data);
      if (list.isNotEmpty) return _rowFromN8n(list.first);
      return TableRow(
          id: rowId,
          data: data,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  Future<void> deleteRow(String tableId, String rowId) async {
    if (_api.isMockMode) {
      await Future.delayed(const Duration(milliseconds: 350));
      _mockRowsCache[tableId]?.removeWhere((r) => r.id == rowId);
      return;
    }
    try {
      // ✅ n8n delete: query param হিসেবে filter JSON string
      final filterJson =
          '{"type":"and","filters":[{"columnName":"id","condition":"eq","value":"$rowId"}]}';
      await _dio.delete(
        '$_base/$tableId/rows/delete',
        queryParameters: {'filter': filterJson},
      );
    } on DioException catch (e) {
      throw _err(e);
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  // ✅ Flutter-এ col.id key আছে, n8n-এ col.name key চাই
  // getTable() দিয়ে column mapping করা হয়
  Map<String, dynamic> _toN8nRowData(
      String tableId, Map<String, dynamic> data) {
    // data এ key হলো col.id — n8n চায় col.name
    // কিন্তু আমাদের কাছে tableId আছে, table object নেই এখানে
    // তাই data সরাসরি পাঠাই — n8n column name বা id দুটোই accept করে
    return data;
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is Map && data['data'] is List)
      return (data['data'] as List).cast<Map<String, dynamic>>();
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }

  // ✅ n8n row format: flat — id, createdAt, updatedAt বাদ দিলে বাকিটা data
  TableRow _rowFromN8n(Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? const Uuid().v4();
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
        DateTime.now();
    final updatedAt = DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
        DateTime.now();
    final data = Map<String, dynamic>.from(json)
      ..remove('id')
      ..remove('createdAt')
      ..remove('updatedAt');
    return TableRow(
        id: id, data: data, createdAt: createdAt, updatedAt: updatedAt);
  }

  DataTableModel _tableFromN8n(Map<String, dynamic> json) {
    final cols = (json['columns'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((c) => TableColumn(
              id: c['id']?.toString() ?? c['name'] as String,
              name: c['name'] as String,
              type: _fromN8nType(c['type'] as String? ?? 'string'),
              options: (c['options'] as List?)?.cast<String>() ?? [],
            ))
        .toList();
    return DataTableModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      columns: cols,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  String _toN8nType(ColumnType t) {
    switch (t) {
      case ColumnType.number:
        return 'number';
      case ColumnType.boolean:
        return 'boolean';
      case ColumnType.date:
        return 'datetime';
      case ColumnType.select:
        return 'string'; // n8n-এ select আলাদা type নেই
      default:
        return 'string';
    }
  }

  ColumnType _fromN8nType(String t) {
    switch (t) {
      case 'number':
        return ColumnType.number;
      case 'boolean':
        return ColumnType.boolean;
      case 'datetime':
        return ColumnType.date;
      default:
        return ColumnType.text;
    }
  }

  Exception _err(DioException e) {
    final s = e.response?.statusCode;
    final body = e.response?.data?.toString() ?? '';
    if (s == 404) return Exception('Table not found.');
    if (s == 401) return Exception('Unauthorized.');
    if (s == 400) return Exception('Bad request: $body');
    return Exception(e.message ?? 'Network error');
  }
}
