import 'package:get/get.dart';
import 'package:n8n_manager/audit/data/models/audit_entry.dart';
import 'package:n8n_manager/audit/data/services/audit_log_service.dart';

class ActivityController extends GetxController {
  late final AuditLogService _svc;

  final RxString filterAction = 'all'.obs;
  final RxString filterType = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<AuditEntry> filteredEntries = <AuditEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _svc = Get.find<AuditLogService>();
    ever(filterAction, (_) => _apply());
    ever(filterType, (_) => _apply());
    ever(searchQuery, (_) => _apply());
    ever(_svc.entries, (_) => _apply());
    _apply();
  }

  List<AuditEntry> get entries => _svc.entries;

  void _apply() {
    var list = List<AuditEntry>.from(_svc.entries);

    if (filterAction.value != 'all') {
      list = list.where((e) => e.action == filterAction.value).toList();
    }
    if (filterType.value != 'all') {
      list = list.where((e) => e.targetType == filterType.value).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((e) =>
              e.targetName.toLowerCase().contains(q) ||
              (e.detail ?? '').toLowerCase().contains(q))
          .toList();
    }

    filteredEntries.value = list;
  }

  void setAction(String v) => filterAction.value = v;
  void setType(String v) => filterType.value = v;
  void setSearch(String v) => searchQuery.value = v;

  Future<void> clear() async {
    await _svc.clear();
    Get.snackbar(
      'Cleared',
      'Activity history removed',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}