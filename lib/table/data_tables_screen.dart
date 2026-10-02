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
import 'package:n8n_manager/common/admob_helper.dart';
import 'package:n8n_manager/core/widgets/medium_rect_ad.dart';
import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
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
  @override
  void initState() {
    super.initState();
    AdmobHelper.loadInterstitialAd();
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
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
                  Theme.of(context).scaffoldBackgroundColor,
              pinned: true,
              title: const Text('Data Tables'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: 'New Table',
                  onPressed: () => _openTableEditor(context, ctrl, null),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(68),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: _SearchBar(controller: ctrl),
                ),
              ),
            ),

            // ── Banner Ad ───────────────────────────────────────────────────
            const SliverToBoxAdapter(child: MediumRectAd()),

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
              if (ctrl.filteredTables.isEmpty) {
                return SliverFillRemaining(
                  child: ctrl.searchQuery.value.isNotEmpty
                      ? const EmptyStateWidget(
                          title: 'No Results Found',
                          subtitle: 'Try a different search term.',
                          icon: Icons.search_off_rounded,
                        )
                      : EmptyTablesWidget(
                          onCreateTap: () =>
                              _openTableEditor(context, ctrl, null),
                        ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => TableCard(
                      table: ctrl.filteredTables[i],
                      index: i,
                      onEdit: () => _openTableEditor(
                          context, ctrl, ctrl.filteredTables[i]),
                      onDelete: () =>
                          _confirmDelete(context, ctrl, ctrl.filteredTables[i]),
                      onOpen: () => Get.to(
                        () => DataTableDetailScreen(
                            tableId: ctrl.filteredTables[i].id),
                        transition: Transition.rightToLeft,
                      ),
                    ),
                    childCount: ctrl.filteredTables.length,
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

class _SearchBar extends StatelessWidget {
  final DataTableListController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.setSearch,
      decoration: InputDecoration(
        hintText: 'Search tables...',
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
