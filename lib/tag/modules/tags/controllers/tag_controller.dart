// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import '../../../data/models/n8n_tag_model.dart';
// import '../../../data/services/n8n_tag_service.dart';

// class TagController extends GetxController {
//   final N8nTagService _service;
//   TagController(this._service);

//   final tags = <N8nTag>[].obs;
//   final isLoading = false.obs;
//   final isSubmitting = false.obs;
//   final errorMessage = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadTags();
//   }

//   Future<void> loadTags() async {
//     isLoading.value = true;
//     errorMessage.value = '';
//     try {
//       if (kDebugMode) {
//         print('Loading tags...');
//       }
//       tags.value = await _service.getAllTags();
//       if (kDebugMode) {
//         print('Tags loaded: ${tags.length}');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Tag error: $e');
//       }
//       errorMessage.value = e.toString().replaceFirst('Exception: ', '');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<bool> createTag(String name) async {
//     if (name.trim().isEmpty) {
//       errorMessage.value = 'Tag name cannot be empty';
//       return false;
//     }
//     isSubmitting.value = true;
//     errorMessage.value = '';
//     try {
//       final newTag = await _service.createTag(name.trim());
//       tags.insert(0, newTag);
//       return true;
//     } catch (e) {
//       errorMessage.value = e.toString().replaceFirst('Exception: ', '');
//       return false;
//     } finally {
//       isSubmitting.value = false;
//     }
//   }

//   Future<bool> updateTag(String id, String newName) async {
//     if (newName.trim().isEmpty) {
//       errorMessage.value = 'Tag name cannot be empty';
//       return false;
//     }
//     isSubmitting.value = true;
//     errorMessage.value = '';
//     try {
//       final updated = await _service.updateTag(id, newName.trim());
//       final index = tags.indexWhere((t) => t.id == id);
//       if (index != -1) tags[index] = updated;
//       return true;
//     } catch (e) {
//       errorMessage.value = e.toString().replaceFirst('Exception: ', '');
//       return false;
//     } finally {
//       isSubmitting.value = false;
//     }
//   }

//   Future<void> deleteTag(String id) async {
//     try {
//       await _service.deleteTag(id);
//       tags.removeWhere((t) => t.id == id);
//     } catch (e) {
//       errorMessage.value = e.toString().replaceFirst('Exception: ', '');
//     }
//   }

//   void clearError() => errorMessage.value = '';
// }

import 'package:get/get.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import '../../../data/models/n8n_tag_model.dart';
import '../../../data/services/n8n_tag_service.dart';

class TagController extends GetxController {
  final N8nTagService _service;
  TagController(this._service);

  final tags = <N8nTag>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTags();
  }

  // ================= LOAD TAGS =================
  final auth = Get.find<AuthController>();

  Future<void> loadTags() async {
    isLoading.value = true;

    try {
      if (auth.isDemo) {
        final mockData = MockData.data['tags_response'];

        if (mockData == null) {
          errorMessage.value = "Mock data missing";
          return;
        }

        final list = (mockData['data'] ?? []) as List;

        tags.value = list
            .map((e) => N8nTag.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        return;
      }

      final result = await _service.getAllTags();
      tags.value = result;
    } finally {
      isLoading.value = false;
    }
  } // ================= CREATE TAG =================

  Future<bool> createTag(String name) async {
    if (name.trim().isEmpty) {
      errorMessage.value = 'Tag name cannot be empty';
      return false;
    }

    isSubmitting.value = true;

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final newTag = N8nTag(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
        );

        tags.insert(0, newTag);
        return true;
      }

      // 🌐 REAL API
      final newTag = await _service.createTag(name.trim());
      tags.insert(0, newTag);

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ================= UPDATE TAG =================
  Future<bool> updateTag(String id, String newName) async {
    if (newName.trim().isEmpty) {
      errorMessage.value = 'Tag name cannot be empty';
      return false;
    }

    isSubmitting.value = true;

    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final index = tags.indexWhere((t) => t.id == id);

        if (index != -1) {
          tags[index] = N8nTag(
            id: id,
            name: newName.trim(),
          );
        }

        return true;
      }

      // 🌐 REAL API
      final updated = await _service.updateTag(id, newName.trim());

      final index = tags.indexWhere((t) => t.id == id);
      if (index != -1) tags[index] = updated;

      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ================= DELETE TAG =================
  Future<void> deleteTag(String id) async {
    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        tags.removeWhere((t) => t.id == id);
        return;
      }

      // 🌐 REAL API
      await _service.deleteTag(id);
      tags.removeWhere((t) => t.id == id);
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  void clearError() => errorMessage.value = '';
}
