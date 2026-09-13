import 'package:get/get.dart';
import 'package:n8n_manager/audit/modules/activity/views/activity_screen.dart';
import 'package:n8n_manager/folders/modules/folders/views/folder_list_screen.dart';
import 'package:n8n_manager/presentation/screens/splash_screen.dart';
import '../../core/constants/app_constants.dart';
import '../screens/execution_screens.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/subscription_screen.dart';
import '../screens/workflow_detail_screen.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.workflowDetail,
      page: () => const WorkflowDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.executionDetail,
      page: () => const ExecutionDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.folders,
      page: () => const FolderListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.activity,
      page: () => const ActivityScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
