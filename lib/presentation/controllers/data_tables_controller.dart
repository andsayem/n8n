import 'package:get/get.dart';
import '../../data/models/data_table_model.dart';
import '../../services/data_table_service.dart';

// ─── Tables list controller ───────────────────────────────────────────────────
class DataTableListController extends GetxController {
  final DataTableService _svc = Get.put(DataTableService());

  final RxList<DataTableModel> tables = <DataTableModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTables();
  }

  Future<void> fetchTables() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      tables.value = await _svc.getTables();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTable(String id) async {
    try {
      await _svc.deleteTable(id);
      tables.removeWhere((t) => t.id == id);
      Get.snackbar(
        'Deleted',
        'Table removed successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// ─── Single table + rows controller ──────────────────────────────────────────
class DataTableDetailController extends GetxController {
  final DataTableService _svc = Get.find<DataTableService>();

  final Rxn<DataTableModel> table = Rxn<DataTableModel>();
  final RxList<TableRow> rows = <TableRow>[].obs;
  final RxList<TableRow> filteredRows = <TableRow>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt sortColIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxInt currentPage = 0.obs;
  final int rowsPerPage = 8;

  @override
  void onInit() {
    super.onInit();
    ever(searchQuery, (_) => _applyFilter());
    ever(sortColIndex, (_) => _applyFilter());
    ever(sortAscending, (_) => _applyFilter());
  }

  Future<void> load(String tableId) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      table.value = await _svc.getTable(tableId);
      final rawRows = await _svc.getRows(tableId);

      // ✅ n8n row data-তে key হলো column name
      // Flutter widget চায় column id — mapping করি
      final cols = table.value?.columns ?? [];
      final mappedRows = rawRows.map((row) {
        final mappedData = <String, dynamic>{};
        for (final col in cols) {
          // n8n-এ key হলো col.name, আমরা col.id-তে store করি
          final val = row.data[col.name] ?? row.data[col.id];
          if (val != null) mappedData[col.id] = val;
        }
        return TableRow(
          id: row.id,
          data: mappedData,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        );
      }).toList();

      rows.value = mappedRows;
      _applyFilter();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var list = List<TableRow>.from(rows);

    // Search across all values
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (r) => r.data.values.any(
              (v) => v.toString().toLowerCase().contains(q),
            ),
          )
          .toList();
    }

    // Sort
    final cols = table.value?.columns ?? [];
    if (sortColIndex.value < cols.length) {
      final colId = cols[sortColIndex.value].id;
      list.sort((a, b) {
        final av = a.data[colId]?.toString() ?? '';
        final bv = b.data[colId]?.toString() ?? '';
        return sortAscending.value ? av.compareTo(bv) : bv.compareTo(av);
      });
    }

    filteredRows.value = list;
    currentPage.value = 0;
  }

  List<TableRow> get currentPageRows {
    final start = currentPage.value * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredRows.length);
    return filteredRows.sublist(start, end);
  }

  int get totalPages =>
      (filteredRows.length / rowsPerPage).ceil().clamp(1, 9999);

  void setSearch(String q) => searchQuery.value = q;
  void setSort(int index, bool asc) {
    sortColIndex.value = index;
    sortAscending.value = asc;
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) currentPage.value++;
  }

  void prevPage() {
    if (currentPage.value > 0) currentPage.value--;
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  // col.id → col.name mapping helper
  Map<String, dynamic> _toN8nFormat(Map<String, dynamic> data) {
    final cols = table.value?.columns ?? [];
    final result = <String, dynamic>{};
    for (final col in cols) {
      if (data.containsKey(col.id)) {
        result[col.name] = data[col.id]; // ✅ id → name
      }
    }
    return result;
  }

  Future<bool> createRow(Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final n8nData = _toN8nFormat(data);
      final row = await _svc.createRow(table.value!.id, n8nData);
      // response-এ আসা data-ও col.name দিয়ে — id-তে convert করি
      final mappedData = <String, dynamic>{};
      final cols = table.value?.columns ?? [];
      for (final col in cols) {
        final val = row.data[col.name] ?? row.data[col.id];
        if (val != null) mappedData[col.id] = val;
      }
      rows.add(
        TableRow(
          id: row.id,
          data: mappedData,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
      );
      _applyFilter();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateRow(String rowId, Map<String, dynamic> data) async {
    isSaving.value = true;
    try {
      final n8nData = _toN8nFormat(data);
      await _svc.updateRow(table.value!.id, rowId, n8nData);
      // locally update করি
      final idx = rows.indexWhere((r) => r.id == rowId);
      if (idx >= 0) {
        rows[idx].data = data; // col.id format-এ রাখি locally
        rows[idx].updatedAt = DateTime.now();
      }
      rows.refresh();
      _applyFilter();
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteRow(String rowId) async {
    try {
      await _svc.deleteRow(table.value!.id, rowId);
      rows.removeWhere((r) => r.id == rowId);
      _applyFilter();
      Get.snackbar(
        'Deleted',
        'Row removed',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

// ─── Create / Edit Table controller ──────────────────────────────────────────
class DataTableEditController extends GetxController {
  final DataTableService _svc = Get.find<DataTableService>();

  final RxList<TableColumn> columns = <TableColumn>[].obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  void loadFromTable(DataTableModel table) {
    columns.value = List<TableColumn>.from(table.columns);
  }

  void addColumn(TableColumn col) => columns.add(col);

  void removeColumn(String id) => columns.removeWhere((c) => c.id == id);

  void updateColumn(TableColumn updated) {
    final idx = columns.indexWhere((c) => c.id == updated.id);
    if (idx >= 0) columns[idx] = updated;
    columns.refresh();
  }

  void reorderColumns(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final col = columns.removeAt(oldIndex);
    columns.insert(newIndex, col);
  }

  Future<DataTableModel?> createTable(String name, String description) async {
    isSaving.value = true;
    errorMessage.value = '';
    try {
      final table = DataTableModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        description: description.trim(),
        columns: List.from(columns),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return await _svc.createTable(table);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<DataTableModel?> updateTable(
    DataTableModel original,
    String name,
    String desc,
  ) async {
    isSaving.value = true;
    errorMessage.value = '';
    try {
      original.name = name.trim();
      original.description = desc.trim();
      original.columns = List.from(columns);
      original.updatedAt = DateTime.now();
      return await _svc.updateTable(original);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isSaving.value = false;
    }
  }
}
