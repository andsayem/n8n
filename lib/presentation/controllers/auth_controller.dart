import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/instance_model.dart';
import '../../services/instance_service.dart';
import '../../services/n8n_api_service.dart';

class AuthController extends GetxController {
  final InstanceService _instanceService = Get.find<InstanceService>();
  final N8nApiService _apiService = Get.find<N8nApiService>();

  final RxList<N8nInstance> instances = <N8nInstance>[].obs;
  final Rxn<N8nInstance> activeInstance = Rxn<N8nInstance>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInstances();
  }

  bool get isDemo =>
      activeInstance.value?.apiKey ==
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhOGNiNTMzZi03NWNlLTRiMzAtODhkMy1mY2FmZTViNTZjNDQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiNzZlMjlhYmEtMDBhYi00NWY2LTljYmYtZTc2Y2Q3MmNkZWZiIiwiaWF0IjoxNzc1Mzc1Mzk4fQ.hi17mKMcVjPe7_SF5n4AAOIMMqPUZ1G6fjH9UoXcvdc";
  Future<bool> loginWithDemo() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await Future.delayed(const Duration(seconds: 1));

      final demoInstance = N8nInstance(
        id: const Uuid().v4(),
        name: "n8n Demo",
        baseUrl: "https://n8n-production-c2c8.up.railway.app/",
        apiKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhOGNiNTMzZi03NWNlLTRiMzAtODhkMy1mY2FmZTViNTZjNDQiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiNzZlMjlhYmEtMDBhYi00NWY2LTljYmYtZTc2Y2Q3MmNkZWZiIiwiaWF0IjoxNzc1Mzc1Mzk4fQ.hi17mKMcVjPe7_SF5n4AAOIMMqPUZ1G6fjH9UoXcvdc",
        createdAt: DateTime.now(),
      );

      print('-----------------------------');

      print(demoInstance.toJson());

      activeInstance.value = demoInstance;

      // API configure (important 🔥)
      _configureApi(demoInstance);

      // ✅ Save demo instance to secure storage so it persists on restart
      await _instanceService.saveInstance(demoInstance);
      await _instanceService.setActiveInstanceId(demoInstance.id);

      // Optional: list e add korte paro
      instances.add(demoInstance);

      // ✅ Mark as logged in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);

      Get.offAllNamed(AppRoutes.home);

      return true;
    } catch (e) {
      errorMessage.value = 'Demo login failed';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInstances() async {
    instances.value = await _instanceService.getInstances();
    activeInstance.value = await _instanceService.getActiveInstance();
    if (activeInstance.value != null) {
      _configureApi(activeInstance.value!);
    }
  }

  void _configureApi(N8nInstance instance) {
    _apiService.configure(instance.baseUrl, instance.apiKey);
  }

  Future<bool> addInstance({
    required String name,
    required String baseUrl,
    required String apiKey,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final sanitizedUrl = AppUtils.sanitizeUrl(baseUrl);
      _apiService.configure(sanitizedUrl, apiKey);

      final connected = await _apiService.testConnection();
      if (!connected) {
        errorMessage.value = 'Could not connect. Check URL and API key.';
        return false;
      }

      final instance = N8nInstance(
        id: const Uuid().v4(),
        name: name,
        baseUrl: sanitizedUrl,
        apiKey: apiKey,
        createdAt: DateTime.now(),
      );

      await _instanceService.saveInstance(instance);
      instances.add(instance);

      // ✅ Mark as logged in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);

      await switchInstance(instance);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> switchInstance(N8nInstance instance) async {
    await _instanceService.setActiveInstanceId(instance.id);
    activeInstance.value = instance;
    _configureApi(instance);
    Get.offAllNamed(AppRoutes.home);
  }

  Future<void> removeInstance(String id) async {
    await _instanceService.deleteInstance(id);
    instances.removeWhere((i) => i.id == id);
    if (activeInstance.value?.id == id) {
      activeInstance.value = null;
      if (instances.isNotEmpty) {
        await switchInstance(instances.first);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    }
  }

  Future<void> logout() async {
    await _instanceService.clearActiveInstance();
    activeInstance.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  Future<bool> is_logged_in() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  //logout and clear all data
  Future<void> logoutAndClearData() async {
    //  await _instanceService.clearAllData();
    activeInstance.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    Get.offAllNamed(AppRoutes.login);
  }
}
