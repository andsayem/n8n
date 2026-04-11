import 'package:get/get.dart';
import '../../services/instance_service.dart';

class ThemeController extends GetxController {
  final InstanceService _instanceService = Get.find<InstanceService>();

  /// Reactive dark mode flag — observed by GetMaterialApp via Obx in main.dart
  final RxBool isDarkMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    isDarkMode.value = await _instanceService.isDarkTheme;
  }

  /// Toggle and persist the user's theme preference.
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _instanceService.setDarkTheme(isDarkMode.value);
  }
}
