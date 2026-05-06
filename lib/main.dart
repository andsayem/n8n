import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/ads_service.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/theme_controller.dart';
import 'presentation/routes/app_pages.dart';
import 'services/instance_service.dart';
import 'services/n8n_api_service.dart';
import 'core/services/purchase_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:upgrader/upgrader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  Get.put(PurchaseController(), permanent: true);
  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Init services
  await Get.putAsync<InstanceService>(() => InstanceService().init());
  Get.put<N8nApiService>(N8nApiService());

  // Init controllers
  Get.put<AuthController>(AuthController());
  Get.put<ThemeController>(ThemeController());
  final adHelper = AdmobHelper();
  // lifecycle observer
  WidgetsBinding.instance.addObserver(adHelper);

  adHelper.loadAppOpenAd(
    onLoaded: () {
      Future.delayed(const Duration(seconds: 2), () {
        final controller = Get.find<PurchaseController>();

        // ✅ ONLY SHOW IF NOT SUBSCRIBED
        if (!controller.adsRemoved.value) {
          AdmobHelper.showAppOpenAd();
        }
      });
    },
  );

  // Register AdsService with GetX (fixes Get.find<AdsService>() in dashboard)
  final adsService = Get.put<AdsService>(AdsService(), permanent: true);
  await adsService.initialize();

  // Initialize PurchaseService in the background (non-blocking)
  final purchaseService = PurchaseService();
  // start initialization but do not await so UI can appear quickly
  purchaseService.initialize();
  runApp(const N8nManagerApp());
}

class N8nManagerApp extends StatelessWidget {
  const N8nManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      // Update status bar icons to match active theme
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
      );

      return GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
        builder: (context, child) {
          return UpgradeAlert(
            upgrader: Upgrader(
              debugLogging: true,
              // Optional configs:
              // durationUntilAlertAgain: Duration(days: 1),
              // showIgnore: false,
              // showLater: true,
            ),
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            ),
          );
        },
      );
    });
  }
}

void configEasyLoading() {
  EasyLoading.instance
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.indigo
    ..textColor = Colors.black
    ..maskColor = Colors.black.withValues(alpha: 0.5)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..userInteractions = false
    ..dismissOnTap = false;
}
