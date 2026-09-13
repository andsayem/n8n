import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../data/models/workflow_model.dart';
import '../controllers/workflow_controller.dart';
import '../widgets/banner_ad_view.dart';
import '../widgets/common_widgets.dart';
import '../../folders/modules/folders/views/folder_list_screen.dart';

class WorkflowListScreen extends StatefulWidget {
  const WorkflowListScreen({super.key});

  @override
  State<WorkflowListScreen> createState() => _WorkflowListScreenState();
}

class _WorkflowListScreenState extends State<WorkflowListScreen> {
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    _initAdd();
  }

  Future<void> _initAdd() async {
    // ✅ SKIP all ad loading if user has subscription
    try {
      final purchaseCtrl = Get.find<PurchaseController>();
      if (purchaseCtrl.adsRemoved.value) return;
    } catch (_) {}

    AdmobHelper.loadInterstitialAd();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      // Double-check subscription after delay
      final purchaseCtrl = Get.find<PurchaseController>();
      if (purchaseCtrl.adsRemoved.value) return;

      final width = MediaQuery.of(context).size.width.toInt();

      final ad = await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 50, height: 220),
      );

      if (!mounted) return;

      setState(() {
        _bannerAd = ad;
      });
    } catch (e) {
      debugPrint("Banner load error: $e");

      setState(() {
        _bannerAd = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkflowController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            title: const Text('Workflows'),
            actions: [
              _SortMenu(controller: controller),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    _SearchBar(controller: controller),
                    const SizedBox(height: 8),
                    _FilterTabs(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: Theme.of(context).appBarTheme.backgroundColor ??
                  Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FolderChips(controller: controller),
                    const SizedBox(height: 8),
                    _TagChips(controller: controller),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    itemBuilder: (_, __) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: CardSkeletonLoader(),
                    ),
                  );
                }

                if (controller.hasError.value) {
                  return ErrorRetryWidget(
                    message: controller.errorMessage.value,
                    onRetry: controller.fetchWorkflows,
                  );
                }

                if (controller.filteredWorkflows.isEmpty) {
                  return EmptyStateWidget(
                    title: controller.searchQuery.value.isNotEmpty
                        ? 'No Results Found'
                        : 'No Workflows',
                    subtitle: controller.searchQuery.value.isNotEmpty
                        ? 'Try a different search term.'
                        : 'Create workflows in your n8n instance.',
                    icon: Icons.account_tree_rounded,
                  );
                }

                return Column(
                  children: [
                    // ✅ Banner ad (only shows if loaded — skipped when subscribed)
                    BannerAdView(ad: _bannerAd),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: controller.fetchWorkflows,
                        color: AppTheme.primaryColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.filteredWorkflows.length,
                          itemBuilder: (context, index) {
                            final wf = controller.filteredWorkflows[index];
                            final folder = controller.folders
                                .where((f) => f.id == wf.parentFolderId)
                                .firstOrNull;
                            return _WorkflowCard(
                              workflow: wf,
                              index: index,
                              folderName: folder?.name,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final WorkflowController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.setSearch,
      decoration: InputDecoration(
        hintText: 'Search workflows...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () => controller.setSearch(''),
              )
            : const SizedBox.shrink()),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final WorkflowController controller;

  const _FilterTabs({required this.controller});

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', 'All'),
      ('active', 'Active'),
      ('inactive', 'Inactive'),
    ];

    return Obx(() {
      final selected = controller.filterStatus.value;
      return Container(
        height: 44,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: filters.map((f) {
            final isSelected = selected == f.$1;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.setFilter(f.$1),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).textTheme.labelMedium?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _SortMenu extends StatelessWidget {
  final WorkflowController controller;

  const _SortMenu({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Sort',
      icon: const Icon(Icons.sort_rounded, size: 20),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: controller.setSort,
      itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'updated',
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 16),
                SizedBox(width: 8),
                Text('Recently Updated'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'name',
            child: Row(
              children: [
                Icon(Icons.sort_by_alpha_rounded, size: 16),
                SizedBox(width: 8),
                Text('Name (A-Z)'),
              ],
            ),
          ),
        ],
      );
  }
}

class _FolderChips extends StatelessWidget {
  final WorkflowController controller;

  const _FolderChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.folderIdFilter.value;
      final topFolders = controller.folders.where((f) => f.isRoot).toList();

      return SizedBox(
        width: double.infinity,
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _chip(context,
                label: 'All folders',
                icon: Icons.home_rounded,
                selected: selected == null,
                onTap: () => controller.setFolderFilter(null)),
            for (final f in topFolders)
              _chip(context,
                  label: f.name,
                  icon: Icons.folder_rounded,
                  selected: selected == f.id,
                  onTap: () => controller.setFolderFilter(f.id)),
            _chip(
              context,
              label: 'Manage',
              icon: Icons.folder_open_rounded,
              selected: false,
              onTap: () => Get.to(() => const FolderListScreen()),
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(BuildContext context,
      {required String label,
      required IconData icon,
      required bool selected,
      required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 13,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChips extends StatelessWidget {
  final WorkflowController controller;

  const _TagChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.tags.isEmpty &&
          controller.selectedTags.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        width: double.infinity,
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: controller.tags.map((tag) {
            final selected = controller.isTagSelected(tag.name);
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => controller.toggleTag(tag.name),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.accentColor
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected
                          ? AppTheme.accentColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selected
                            ? Icons.check_rounded
                            : Icons.label_rounded,
                        size: 13,
                        color: selected
                            ? Colors.white
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tag.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}

class _WorkflowCard extends StatelessWidget {
  final WorkflowModel workflow;
  final int index;
  final String? folderName;

  const _WorkflowCard({
    required this.workflow,
    required this.index,
    this.folderName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.workflowDetail, arguments: workflow),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: workflow.active
                ? AppTheme.successColor.withValues(alpha: 0.2)
                : isDark
                    ? AppTheme.darkBorder
                    : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: workflow.active
                        ? AppTheme.successColor.withValues(alpha: 0.15)
                        : AppTheme.darkTextMuted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_tree_rounded,
                    size: 18,
                    color: workflow.active
                        ? AppTheme.successColor
                        : AppTheme.darkTextMuted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    workflow.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: workflow.active ? 'active' : 'inactive'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.hub_rounded,
                  label: '${workflow.nodeCount} nodes',
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label:
                      AppUtils.formatDate(workflow.updatedAt.toIso8601String()),
                ),
              ],
            ),
            if (folderName != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.folder_rounded,
                      size: 13, color: AppTheme.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    folderName!,
                    style: const TextStyle(
                      color: AppTheme.accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (workflow.tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: workflow.tags
                    .take(4)
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 13, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
