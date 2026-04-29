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
import '../widgets/common_widgets.dart';

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
    AdmobHelper.loadInterstitialAd();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      final width = MediaQuery.of(context).size.width.toInt();

      final ad = await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 50, height: 220),
      );

      if (!mounted) return;

      setState(() {
        _bannerAd = ad; // শুধু এটুকুই যথেষ্ট
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
            floating: true,
            snap: true,
            title: const Text('Workflows'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    _SearchBar(controller: controller),
                    const SizedBox(height: 10),
                    _FilterChips(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: Obx(() {
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
              Obx(() {
                final controller = Get.find<PurchaseController>();

                final showBanner =
                    _bannerAd != null && !controller.adsRemoved.value;

                if (!showBanner) return const SizedBox();

                return SizedBox(
                  width: double.infinity,
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                );
              }),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchWorkflows,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.filteredWorkflows.length,
                    itemBuilder: (context, index) {
                      return _WorkflowCard(
                        workflow: controller.filteredWorkflows[index],
                        index: index,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
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
          borderSide: BorderSide(color: AppTheme.primaryColor),
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

class _FilterChips extends StatelessWidget {
  final WorkflowController controller;

  const _FilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final filters = ['all', 'active', 'inactive'];
      return Row(
        children: filters
            .map((f) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f.capitalize!),
                    selected: controller.filterStatus.value == f,
                    onSelected: (_) => controller.setFilter(f),
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: controller.filterStatus.value == f
                          ? Colors.white
                          : Theme.of(context).textTheme.labelMedium?.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: controller.filterStatus.value == f
                          ? AppTheme.primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                    backgroundColor: Theme.of(context).cardColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ))
            .toList(),
      );
    });
  }
}

class _WorkflowCard extends StatelessWidget {
  final WorkflowModel workflow;
  final int index;

  const _WorkflowCard({required this.workflow, required this.index});

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
