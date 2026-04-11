import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/data_tables_controller.dart';
import '../widgets/common_widgets.dart';

class DataTablesScreen extends StatefulWidget {
  const DataTablesScreen({super.key});

  @override
  State<DataTablesScreen> createState() => _DataTablesScreenState();
}

class _DataTablesScreenState extends State<DataTablesScreen> {
  BannerAd? _bannerAd;
  @override
  void initState() {
    super.initState();
    _initAdd();
  }

  Future<void> _initAdd() async {
    AdmobHelper.loadInterstitialAd();

    // ⚠️ delay banner load (important)
    Future.delayed(const Duration(seconds: 1), () async {
      if (!mounted) return;

      final width = MediaQuery.of(context).size.width.toInt();
      final ad = await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 27, height: 220),
      );
      if (!mounted) return;

      setState(() {
        _bannerAd = ad;
      });
    });
  }

  Widget build(BuildContext context) {
    final controller = Get.put(DataTablesController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Data Tables'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: controller.fetchData,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.filteredRows.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No Data Found',
                    subtitle:
                        'Connect to an instance with data-producing workflows.',
                    icon: Icons.table_chart_rounded,
                  );
                }

                final columns = controller.rows.first.keys.toList();

                return Column(
                  children: [
                    _buildInfoBanner(context),
                    const SizedBox(height: 16),
                    if (_bannerAd != null) ...[
                      Container(
                        width: double.infinity,
                        height: _bannerAd!.size.height.toDouble(),
                        alignment: Alignment.center,
                        child: AdWidget(ad: _bannerAd!),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildTableCard(context, isDark, columns, controller),
                    const SizedBox(height: 16),
                    _buildPagination(context, controller),
                    const SizedBox(height: 80),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.accentColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Showing workflow execution data. Real-time tables are generated from your n8n nodes.',
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTheme.accentColor),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTableCard(BuildContext context, bool isDark,
      List<String> columns, DataTablesController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: controller.sortColumnIndex.value,
            sortAscending: controller.sortAscending.value,
            headingRowColor: WidgetStateProperty.all(
              isDark ? AppTheme.darkBg : Colors.grey.shade50,
            ),
            dataRowColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTheme.primaryColor.withValues(alpha: 0.08);
              }
              return null;
            }),
            columnSpacing: 32,
            dividerThickness: 0.5,
            headingTextStyle: TextStyle(
              color: isDark ? AppTheme.darkTextSecondary : Colors.grey.shade700,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
            dataTextStyle: TextStyle(
              color:
                  isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              fontSize: 13,
            ),
            columns: columns
                .asMap()
                .entries
                .map(
                  (e) => DataColumn(
                    label: Text(e.value.toUpperCase()),
                    onSort: (i, asc) => controller.onSort(i, asc),
                  ),
                )
                .toList(),
            rows: controller.pagedRows
                .asMap()
                .entries
                .map(
                  (entry) => DataRow(
                    cells: columns.map((col) {
                      final val = entry.value[col]?.toString() ?? '—';
                      if (col == 'Status') {
                        return DataCell(StatusBadge(status: val, fontSize: 10));
                      }
                      return DataCell(Text(val));
                    }).toList(),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 300.ms);
  }

  Widget _buildPagination(
      BuildContext context, DataTablesController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Page ${controller.currentPage.value + 1} of ${controller.totalPages} · ${controller.filteredRows.length} rows',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed:
                  controller.currentPage.value > 0 ? controller.prev : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed:
                  controller.currentPage.value < controller.totalPages - 1
                      ? controller.next
                      : null,
            ),
          ],
        ),
      ],
    );
  }
}
