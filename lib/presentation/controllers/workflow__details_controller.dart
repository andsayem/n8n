import 'package:get/get.dart';
import 'package:n8n_manager/audit/data/models/audit_entry.dart';
import 'package:n8n_manager/audit/data/services/audit_log_service.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/folders/data/models/n8n_folder_model.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import 'package:n8n_manager/presentation/controllers/workflow_controller.dart';
import '../../data/models/workflow_model.dart';
import '../../services/n8n_api_service.dart';

class WorkflowDetailController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final Rxn<WorkflowModel> workflow = Rxn<WorkflowModel>();
  final RxBool isLoading = false.obs;
  final RxBool isActing = false.obs;
  final RxString errorMessage = ''.obs;

  AuditLogService get _audit => Get.find<AuditLogService>();

  Future<void> loadWorkflow(String id) async {
    isLoading.value = true;

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final mock = MockData.data['workflows_response']['data'] as List;

        final data =
            mock.firstWhere((e) => e['id'] == id, orElse: () => mock.first);

        workflow.value = WorkflowModel.fromJson(data);
        return;
      }

      // 🌐 REAL API
      workflow.value = await _apiService.getWorkflow(id);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activate() async {
    if (workflow.value == null) return;

    isActing.value = true;

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE (NO API CALL)
      if (auth.isDemo) {
        workflow.value = workflow.value!.copyWith(active: true);

        _audit.log(
          action: AuditAction.activated,
          targetType: AuditTarget.workflow,
          targetName: workflow.value!.name,
        );

        Get.snackbar(
          'Success',
          'Workflow activated (Demo)',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _apiService.activateWorkflow(workflow.value!.id);
      await loadWorkflow(workflow.value!.id);

      _audit.log(
        action: AuditAction.activated,
        targetType: AuditTarget.workflow,
        targetName: workflow.value!.name,
      );

      Get.snackbar(
        'Success',
        'Workflow activated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActing.value = false;
    }
  }

  Future<void> deactivate() async {
    if (workflow.value == null) return;

    isActing.value = true;

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        workflow.value = workflow.value!.copyWith(active: false);

        _audit.log(
          action: AuditAction.deactivated,
          targetType: AuditTarget.workflow,
          targetName: workflow.value!.name,
        );

        Get.snackbar(
          'Success',
          'Workflow deactivated (Demo)',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _apiService.deactivateWorkflow(workflow.value!.id);
      await loadWorkflow(workflow.value!.id);

      _audit.log(
        action: AuditAction.deactivated,
        targetType: AuditTarget.workflow,
        targetName: workflow.value!.name,
      );

      Get.snackbar(
        'Success',
        'Workflow deactivated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActing.value = false;
    }
  }

  Future<void> runNow() async {
    if (workflow.value == null) return;

    isActing.value = true;

    try {
      final auth = Get.find<AuthController>();

      if (auth.isDemo) {
        _audit.log(
          action: AuditAction.ran,
          targetType: AuditTarget.workflow,
          targetName: workflow.value!.name,
        );

        Get.snackbar(
          'Demo Mode',
          'Execution simulated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final result = await _apiService.runWorkflow(workflow.value!.id);

      _audit.log(
        action: AuditAction.ran,
        targetType: AuditTarget.workflow,
        targetName: workflow.value!.name,
      );

      Get.snackbar(
        'Triggered',
        'Execution ID: ${result['executionId'] ?? 'Started'}',
      );
    } finally {
      isActing.value = false;
    }
  }

  Future<void> moveToFolder(String? folderId, N8nFolder? folder) async {
    final wf = workflow.value;
    if (wf == null) return;

    isActing.value = true;

    try {
      if (!Get.find<AuthController>().isDemo) {
        await _apiService.updateWorkflow(
          wf.id,
          parentFolderId: folderId,
        );
      }

      workflow.value = WorkflowModel(
        id: wf.id,
        name: wf.name,
        active: wf.active,
        createdAt: wf.createdAt,
        updatedAt: wf.updatedAt,
        tags: wf.tags,
        nodes: wf.nodes,
        connections: wf.connections,
        settings: wf.settings,
        description: wf.description,
        parentFolderId: folderId,
        lastExecutionStatus: wf.lastExecutionStatus,
        lastExecutionAt: wf.lastExecutionAt,
      );

      _audit.log(
        action: AuditAction.movedToFolder,
        targetType: AuditTarget.workflow,
        targetName: wf.name,
        detail: folder?.name ?? 'Root',
      );

      if (Get.isRegistered<WorkflowController>()) {
        Get.find<WorkflowController>().fetchWorkflows();
      }

      Get.snackbar(
        'Moved',
        'Workflow moved to ${folder?.name ?? 'Root'}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActing.value = false;
    }
  }
}
