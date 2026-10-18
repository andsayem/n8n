import 'dart:async';

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
import 'tools/data/n8n_tools_service.dart';
import 'core/services/purchase_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:upgrader/upgrader.dart';
import 'audit/data/services/audit_log_service.dart';
import 'folders/modules/folders/controllers/folder_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  Get.put(PurchaseController(), permanent: true);
  // Status bar style — only statusBarIconBrightness works in edge-to-edge (SDK 35+)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Init services
  await Get.putAsync<InstanceService>(() => InstanceService().init());
  await Get.putAsync<AuditLogService>(() => AuditLogService().init());
  Get.put<N8nApiService>(N8nApiService());
  Get.put<N8nToolsService>(N8nToolsService());

  // Init controllers
  Get.put<AuthController>(AuthController());
  Get.put<ThemeController>(ThemeController());
  Get.lazyPut(() => FolderController());
  final adHelper = AdmobHelper();
  // lifecycle observer
  WidgetsBinding.instance.addObserver(adHelper);

  // Register AdsService with GetX (fixes Get.find<AdsService>() in dashboard)
  final adsService = Get.put<AdsService>(AdsService(), permanent: true);

  // Initialize PurchaseService in the background (non-blocking)
  final purchaseService = PurchaseService();
  // start initialization but do not await so UI can appear quickly
  purchaseService.initialize();
  runApp(const N8nManagerApp());

  // Consent (UMP) and SDK setup run after the first frame so the app never
  // waits on the network to open. Every ad request awaits AdsService.ready,
  // so nothing is requested before the user has answered the consent form.
  unawaited(adsService.initialize());
  final launchedAt = DateTime.now();
  unawaited(adHelper.loadAppOpenAd(
    onLoaded: () {
      // An App Open ad belongs to the moment the app opens. If consent and
      // the ad request took longer than that, keep the ad for the next
      // resume instead of popping it up in the middle of whatever the user
      // is doing by now (AdMob App Open policy).
      if (DateTime.now().difference(launchedAt) > const Duration(seconds: 8)) {
        return;
      }
      Future.delayed(const Duration(seconds: 2), () {
        final controller = Get.find<PurchaseController>();

        // ✅ ONLY SHOW IF NOT SUBSCRIBED
        if (!controller.adsRemoved.value) {
          AdmobHelper.showAppOpenAd();
        }
      });
    },
  ));
}

class N8nManagerApp extends StatelessWidget {
  const N8nManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      // Update status bar icons to match active theme
      // statusBarColor and systemNavigationBarColor are ignored on SDK 35+
      // edge-to-edge mode — only icon brightness is effective.
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
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
