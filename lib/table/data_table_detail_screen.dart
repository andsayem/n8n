import 'package:flutter/material.dart' hide TableRow;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import 'package:n8n_manager/presentation/widgets/common_widgets.dart';
import 'package:n8n_manager/table/pagination_widget.dart';
import 'package:n8n_manager/table/rows_table.dart';
import 'package:n8n_manager/table/stats_bar.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';
import 'row_editor_sheet.dart';

class DataTableDetailScreen extends StatefulWidget {
  final String tableId;
  const DataTableDetailScreen({super.key, required this.tableId});

  @override
  State<DataTableDetailScreen> createState() => _DataTableDetailScreenState();
}

class _DataTableDetailScreenState extends State<DataTableDetailScreen> {
  late DataTableDetailController _ctrl;

  @override
  void initState() {
    super.initState();
    _initAdd();
    _ctrl = Get.put(DataTableDetailController());
    _ctrl.load(widget.tableId);
  }

  Future<void> _initAdd() async {
    try {
      final purchaseCtrl = Get.find<PurchaseController>();
      if (purchaseCtrl.adsRemoved.value) return;
    } catch (_) {}

    AdmobHelper.loadInterstitialAd();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      final purchaseCtrl = Get.find<PurchaseController>();
      if (purchaseCtrl.adsRemoved.value) return;

      final width = MediaQuery.of(context).size.width.toInt();
      await AdmobHelper.loadBannerAd(
        size: AdSize(width: width - 50, height: 220),
      );

      if (!mounted) return;
    } catch (e) {
      debugPrint("Banner load error: $e");
    }
  }

  @override
  void dispose() {
    Get.delete<DataTableDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Obx(() {
            final tbl = _ctrl.table.value;
            return SliverAppBar(
              pinned: true,
              floating: false,
              expandedHeight: 100,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Get.back(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search_rounded),
                  onPressed: () => _showSearchBar(context),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'Add Row',
                  onPressed: tbl == null
                      ? null
                      : () => _openRowEditor(context, tbl, null),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  tbl?.name ?? 'Table',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, 16),
              ),
            );
          }),
          Obx(() {
            if (_ctrl.isLoading.value) {
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: SkeletonLoader(height: 64, borderRadius: 10),
                    ),
                    childCount: 6,
                  ),
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }),
          Obx(() {
            if (!_ctrl.isLoading.value && _ctrl.errorMessage.value.isNotEmpty) {
              return SliverFillRemaining(
                child: ErrorRetryWidget(
                  message: _ctrl.errorMessage.value,
                  onRetry: () => _ctrl.load(widget.tableId),
                ),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }),
          Obx(() {
            final tbl = _ctrl.table.value;
            if (tbl == null) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(
              child: StatsBar(ctrl: _ctrl, table: tbl),
            );
          }),
          Obx(() {
            if (_ctrl.searchQuery.value.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      'Results for "${_ctrl.searchQuery.value}"',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _ctrl.setSearch(''),
                      child: const Text(
                        'Clear',
                        style:
                            TextStyle(color: AppTheme.errorColor, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() {
            final tbl = _ctrl.table.value;
            if (tbl == null ||
                _ctrl.isLoading.value ||
                _ctrl.errorMessage.value.isNotEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RowsTable(
                  ctrl: _ctrl,
                  table: tbl,
                  onEdit: (row) => _openRowEditor(context, tbl, row),
                  onDelete: (row) => _confirmDeleteRow(context, row),
                ),
              ),
            );
          }),
          Obx(() {
            if (_ctrl.table.value == null) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }
            return SliverToBoxAdapter(child: PaginationWidget(ctrl: _ctrl));
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: Obx(() {
        final tbl = _ctrl.table.value;
        if (tbl == null) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => _openRowEditor(context, tbl, null),
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        );
      }),
    );
  }

  void _showSearchBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        final tc = TextEditingController(text: _ctrl.searchQuery.value);
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Search Rows'),
          content: TextField(
            controller: tc,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search any field...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: _ctrl.setSearch,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _ctrl.setSearch('');
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _openRowEditor(
    BuildContext context,
    DataTableModel tbl,
    TableRow? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: RowEditorSheet(table: tbl, existing: existing, ctrl: _ctrl),
      ),
    );
  }

  void _confirmDeleteRow(BuildContext context, TableRow row) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Row?'),
        content: const Text('This row will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.deleteRow(row.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
