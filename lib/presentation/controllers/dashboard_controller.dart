import 'package:get/get.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import '../../data/models/dashboard_stats.dart';
import '../../data/models/execution_model.dart';
import '../../data/models/workflow_model.dart';
import '../../data/mock_data.dart';
import '../../services/n8n_api_service.dart';

class DashboardController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();
  final AuthController _auth = Get.find<AuthController>();

  final Rx<DashboardStats> stats = DashboardStats().obs;
  final RxList<ExecutionModel> recentExecutions = <ExecutionModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  // =========================
  // MAIN DASHBOARD FETCH
  // =========================
  Future<void> fetchDashboard() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // =========================
      // DEMO MODE
      // =========================
      if (_auth.isDemo) {
        _loadDemoData();
        return;
      }

      // =========================
      // API CALLS PARALLEL
      // =========================
      final results = await Future.wait([
        _apiService.getWorkflows(),
        _apiService.getExecutions(limit: 50),
      ]);

      final workflows = (results[0] as List<WorkflowModel>?) ?? [];

      final executions = (results[1] as List<ExecutionModel>?) ?? [];

      // =========================
      // SORT EXECUTIONS (NEWEST FIRST)
      // =========================
      executions.sort((a, b) {
        final aTime = DateTime.tryParse(a.startedAt ?? '') ?? DateTime(0);
        final bTime = DateTime.tryParse(b.startedAt ?? '') ?? DateTime(0);
        return bTime.compareTo(aTime);
      });

      // =========================
      // FILTER: TODAY EXECUTIONS
      // =========================
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final todayExecutions = executions.where((e) {
        final dt = DateTime.tryParse(e.startedAt ?? '');
        return dt != null && dt.isAfter(startOfDay);
      }).toList();

      // =========================
      // FAILED EXECUTIONS
      // =========================
      final failedExecutions =
          executions.where((e) => e.status == 'error').length;

      // =========================
      // ACTIVE WORKFLOWS
      // =========================
      final activeWorkflows = workflows.where((w) => w.active == true).length;

      // =========================
      // UPDATE STATS
      // =========================
      stats.value = DashboardStats(
        totalWorkflows: workflows.length,
        activeWorkflows: activeWorkflows,
        failedExecutions: failedExecutions,
        totalExecutionsToday: todayExecutions.length,
      );

      // =========================
      // RECENT EXECUTIONS
      // =========================
      recentExecutions.value = executions.take(10).toList();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DEMO DATA
  // =========================
  void _loadDemoData() {
    // Same sample data the Workflows and Executions tabs show.
    final workflows = (MockData.data['workflows_response']['data'] as List)
        .map((e) => WorkflowModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final executions = (MockData.data['executions_response']['data'] as List)
        .map((e) => ExecutionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      ..sort((a, b) => (b.startedAt ?? '').compareTo(a.startedAt ?? ''));
    final dayAgo = DateTime.now().toUtc().subtract(const Duration(days: 1));

    stats.value = DashboardStats(
      totalWorkflows: workflows.length,
      activeWorkflows: workflows.where((w) => w.active).length,
      failedExecutions: executions.where((e) => e.status == 'error').length,
      totalExecutionsToday: executions
          .where((e) =>
              DateTime.tryParse(e.startedAt ?? '')?.isAfter(dayAgo) ??
              false)
          .length,
    );

    recentExecutions.value = executions.take(10).toList();

    isLoading.value = false;
  }
}
