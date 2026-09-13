import 'dart:convert';
import 'package:get/get.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/audit_entry.dart';

class AuditLogService extends GetxService {
  final RxList<AuditEntry> entries = <AuditEntry>[].obs;
  late SharedPreferences _prefs;

  Future<AuditLogService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
    return this;
  }

  void _load() {
    try {
      final raw = _prefs.getString(AppConstants.auditLogKey);
      if (raw == null || raw.isEmpty) return;
      final list = (jsonDecode(raw) as List<dynamic>)
          .map((e) => AuditEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      entries.value = list;
    } catch (_) {
      entries.clear();
    }
  }

  Future<void> _persist() async {
    try {
      final jsonList =
          entries.take(AppConstants.auditLogLimit).map((e) => e.toJson());
      await _prefs.setString(
        AppConstants.auditLogKey,
        jsonEncode(jsonList.toList()),
      );
    } catch (_) {}
  }

  Future<void> log({
    required String action,
    required String targetType,
    required String targetName,
    String? targetId,
    String? detail,
  }) async {
    String? actor;
    try {
      actor = Get.find<AuthController>().activeInstance.value?.name;
    } catch (_) {}

    final entry = AuditEntry(
      id: const Uuid().v4(),
      action: action,
      targetType: targetType,
      targetName: targetName,
      targetId: targetId,
      detail: detail,
      actor: actor,
      timestamp: DateTime.now(),
    );
    entries.insert(0, entry);
    if (entries.length > AppConstants.auditLogLimit) {
      entries.removeRange(
        AppConstants.auditLogLimit,
        entries.length,
      );
    }
    await _persist();
  }

  Future<void> clear() async {
    entries.clear();
    await _prefs.remove(AppConstants.auditLogKey);
  }
}