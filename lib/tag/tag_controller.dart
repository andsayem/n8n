import 'package:get/get.dart';
import 'package:n8n_manager/tag/tag_model.dart';
import 'package:n8n_manager/tag/tag_service.dart';

class TagController extends GetxController {
  final N8nTagService _tagService;

  TagController(this._tagService);

  final tags = <N8nTag>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTags();
  }

  Future<void> loadTags() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      tags.value = await _tagService.getAllTags();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createTag(String name) async {
    if (name.trim().isEmpty) {
      errorMessage.value = 'Tag name cannot be empty';
      return false;
    }
    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final newTag = await _tagService.createTag(name.trim());
      tags.insert(0, newTag);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateTag(String id, String newName) async {
    if (newName.trim().isEmpty) {
      errorMessage.value = 'Tag name cannot be empty';
      return false;
    }
    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final updated = await _tagService.updateTag(id, newName.trim());
      final index = tags.indexWhere((t) => t.id == id);
      if (index != -1) tags[index] = updated;
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteTag(String id) async {
    try {
      await _tagService.deleteTag(id);
      tags.removeWhere((t) => t.id == id);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  void clearError() => errorMessage.value = '';
}
