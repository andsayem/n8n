import 'package:get/get.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import '../../data/models/workflow_model.dart';
import '../../services/n8n_api_service.dart';

class WorkflowController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final RxList<WorkflowModel> workflows = <WorkflowModel>[].obs;
  final RxList<WorkflowModel> filteredWorkflows = <WorkflowModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'all'.obs; // all, active, inactive

  @override
  void onInit() {
    super.onInit();
    fetchWorkflows();
    ever(searchQuery, (_) => _applyFilter());
    ever(filterStatus, (_) => _applyFilter());
  }

  Future<void> fetchWorkflows() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final mockList = MockData.data['workflows_response']['data'] as List;

        workflows.value =
            mockList.map((e) => WorkflowModel.fromJson(e)).toList();

        _applyFilter();
        return;
      }

      // ✅ REAL API
      final result = await _apiService.getWorkflows(limit: 100);
      workflows.value = result;
      _applyFilter();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilter() {
    var list = List<WorkflowModel>.from(workflows);

    // ✅ status filter
    if (filterStatus.value == 'active') {
      list = list.where((w) => w.active).toList();
    } else if (filterStatus.value == 'inactive') {
      list = list.where((w) => !w.active).toList();
    }

    // ✅ search filter
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((w) => w.name.toLowerCase().contains(q)).toList();
    }

    filteredWorkflows.value = list;
  }

  void setSearch(String query) => searchQuery.value = query;
  void setFilter(String status) => filterStatus.value = status;
}

class WorkflowDetailController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final Rxn<WorkflowModel> workflow = Rxn<WorkflowModel>();
  final RxBool isLoading = false.obs;
  final RxBool isActing = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> loadWorkflow(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // ✅ REAL API
      workflow.value = await _apiService.getWorkflow(id);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activate() async {
    if (workflow.value == null) return;

    isActing.value = true;

    try {
      // ✅ REAL API
      await _apiService.activateWorkflow(workflow.value!.id);
      await loadWorkflow(workflow.value!.id);

      Get.snackbar(
        'Success',
        'Workflow activated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
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
      // ✅ REAL API
      await _apiService.deactivateWorkflow(workflow.value!.id);
      await loadWorkflow(workflow.value!.id);

      Get.snackbar(
        'Success',
        'Workflow deactivated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
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
      // ✅ REAL API
      final result = await _apiService.runWorkflow(workflow.value!.id);

      Get.snackbar(
        'Workflow Triggered',
        'Execution ID: ${result['executionId'] ?? 'Started'}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isActing.value = false;
    }
  }
}
