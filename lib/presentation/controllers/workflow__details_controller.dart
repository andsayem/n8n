import 'package:get/get.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import '../../data/models/workflow_model.dart';
import '../../services/n8n_api_service.dart';

class WorkflowDetailController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final Rxn<WorkflowModel> workflow = Rxn<WorkflowModel>();
  final RxBool isLoading = false.obs;
  final RxBool isActing = false.obs;
  final RxString errorMessage = ''.obs;

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

        Get.snackbar(
          'Success',
          'Workflow activated (Demo)',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _apiService.activateWorkflow(workflow.value!.id);
      await loadWorkflow(workflow.value!.id);

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

        Get.snackbar(
          'Success',
          'Workflow deactivated (Demo)',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      await _apiService.deactivateWorkflow(workflow.value!.id);
      await loadWorkflow(workflow.value!.id);

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
        Get.snackbar(
          'Demo Mode',
          'Execution simulated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final result = await _apiService.runWorkflow(workflow.value!.id);

      Get.snackbar(
        'Triggered',
        'Execution ID: ${result['executionId'] ?? 'Started'}',
      );
    } finally {
      isActing.value = false;
    }
  }
}
