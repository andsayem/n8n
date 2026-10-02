import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/services/n8n_api_service.dart';
import 'package:n8n_manager/table/data_tables_screen.dart';
import 'package:n8n_manager/tag/data/services/n8n_credential_service.dart';
import 'package:n8n_manager/tag/data/services/n8n_tag_service.dart';
import 'package:n8n_manager/tag/modules/credentials/controllers/credential_controller.dart';
import 'package:n8n_manager/tag/modules/tags/controllers/tag_controller.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/execution_controller.dart';
import '../controllers/workflow_controller.dart';
import 'dashboard_screen.dart';
import '../../folders/modules/folders/controllers/folder_controller.dart';
import '../controllers/data_tables_controller.dart';
import 'execution_screens.dart';
import 'settings_screen.dart';
import 'workflow_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const WorkflowListScreen(),
    const ExecutionListScreen(),
    const DataTablesScreen(),
    const SettingsScreen(),
  ];

  // Controllers created by this screen. A new HomeScreen (after switching
  // instance) is built before the old one is disposed, so each screen only
  // deletes the instances it created itself.
  final List<VoidCallback> _releasers = [];

  T _fresh<T extends Object>(T Function() create) {
    if (Get.isRegistered<T>()) Get.delete<T>(force: true);
    final instance = Get.put<T>(create());
    _releasers.add(() {
      if (Get.isRegistered<T>() && identical(Get.find<T>(), instance)) {
        Get.delete<T>(force: true);
      }
    });
    return instance;
  }

  @override
  void initState() {
    super.initState();
    // Always start from fresh controllers so data from a previously active
    // instance (or the demo) never leaks into this one.
    _fresh(() => DashboardController());
    _fresh(() => WorkflowController());
    _fresh(() => ExecutionController());
    if (Get.isRegistered<DataTableListController>()) {
      Get.delete<DataTableListController>(force: true);
    }
    if (Get.isRegistered<FolderController>()) {
      Get.delete<FolderController>(force: true);
    }
    Get.lazyPut(() => FolderController(), fenix: true);

    // ── Tags & Credentials ──────────────────────────────────────────────────
    final apiService = Get.find<N8nApiService>();
    final tagService = _fresh(() => N8nTagService(apiService.dio));
    final credService = _fresh(() => N8nCredentialService(apiService.dio));
    _fresh(() => TagController(tagService));
    _fresh(() => CredentialController(credService));
  }

  @override
  void dispose() {
    for (final release in _releasers.reversed) {
      release();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _NavItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    isSelected: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.account_tree_rounded,
                    label: 'Workflows',
                    isSelected: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.history_rounded,
                    label: 'Executions',
                    isSelected: _currentIndex == 2,
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.table_chart_rounded,
                    label: 'Tables',
                    isSelected: _currentIndex == 3,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ),
                Expanded(
                  child: _NavItem(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    isSelected: _currentIndex == 4,
                    onTap: () => setState(() => _currentIndex = 4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                key: ValueKey(isSelected),
                size: 22,
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.darkTextMuted,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color:
                    isSelected ? AppTheme.primaryColor : AppTheme.darkTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
