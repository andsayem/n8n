import 'package:get/get.dart';
import 'package:n8n_manager/audit/data/models/audit_entry.dart';
import 'package:n8n_manager/audit/data/services/audit_log_service.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/folders/data/models/n8n_folder_model.dart';
import 'package:n8n_manager/folders/data/services/n8n_folder_service.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import 'package:n8n_manager/services/n8n_api_service.dart';

class FolderController extends GetxController {
  late final N8nFolderService _service;
  late final AuditLogService _audit;

  final RxList<N8nFolder> folders = <N8nFolder>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  FolderController({N8nFolderService? service}) {
    _service = service ?? N8nFolderService(Get.find<N8nApiService>());
  }

  @override
  void onInit() {
    super.onInit();
    _audit = Get.find<AuditLogService>();
    loadFolders();
  }

  bool get isSupported => folders.isNotEmpty || !hasError.value;

  Future<void> loadFolders() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final auth = Get.find<AuthController>();

      if (auth.isDemo) {
        final mock = MockData.data['folders_response'];
        final list = (mock?['data'] ?? []) as List;
        folders.value = list
            .map((e) => N8nFolder.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return;
      }

      folders.value = await _service.getFolders();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  List<N8nFolder> topLevelFolders() =>
      folders.where((f) => f.isRoot).toList();

  List<N8nFolder> childrenOf(String? parentId) {
    if (parentId == null) return topLevelFolders();
    return folders.where((f) => f.parentFolderId == parentId).toList();
  }

  bool hasChildren(String id) => childrenOf(id).isNotEmpty;

  N8nFolder? folderById(String? id) {
    if (id == null) return null;
    for (final f in folders) {
      if (f.id == id) return f;
    }
    return null;
  }

  Future<bool> createFolder(
    String name, {
    String? parentFolderId,
  }) async {
    try {
      final auth = Get.find<AuthController>();

      if (auth.isDemo) {
        final folder = N8nFolder(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          parentFolderId: parentFolderId,
        );
        folders.add(folder);
        await _audit.log(
          action: AuditAction.created,
          targetType: AuditTarget.folder,
          targetName: folder.name,
          targetId: folder.id,
        );
        return true;
      }

      final folder = await _service.createFolder(
        name.trim(),
        parentFolderId: parentFolderId,
      );
      folders.add(folder);
      await _audit.log(
        action: AuditAction.created,
        targetType: AuditTarget.folder,
        targetName: folder.name,
        targetId: folder.id,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> renameFolder(N8nFolder folder, String newName) async {
    try {
      final auth = Get.find<AuthController>();

      if (auth.isDemo) {
        folders[folders.indexWhere((f) => f.id == folder.id)] = N8nFolder(
          id: folder.id,
          name: newName.trim(),
          parentFolderId: folder.parentFolderId,
        );
        await _audit.log(
          action: AuditAction.renamed,
          targetType: AuditTarget.folder,
          targetName: newName.trim(),
          targetId: folder.id,
        );
        return true;
      }

      final updated = await _service.renameFolder(folder.id, newName.trim());
      final idx = folders.indexWhere((f) => f.id == folder.id);
      if (idx >= 0) folders[idx] = updated;
      await _audit.log(
        action: AuditAction.renamed,
        targetType: AuditTarget.folder,
        targetName: updated.name,
        targetId: updated.id,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> deleteFolder(N8nFolder folder) async {
    try {
      final auth = Get.find<AuthController>();

      if (auth.isDemo) {
        folders.removeWhere(
          (f) => f.id == folder.id || f.parentFolderId == folder.id,
        );
        await _audit.log(
          action: AuditAction.deleted,
          targetType: AuditTarget.folder,
          targetName: folder.name,
          targetId: folder.id,
        );
        return true;
      }

      await _service.deleteFolder(folder.id);
      folders.removeWhere(
        (f) => f.id == folder.id || f.parentFolderId == folder.id,
      );
      await _audit.log(
        action: AuditAction.deleted,
        targetType: AuditTarget.folder,
        targetName: folder.name,
        targetId: folder.id,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> moveWorkflowToFolder({
    required String workflowId,
    required String workflowName,
    String? folderId,
  }) async {
    try {
      final auth = Get.find<AuthController>();
      final target = folderById(folderId);
      final targetName = target?.name ?? 'Root';

      if (auth.isDemo) {
        await _audit.log(
          action: AuditAction.movedToFolder,
          targetType: AuditTarget.workflow,
          targetName: workflowName,
          targetId: workflowId,
          detail: targetName,
        );
        return true;
      }

      await Get.find<N8nApiService>().updateWorkflow(
        workflowId,
        parentFolderId: folderId,
      );
      await _audit.log(
        action: AuditAction.movedToFolder,
        targetType: AuditTarget.workflow,
        targetName: workflowName,
        targetId: workflowId,
        detail: targetName,
      );
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }
}