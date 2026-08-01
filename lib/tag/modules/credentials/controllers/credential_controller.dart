import 'package:get/get.dart';
import 'package:n8n_manager/data/mock_data.dart';
import 'package:n8n_manager/presentation/controllers/auth_controller.dart';
import '../../../data/models/n8n_credential_model.dart';
import '../../../data/services/n8n_credential_service.dart';

class CredentialController extends GetxController {
  final N8nCredentialService _service;
  CredentialController(this._service);

  final credentials = <N8nCredential>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCredentials();
  }

  // ================= LOAD CREDENTIALS =================
  Future<void> loadCredentials() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final mockData = MockData.data['credentials_response'];

        if (mockData == null) {
          errorMessage.value = 'Mock data missing';
          return;
        }

        final list = (mockData['data'] ?? []) as List;

        credentials.value = list
            .map((e) => N8nCredential.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        return;
      }

      // 🌐 REAL API
      credentials.value = await _service.getAllCredentials();
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createCredential({
    required String name,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    if (name.trim().isEmpty || type.trim().isEmpty) {
      errorMessage.value = 'Name and type are required';
      return false;
    }
    isSubmitting.value = true;
    errorMessage.value = '';
    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        final newCred = N8nCredential(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name.trim(),
          type: type.trim(),
          scopes: const ['credential:update', 'credential:delete'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        credentials.insert(0, newCred);
        return true;
      }

      // 🌐 REAL API
      final newCred = await _service.createCredential(
        name: name.trim(),
        type: type.trim(),
        data: data,
      );
      credentials.insert(0, newCred);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteCredential(String id) async {
    try {
      final auth = Get.find<AuthController>();

      // 🔥 DEMO MODE
      if (auth.isDemo) {
        credentials.removeWhere((c) => c.id == id);
        return;
      }

      // 🌐 REAL API
      await _service.deleteCredential(id);
      credentials.removeWhere((c) => c.id == id);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  void clearError() => errorMessage.value = '';
}
