import 'package:get/get.dart';
import 'package:n8n_manager/data/models/workflow_model.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/folders/data/models/n8n_folder_model.dart';
import 'package:n8n_manager/folders/data/services/n8n_folder_service.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import 'package:n8n_manager/services/n8n_api_service.dart';
import 'package:n8n_manager/tag/data/models/n8n_tag_model.dart';
import 'package:n8n_manager/tag/data/services/n8n_tag_service.dart';

class WorkflowController extends GetxController {
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final RxList<WorkflowModel> workflows = <WorkflowModel>[].obs;
  final RxList<WorkflowModel> filteredWorkflows = <WorkflowModel>[].obs;

  final RxList<N8nFolder> folders = <N8nFolder>[].obs;
  final RxList<N8nTag> tags = <N8nTag>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'all'.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxnString folderIdFilter = RxnString();
  final RxString sortOrder = 'updated'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWorkflows();

    ever(searchQuery, (_) => _applyFilter());
    ever(filterStatus, (_) => _applyFilter());
    ever(selectedTags, (_) => _applyFilter());
    ever(folderIdFilter, (_) => _applyFilter());
    ever(sortOrder, (_) => _applyFilter());
  }

  Future<void> fetchWorkflows() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      final auth = Get.find<AuthController>();

      if (auth.isDemo) {
        final mockList = MockData.data['workflows_response']['data'] as List;
        workflows.value =
            mockList.map((e) => WorkflowModel.fromJson(e)).toList();

        final mockFolders = MockData.data['folders_response'];
        folders.value = ((mockFolders?['data'] ?? []) as List)
            .map((e) => N8nFolder.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        final mockTags = MockData.data['tags_response'];
        tags.value = ((mockTags?['data'] ?? []) as List)
            .map((e) => N8nTag.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        _applyFilter();
        return;
      }

      final result = await _apiService.getWorkflows(limit: 100);
      workflows.value = result;

      _loadFolderOptions();
      _loadTagOptions();

      _applyFilter();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFolderOptions() async {
    try {
      final folders = await N8nFolderService(_apiService).getFolders();
      this.folders.value = folders;
    } catch (_) {}
  }

  Future<void> _loadTagOptions() async {
    try {
      final service = Get.find<N8nTagService>();
      tags.value = await service.getAllTags();
    } catch (_) {}
  }

  void _applyFilter() {
    var list = List<WorkflowModel>.from(workflows);

    if (filterStatus.value == 'active') {
      list = list.where((w) => w.active).toList();
    } else if (filterStatus.value == 'inactive') {
      list = list.where((w) => !w.active).toList();
    }

    final folderId = folderIdFilter.value;
    if (folderId != null) {
      list = list.where((w) => w.parentFolderId == folderId).toList();
    }

    if (selectedTags.isNotEmpty) {
      list = list
          .where((w) =>
              selectedTags.every((t) => w.tags.map((e) => e.toLowerCase()).contains(t.toLowerCase())))
          .toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((w) {
        final nodeText = w.nodes
            .map((n) {
              final m = n is Map<String, dynamic> ? n : <String, dynamic>{};
              return '${m['name']} ${m['type']}';
            })
            .join(' ')
            .toLowerCase();
        return w.name.toLowerCase().contains(q) ||
            w.tags.any((t) => t.toLowerCase().contains(q)) ||
            nodeText.contains(q);
      }).toList();
    }

    if (sortOrder.value == 'name') {
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    filteredWorkflows.value = list;
  }

  void setSearch(String q) => searchQuery.value = q;
  void setFilter(String status) => filterStatus.value = status;

  void toggleTag(String tagName) {
    if (selectedTags.contains(tagName)) {
      selectedTags.remove(tagName);
    } else {
      selectedTags.add(tagName);
    }
  }

  bool isTagSelected(String tagName) => selectedTags.contains(tagName);

  void setFolderFilter(String? folderId) => folderIdFilter.value = folderId;

  void setSort(String order) => sortOrder.value = order;

  void clearFilters() {
    searchQuery.value = '';
    filterStatus.value = 'all';
    selectedTags.clear();
    folderIdFilter.value = null;
  }
}