import 'package:get/get.dart';
import '../../presentation/controllers/auth_controller.dart';

class DataTablesController extends GetxController {
  final RxList<Map<String, dynamic>> rows = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredRows = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt sortColumnIndex = 0.obs;
  final RxBool sortAscending = true.obs;
  final RxInt currentPage = 0.obs;
  final int rowsPerPage = 7;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        rows.value = List.generate(
          20,
          (i) => {
            'ID': 'row_${1000 + i}',
            'Name': 'Record ${i + 1}',
            'Status': i % 3 == 0 ? 'Active' : i % 3 == 1 ? 'Pending' : 'Inactive',
            'Created': '2024-03-${(i % 28) + 1}',
            'Value': '\$${(i + 1) * 125}',
          },
        );
      } else {
        // REAL API (n8n usually returns binary/json data from nodes, 
        // we'd fetch from a specific execution or static data table if available)
        rows.value = []; 
      }
      _applySort();
    } catch (e) {
      // Error handling
    } finally {
      isLoading.value = false;
    }
  }

  void onSort(int index, bool ascending) {
    sortColumnIndex.value = index;
    sortAscending.value = ascending;
    _applySort();
  }

  void _applySort() {
    if (rows.isEmpty) return;
    final keys = rows.first.keys.toList();
    final key = keys[sortColumnIndex.value];
    
    final list = [...rows];
    list.sort((a, b) {
      final av = a[key].toString();
      final bv = b[key].toString();
      return sortAscending.value ? av.compareTo(bv) : bv.compareTo(av);
    });
    
    filteredRows.value = list;
  }

  List<Map<String, dynamic>> get pagedRows {
    final start = currentPage.value * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, filteredRows.length);
    return filteredRows.sublist(start, end);
  }

  int get totalPages => (filteredRows.length / rowsPerPage).ceil();

  void next() {
    if (currentPage.value < totalPages - 1) currentPage.value++;
  }

  void prev() {
    if (currentPage.value > 0) currentPage.value--;
  }
}
