// import 'package:get/get.dart';
// import '../../data/models/n8n_credential_model.dart';
// import '../../data/services/n8n_credential_service.dart';

// class CredentialController extends GetxController {
//   final N8nCredentialService _credentialService;

//   CredentialController(this._credentialService);

//   final credentials = <N8nCredential>[].obs;
//   final isLoading = false.obs;
//   final isSubmitting = false.obs;
//   final errorMessage = ''.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     loadCredentials();
//   }

//   Future<void> loadCredentials() async {
//     isLoading.value = true;
//     errorMessage.value = '';
//     try {
//       credentials.value = await _credentialService.getAllCredentials();
//     } catch (e) {
//       errorMessage.value = e.toString().replaceFirst('Exception: ', '');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<bool> createCredential({
//     required String name,
//     required String type,
//     required Map<String, dynamic> data,
//   }) async {
//     if (name.trim().isEmpty || type.trim().isEmpty) {
//       errorMessage.value = 'Name and type are required';
//       return false;
//     }
//     isSubmitting.value = true;
//     errorMessage.value = '';
//     try {
//       final newCred = await _credentialService.createCredential(
//         name: name.trim(),
//         type: type.trim(),
//         data: data,
//       );
//       credentials.insert(0, newCred);
//       return true;
//     } catch (e) {
//       errorMessage.value = e.toString().replaceFirst('Exception: ', '');
//       return false;
//     } finally {
//       isSubmitting.value = false;
//     }
//   }

//   Future<void> deleteCredential(String id) async {
//     try {
//       await _credentialService.deleteCredential(id);
//       credentials.removeWhere((c) => c.id == id);
//     } catch (e) {
//       errorMessage.value = e.toString().replaceFirst('Exception: ', '');
//     }
//   }

//   void clearError() => errorMessage.value = '';
// }
