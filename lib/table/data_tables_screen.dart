// import 'package:flutter/material.dart' hide TableRow;
// import 'package:get/get.dart';
// import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
// import 'package:n8n_manager/presentation/widgets/common_widgets.dart';
// import 'package:n8n_manager/table/empty_tables_widget.dart';
// import 'package:n8n_manager/table/table_card.dart';
// import '../../core/theme/app_theme.dart';
// import '../../data/models/data_table_model.dart';
// import 'data_table_detail_screen.dart';
// import 'table_editor_screen.dart';

// class DataTablesScreen extends StatelessWidget {
//   const DataTablesScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.put(DataTableListController());

//     return Scaffold(
//       body: RefreshIndicator(
//         onRefresh: ctrl.fetchTables,
//         color: AppTheme.primaryColor,
//         child: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               floating: true,
//               snap: true,
//               title: const Text('Data Tables'),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.add_rounded),
//                   tooltip: 'New Table',
//                   onPressed: () => _openTableEditor(context, ctrl, null),
//                 ),
//               ],
//             ),
//             Obx(() {
//               if (ctrl.isLoading.value) {
//                 return SliverPadding(
//                   padding: const EdgeInsets.all(20),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                       (_, i) => const Padding(
//                         padding: EdgeInsets.only(bottom: 12),
//                         child: CardSkeletonLoader(),
//                       ),
//                       childCount: 3,
//                     ),
//                   ),
//                 );
//               }
//               if (ctrl.hasError.value) {
//                 return SliverFillRemaining(
//                   child: ErrorRetryWidget(
//                     message: ctrl.errorMessage.value,
//                     onRetry: ctrl.fetchTables,
//                   ),
//                 );
//               }
//               if (ctrl.tables.isEmpty) {
//                 return SliverFillRemaining(
//                   child: EmptyTablesWidget(
//                     onCreateTap: () => _openTableEditor(context, ctrl, null),
//                   ),
//                 );
//               }
//               return SliverPadding(
//                 padding: const EdgeInsets.all(16),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (ctx, i) => TableCard(
//                       table: ctrl.tables[i],
//                       index: i,
//                       onEdit: () =>
//                           _openTableEditor(context, ctrl, ctrl.tables[i]),
//                       onDelete: () =>
//                           _confirmDelete(context, ctrl, ctrl.tables[i]),
//                       onOpen: () => Get.to(
//                         () => DataTableDetailScreen(tableId: ctrl.tables[i].id),
//                         transition: Transition.rightToLeft,
//                       ),
//                     ),
//                     childCount: ctrl.tables.length,
//                   ),
//                 ),
//               );
//             }),
//             const SliverToBoxAdapter(child: SizedBox(height: 80)),
//           ],
//         ),
//       ),
//     );
//   }

//   void _openTableEditor(
//     BuildContext context,
//     DataTableListController listCtrl,
//     DataTableModel? existing,
//   ) {
//     Get.to(
//       () => TableEditorScreen(existing: existing),
//       transition: Transition.downToUp,
//     )?.then((created) {
//       if (created == true) listCtrl.fetchTables();
//     });
//   }

//   void _confirmDelete(
//     BuildContext context,
//     DataTableListController ctrl,
//     DataTableModel table,
//   ) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: Theme.of(context).cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete Table?'),
//         content: Text('Permanently delete "${table.name}" and all its rows?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               ctrl.deleteTable(table.id);
//             },
//             child: const Text(
//               'Delete',
//               style: TextStyle(color: AppTheme.errorColor),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart' hide TableRow;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:n8n_manager/common/admob_helper.dart';
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
import 'package:n8n_manager/presentation/widgets/common_widgets.dart';
import 'package:n8n_manager/table/empty_tables_widget.dart';
import 'package:n8n_manager/table/table_card.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/data_table_model.dart';
import 'data_table_detail_screen.dart';
import 'table_editor_screen.dart';

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
    _initAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _initAd() async {
    // ✅ SKIP all ad loading if user has subscription
    try {
      final purchaseCtrl = Get.find<PurchaseController>();
      if (purchaseCtrl.adsRemoved.value) return;
    } catch (_) {}

    AdmobHelper.loadInterstitialAd();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    try {
      // Double-check subscription after delay (may have loaded by now)
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
    final ctrl = Get.put(DataTableListController());

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ctrl.fetchTables,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text('Data Tables'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'New Table',
                  onPressed: () => _openTableEditor(context, ctrl, null),
                ),
              ],
            ),

            // ── Banner Ad ───────────────────────────────────────────────────
            if (_bannerAd != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
                    ),
                  ),
                ),
              ),

            Obx(() {
              if (ctrl.isLoading.value) {
                return SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: CardSkeletonLoader(),
                      ),
                      childCount: 3,
                    ),
                  ),
                );
              }
              if (ctrl.hasError.value) {
                return SliverFillRemaining(
                  child: ErrorRetryWidget(
                    message: ctrl.errorMessage.value,
                    onRetry: ctrl.fetchTables,
                  ),
                );
              }
              if (ctrl.tables.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyTablesWidget(
                    onCreateTap: () => _openTableEditor(context, ctrl, null),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => TableCard(
                      table: ctrl.tables[i],
                      index: i,
                      onEdit: () =>
                          _openTableEditor(context, ctrl, ctrl.tables[i]),
                      onDelete: () =>
                          _confirmDelete(context, ctrl, ctrl.tables[i]),
                      onOpen: () => Get.to(
                        () => DataTableDetailScreen(tableId: ctrl.tables[i].id),
                        transition: Transition.rightToLeft,
                      ),
                    ),
                    childCount: ctrl.tables.length,
                  ),
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  void _openTableEditor(
    BuildContext context,
    DataTableListController listCtrl,
    DataTableModel? existing,
  ) {
    Get.to(
      () => TableEditorScreen(existing: existing),
      transition: Transition.downToUp,
    )?.then((created) {
      if (created == true) listCtrl.fetchTables();
    });
  }

  void _confirmDelete(
    BuildContext context,
    DataTableListController ctrl,
    DataTableModel table,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Table?'),
        content: Text('Permanently delete "${table.name}" and all its rows?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteTable(table.id);
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
