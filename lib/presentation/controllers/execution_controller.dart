import 'package:get/get.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import '../../data/models/execution_model.dart';
import '../../services/n8n_api_service.dart';

class ExecutionController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final RxList<ExecutionModel> executions = <ExecutionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasError = false.obs;
  final RxString filterStatus = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExecutions();
    ever(filterStatus, (_) => fetchExecutions());
  }

  Future<void> fetchExecutions() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final mockList =
            MockData.data['executions_response']['data'] as List;

        List filteredList = mockList;

        // ✅ filter apply
        if (filterStatus.value != 'all') {
          filteredList = mockList
              .where((e) => e['status'] == filterStatus.value)
              .toList();
        }

        executions.value = filteredList
            .map((e) => ExecutionModel.fromJson(e))
            .toList();

        return;
      }

      // ✅ REAL API
      final status =
          filterStatus.value == 'all' ? null : filterStatus.value;

      final result =
          await _apiService.getExecutions(limit: 50, status: status);

      executions.value = result;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String status) => filterStatus.value = status;
}

class ExecutionDetailController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final Rxn<ExecutionModel> execution = Rxn<ExecutionModel>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<String> expandedNodes = <String>[].obs;

  Future<void> loadExecution(String id) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final mockList =
            MockData.data['executions_response']['data'] as List;

        final found = mockList.cast<Map<String, dynamic>?>().firstWhere(
          (e) => e?['id'] == id,
          orElse: () => null,
        );

        if (found != null) {
          execution.value = ExecutionModel.fromJson(found);
        }

        return;
      }

      // ✅ REAL API
      execution.value = await _apiService.getExecution(id);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleNode(String nodeName) {
    if (expandedNodes.contains(nodeName)) {
      expandedNodes.remove(nodeName);
    } else {
      expandedNodes.add(nodeName);
    }
  }
}