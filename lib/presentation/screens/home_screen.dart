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

  @override
  void initState() {
    super.initState();
    // Initialize controllers (guard to prevent duplicate registration)
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    if (!Get.isRegistered<WorkflowController>()) {
      Get.put(WorkflowController());
    }
    if (!Get.isRegistered<ExecutionController>()) {
      Get.put(ExecutionController());
    }
    // ── Tags & Credentials ──────────────────────────────────────────────────

    final apiService = Get.find<N8nApiService>();

    if (!Get.isRegistered<N8nTagService>()) {
      Get.put(N8nTagService(apiService.dio));
    }
    if (!Get.isRegistered<N8nCredentialService>()) {
      Get.put(N8nCredentialService(apiService.dio));
    }
    if (!Get.isRegistered<TagController>()) {
      Get.put(TagController(Get.find<N8nTagService>()));
    }
    if (!Get.isRegistered<CredentialController>()) {
      Get.put(CredentialController(Get.find<N8nCredentialService>()));
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<DashboardController>()) {
      Get.delete<DashboardController>();
    }
    if (Get.isRegistered<WorkflowController>()) {
      Get.delete<WorkflowController>();
    }
    if (Get.isRegistered<ExecutionController>()) {
      Get.delete<ExecutionController>();
    }

    // ── Tags & Credentials ──────────────────────────────────────────────────
    if (Get.isRegistered<TagController>()) Get.delete<TagController>();
    if (Get.isRegistered<CredentialController>()) {
      Get.delete<CredentialController>();
    }
    if (Get.isRegistered<N8nTagService>()) Get.delete<N8nTagService>();
    if (Get.isRegistered<N8nCredentialService>()) {
      Get.delete<N8nCredentialService>();
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
