// import 'package:flutter/material.dart' hide TableRow;
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:n8n_manager/common/admob_helper.dart';
// import 'package:n8n_manager/presentation/controllers/data_tables_controller.dart';
// import 'package:n8n_manager/presentation/controllers/purchase_controller.dart';
// import 'package:uuid/uuid.dart';
// import '../../core/theme/app_theme.dart';
// import '../../core/utils/app_utils.dart';
// import '../../data/models/data_table_model.dart';
// import '../widgets/common_widgets.dart';

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
//                   child: _EmptyTablesWidget(
//                     onCreateTap: () => _openTableEditor(context, ctrl, null),
//                   ),
//                 );
//               }
//               return SliverPadding(
//                 padding: const EdgeInsets.all(16),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (ctx, i) => _TableCard(
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
//       // floatingActionButton: FloatingActionButton.extended(
//       //   onPressed: () =>
//       //       _openTableEditor(context, Get.put(DataTableListController()), null),
//       //   backgroundColor: AppTheme.primaryColor,
//       //   icon: const Icon(Icons.add_rounded, color: Colors.white),
//       //   label: const Text(
//       //     'New Table',
//       //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
//       //   ),
//       // ),
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

// // ── Table Card ────────────────────────────────────────────────────────────────
// class _TableCard extends StatelessWidget {
//   final DataTableModel table;
//   final int index;
//   final VoidCallback onOpen;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _TableCard({
//     required this.table,
//     required this.index,
//     required this.onOpen,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = [
//       AppTheme.primaryColor,
//       AppTheme.accentColor,
//       AppTheme.warningColor,
//       const Color(0xFF9B59B6),
//     ];
//     final accent = colors[index % colors.length];

//     return GestureDetector(
//       onTap: onOpen,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Theme.of(context).cardColor,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: accent.withValues(alpha: 0.25)),
//         ),
//         child: Column(
//           children: [
//             // Header strip
//             Container(
//               height: 5,
//               decoration: BoxDecoration(
//                 color: accent,
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(16),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(14),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 44,
//                     height: 44,
//                     decoration: BoxDecoration(
//                       color: accent.withValues(alpha: 0.12),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Icon(
//                       Icons.table_chart_rounded,
//                       color: accent,
//                       size: 22,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           table.name,
//                           style:
//                               Theme.of(context).textTheme.titleSmall?.copyWith(
//                                     fontWeight: FontWeight.w700,
//                                     color: Theme.of(
//                                       context,
//                                     ).textTheme.bodyLarge?.color,
//                                   ),
//                         ),
//                         if (table.description.isNotEmpty)
//                           Text(
//                             table.description,
//                             style: Theme.of(
//                               context,
//                             ).textTheme.labelSmall,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                       ],
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     onSelected: (v) {
//                       if (v == 'edit') onEdit();
//                       if (v == 'delete') onDelete();
//                     },
//                     color: Theme.of(context).cardColor,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     itemBuilder: (_) => [
//                       const PopupMenuItem(
//                         value: 'edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit_rounded, size: 16),
//                             SizedBox(width: 8),
//                             Text('Edit Schema'),
//                           ],
//                         ),
//                       ),
//                       const PopupMenuItem(
//                         value: 'delete',
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.delete_rounded,
//                               size: 16,
//                               color: AppTheme.errorColor,
//                             ),
//                             SizedBox(width: 8),
//                             Text(
//                               'Delete',
//                               style: TextStyle(
//                                 color: AppTheme.errorColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//               child: Row(
//                 children: [
//                   _Chip(
//                     icon: Icons.view_column_rounded,
//                     label: '${table.columns.length} columns',
//                     color: accent,
//                   ),
//                   const SizedBox(width: 8),
//                   _Chip(
//                     icon: Icons.update_rounded,
//                     label: AppUtils.timeAgo(
//                       table.updatedAt.toIso8601String(),
//                     ),
//                     color: AppTheme.darkTextMuted,
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: accent.withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(
//                           'Open',
//                           style: TextStyle(
//                             color: accent,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         Icon(
//                           Icons.arrow_forward_rounded,
//                           size: 13,
//                           color: accent,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       )
//           .animate(delay: Duration(milliseconds: index * 60))
//           .fadeIn(duration: 350.ms)
//           .slideY(begin: 0.12, end: 0),
//     );
//   }
// }

// class _Chip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   const _Chip({required this.icon, required this.label, required this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 12, color: color),
//         const SizedBox(width: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: color,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _EmptyTablesWidget extends StatelessWidget {
//   final VoidCallback onCreateTap;
//   const _EmptyTablesWidget({required this.onCreateTap});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryColor.withValues(alpha: 0.1),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.table_chart_rounded,
//               size: 52,
//               color: AppTheme.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             'No Tables Yet',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             'Create your first data table to store structured data.',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: AppTheme.darkTextSecondary),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: onCreateTap,
//             icon: const Icon(Icons.add_rounded, size: 18),
//             label: const Text('Create Table'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // TABLE DETAIL SCREEN  (rows view + add/edit/delete rows)
// // ══════════════════════════════════════════════════════════════════════════════
// class DataTableDetailScreen extends StatefulWidget {
//   final String tableId;
//   const DataTableDetailScreen({super.key, required this.tableId});

//   @override
//   State<DataTableDetailScreen> createState() => _DataTableDetailScreenState();
// }

// class _DataTableDetailScreenState extends State<DataTableDetailScreen> {
//   late DataTableDetailController _ctrl;
//   BannerAd? _bannerAd;

//   @override
//   void initState() {
//     super.initState();
//     _initAdd();
//     _ctrl = Get.put(DataTableDetailController());
//     _ctrl.load(widget.tableId);
//   }

//   Future<void> _initAdd() async {
//     // ✅ SKIP all ad loading if user has subscription
//     try {
//       final purchaseCtrl = Get.find<PurchaseController>();
//       if (purchaseCtrl.adsRemoved.value) return;
//     } catch (_) {}

//     AdmobHelper.loadInterstitialAd();

//     await Future.delayed(const Duration(seconds: 1));

//     if (!mounted) return;

//     try {
//       // Double-check subscription after delay (may have loaded by now)
//       final purchaseCtrl = Get.find<PurchaseController>();
//       if (purchaseCtrl.adsRemoved.value) return;

//       final width = MediaQuery.of(context).size.width.toInt();

//       final ad = await AdmobHelper.loadBannerAd(
//         size: AdSize(width: width - 50, height: 220),
//       );

//       if (!mounted) return;

//       setState(() {
//         _bannerAd = ad;
//       });
//     } catch (e) {
//       debugPrint("Banner load error: $e");

//       setState(() {
//         _bannerAd = null;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     Get.delete<DataTableDetailController>();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         // ← NO outer Obx wrapper
//         slivers: [
//           Obx(() {
//             // ← targeted Obx only for AppBar title/actions
//             final tbl = _ctrl.table.value;
//             return SliverAppBar(
//               pinned: true,
//               floating: false,
//               expandedHeight: 100,
//               leading: IconButton(
//                 icon: const Icon(Icons.arrow_back_rounded),
//                 onPressed: () => Get.back(),
//               ),
//               actions: [
//                 IconButton(
//                   icon: const Icon(Icons.search_rounded),
//                   onPressed: () => _showSearchBar(context),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add_rounded),
//                   tooltip: 'Add Row',
//                   onPressed: tbl == null
//                       ? null
//                       : () => _openRowEditor(context, tbl, null),
//                 ),
//               ],
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Text(
//                   tbl?.name ?? 'Table',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                 ),
//                 titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, 16),
//               ),
//             );
//           }),

//           // Loading state
//           Obx(() {
//             if (_ctrl.isLoading.value) {
//               return SliverPadding(
//                 padding: const EdgeInsets.all(16),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate(
//                     (_, i) => const Padding(
//                       padding: EdgeInsets.only(bottom: 10),
//                       child: SkeletonLoader(height: 64, borderRadius: 10),
//                     ),
//                     childCount: 6,
//                   ),
//                 ),
//               );
//             }
//             return const SliverToBoxAdapter(child: SizedBox.shrink());
//           }),

//           // Error state
//           Obx(() {
//             if (!_ctrl.isLoading.value && _ctrl.errorMessage.value.isNotEmpty) {
//               return SliverFillRemaining(
//                 child: ErrorRetryWidget(
//                   message: _ctrl.errorMessage.value,
//                   onRetry: () => _ctrl.load(widget.tableId),
//                 ),
//               );
//             }
//             return const SliverToBoxAdapter(child: SizedBox.shrink());
//           }),

//           // Stats bar
//           Obx(() {
//             final tbl = _ctrl.table.value;
//             if (tbl == null) {
//               return const SliverToBoxAdapter(child: SizedBox.shrink());
//             }
//             return SliverToBoxAdapter(
//               child: _StatsBar(ctrl: _ctrl, table: tbl),
//             );
//           }),

//           // Search hint
//           Obx(() {
//             if (_ctrl.searchQuery.value.isEmpty) {
//               return const SliverToBoxAdapter(child: SizedBox.shrink());
//             }
//             return SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.search_rounded,
//                       size: 14,
//                       color: AppTheme.primaryColor,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Results for "${_ctrl.searchQuery.value}"',
//                       style: const TextStyle(
//                         color: AppTheme.primaryColor,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () => _ctrl.setSearch(''),
//                       child: const Text(
//                         'Clear',
//                         style: TextStyle(
//                           color: AppTheme.errorColor,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }),

//           // Rows table
//           Obx(() {
//             final tbl = _ctrl.table.value;
//             if (tbl == null ||
//                 _ctrl.isLoading.value ||
//                 _ctrl.errorMessage.value.isNotEmpty) {
//               return const SliverToBoxAdapter(child: SizedBox.shrink());
//             }
//             return SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: _RowsTable(
//                   ctrl: _ctrl,
//                   table: tbl,
//                   onEdit: (row) => _openRowEditor(context, tbl, row),
//                   onDelete: (row) => _confirmDeleteRow(context, row),
//                 ),
//               ),
//             );
//           }),

//           // Pagination
//           Obx(() {
//             if (_ctrl.table.value == null) {
//               return const SliverToBoxAdapter(child: SizedBox.shrink());
//             }
//             return SliverToBoxAdapter(child: _Pagination(ctrl: _ctrl));
//           }),

//           const SliverToBoxAdapter(child: SizedBox(height: 80)),
//         ],
//       ),
//       floatingActionButton: Obx(() {
//         // ← separate Obx for FAB
//         final tbl = _ctrl.table.value;
//         if (tbl == null) return const SizedBox.shrink();
//         return FloatingActionButton(
//           onPressed: () => _openRowEditor(context, tbl, null),
//           backgroundColor: AppTheme.primaryColor,
//           child: const Icon(Icons.add_rounded, color: Colors.white),
//         );
//       }),
//     );
//   }

//   void _showSearchBar(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) {
//         final tc = TextEditingController(text: _ctrl.searchQuery.value);
//         return AlertDialog(
//           backgroundColor: Theme.of(context).cardColor,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: const Text('Search Rows'),
//           content: TextField(
//             controller: tc,
//             autofocus: true,
//             decoration: const InputDecoration(
//               hintText: 'Search any field...',
//               prefixIcon: Icon(Icons.search_rounded),
//             ),
//             onChanged: _ctrl.setSearch,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _ctrl.setSearch('');
//                 Navigator.pop(ctx);
//               },
//               child: const Text('Clear'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(ctx),
//               child: const Text('Done'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _openRowEditor(
//     BuildContext context,
//     DataTableModel tbl,
//     TableRow? existing,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).cardColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (_) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: RowEditorSheet(table: tbl, existing: existing, ctrl: _ctrl),
//       ),
//     );
//   }

//   void _confirmDeleteRow(BuildContext context, TableRow row) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: Theme.of(context).cardColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete Row?'),
//         content: const Text('This row will be permanently removed.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               _ctrl.deleteRow(row.id);
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

// // ── Stats bar ─────────────────────────────────────────────────────────────────
// class _StatsBar extends StatelessWidget {
//   final DataTableDetailController ctrl;
//   final DataTableModel table;
//   const _StatsBar({required this.ctrl, required this.table});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
//         ),
//       ),
//       child: Obx(
//         () => Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _StatItem(
//               label: 'Total Rows',
//               value: '${ctrl.rows.length}',
//               color: AppTheme.primaryColor,
//             ),
//             Container(width: 1, height: 30, color: AppTheme.darkBorder),
//             _StatItem(
//               label: 'Filtered',
//               value: '${ctrl.filteredRows.length}',
//               color: AppTheme.accentColor,
//             ),
//             Container(width: 1, height: 30, color: AppTheme.darkBorder),
//             _StatItem(
//               label: 'Columns',
//               value: '${table.columns.length}',
//               color: AppTheme.warningColor,
//             ),
//             Container(width: 1, height: 30, color: AppTheme.darkBorder),
//             _StatItem(
//               label: 'Page',
//               value: '${ctrl.currentPage.value + 1}/${ctrl.totalPages}',
//               color: AppTheme.darkTextSecondary,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _StatItem extends StatelessWidget {
//   final String label;
//   final String value;
//   final Color color;
//   const _StatItem({
//     required this.label,
//     required this.value,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) => Column(
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.w800,
//               fontSize: 18,
//             ),
//           ),
//           Text(
//             label,
//             style: const TextStyle(color: AppTheme.darkTextMuted, fontSize: 10),
//           ),
//         ],
//       );
// }

// // ── Rows table ────────────────────────────────────────────────────────────────
// class _RowsTable extends StatelessWidget {
//   final DataTableDetailController ctrl;
//   final DataTableModel table;
//   final void Function(TableRow) onEdit;
//   final void Function(TableRow) onDelete;

//   const _RowsTable({
//     required this.ctrl,
//     required this.table,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final pageRows = ctrl.currentPageRows;

//     if (pageRows.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 40),
//         child: Center(
//           child: Text(
//             'No rows found',
//             style: TextStyle(color: AppTheme.darkTextMuted),
//           ),
//         ),
//       );
//     }

//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
//         ),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: DataTable(
//             sortColumnIndex: ctrl.sortColIndex.value < table.columns.length
//                 ? ctrl.sortColIndex.value
//                 : null,
//             sortAscending: ctrl.sortAscending.value,
//             headingRowColor: WidgetStateProperty.all(
//               isDark ? AppTheme.darkBg : Colors.grey.shade50,
//             ),
//             dividerThickness: 0.5,
//             columnSpacing: 20,
//             horizontalMargin: 14,
//             headingTextStyle: TextStyle(
//               color: isDark ? AppTheme.darkTextSecondary : Colors.grey.shade700,
//               fontWeight: FontWeight.w700,
//               fontSize: 11,
//               letterSpacing: 0.5,
//             ),
//             dataTextStyle: TextStyle(
//               color:
//                   isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
//               fontSize: 13,
//             ),
//             columns: [
//               ...table.columns.asMap().entries.map(
//                     (e) => DataColumn(
//                       label: Text(e.value.name.toUpperCase()),
//                       onSort: (i, asc) => ctrl.setSort(i, asc),
//                     ),
//                   ),
//               const DataColumn(label: Text('')), // actions
//             ],
//             rows: pageRows
//                 .map(
//                   (row) => DataRow(
//                     cells: [
//                       ...table.columns.map((col) {
//                         final val = row.data[col.id];
//                         return DataCell(_CellValue(col: col, value: val));
//                       }),
//                       DataCell(
//                         Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             InkWell(
//                               onTap: () => onEdit(row),
//                               borderRadius: BorderRadius.circular(6),
//                               child: const Padding(
//                                 padding: EdgeInsets.all(6),
//                                 child: Icon(
//                                   Icons.edit_rounded,
//                                   size: 15,
//                                   color: AppTheme.primaryColor,
//                                 ),
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () => onDelete(row),
//                               borderRadius: BorderRadius.circular(6),
//                               child: const Padding(
//                                 padding: EdgeInsets.all(6),
//                                 child: Icon(
//                                   Icons.delete_rounded,
//                                   size: 15,
//                                   color: AppTheme.errorColor,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//                 .toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CellValue extends StatelessWidget {
//   final TableColumn col;
//   final dynamic value;
//   const _CellValue({required this.col, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     if (value == null) {
//       return const Text('—', style: TextStyle(color: AppTheme.darkTextMuted));
//     }

//     switch (col.type) {
//       case ColumnType.boolean:
//         final v = value == true || value == 'true';
//         return Icon(
//           v ? Icons.check_circle_rounded : Icons.cancel_rounded,
//           size: 18,
//           color: v ? AppTheme.successColor : AppTheme.errorColor,
//         );
//       case ColumnType.select:
//         return StatusBadge(status: value.toString(), fontSize: 10);
//       case ColumnType.number:
//         return Text(
//           value.toString(),
//           style: const TextStyle(fontFamily: 'monospace'),
//         );
//       default:
//         return Text(
//           value.toString(),
//           overflow: TextOverflow.ellipsis,
//           maxLines: 1,
//         );
//     }
//   }
// }

// // ── Pagination ────────────────────────────────────────────────────────────────
// class _Pagination extends StatelessWidget {
//   final DataTableDetailController ctrl;
//   const _Pagination({required this.ctrl});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
//       child: Row(
//         children: [
//           Text(
//             'Page ${ctrl.currentPage.value + 1} of ${ctrl.totalPages}  ·  ${ctrl.filteredRows.length} rows',
//             style: Theme.of(context).textTheme.labelSmall,
//           ),
//           const Spacer(),
//           _PageBtn(
//             icon: Icons.chevron_left_rounded,
//             onTap: ctrl.currentPage.value > 0 ? ctrl.prevPage : null,
//           ),
//           const SizedBox(width: 4),
//           _PageBtn(
//             icon: Icons.chevron_right_rounded,
//             onTap: ctrl.currentPage.value < ctrl.totalPages - 1
//                 ? ctrl.nextPage
//                 : null,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _PageBtn extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   const _PageBtn({required this.icon, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     final enabled = onTap != null;
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(8),
//       child: Container(
//         padding: const EdgeInsets.all(6),
//         decoration: BoxDecoration(
//           color: enabled
//               ? AppTheme.primaryColor.withValues(alpha: 0.1)
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(
//           icon,
//           size: 20,
//           color: enabled ? AppTheme.primaryColor : AppTheme.darkTextMuted,
//         ),
//       ),
//     );
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // ROW EDITOR BOTTOM SHEET
// // ══════════════════════════════════════════════════════════════════════════════
// class RowEditorSheet extends StatefulWidget {
//   final DataTableModel table;
//   final TableRow? existing;
//   final DataTableDetailController ctrl;

//   const RowEditorSheet({
//     super.key,
//     required this.table,
//     required this.existing,
//     required this.ctrl,
//   });

//   @override
//   State<RowEditorSheet> createState() => _RowEditorSheetState();
// }

// class _RowEditorSheetState extends State<RowEditorSheet> {
//   // ✅ FIX: Store controller reference as a local field so GetX can
//   //         reliably track the reactive subscription inside Obx.
//   late final DataTableDetailController _ctrl;

//   late Map<String, dynamic> _values;
//   final Map<String, TextEditingController> _textCtrls = {};

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = widget.ctrl; // ✅ capture once
//     _values = {};
//     for (final col in widget.table.columns) {
//       _values[col.id] = widget.existing?.data[col.id];
//       if (col.type == ColumnType.text ||
//           col.type == ColumnType.number ||
//           col.type == ColumnType.date) {
//         _textCtrls[col.id] = TextEditingController(
//           text: widget.existing?.data[col.id]?.toString() ?? '',
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     for (final c in _textCtrls.values) {
//       c.dispose();
//     }
//     super.dispose();
//   }

//   Future<void> _save() async {
//     // Sync text controllers into _values
//     for (final col in widget.table.columns) {
//       if (_textCtrls.containsKey(col.id)) {
//         final raw = _textCtrls[col.id]!.text.trim();
//         if (col.type == ColumnType.number) {
//           _values[col.id] = num.tryParse(raw) ?? raw;
//         } else {
//           _values[col.id] = raw.isEmpty ? null : raw;
//         }
//       }
//     }

//     bool ok;
//     if (widget.existing == null) {
//       ok = await _ctrl.createRow(Map.from(_values));
//     } else {
//       ok = await _ctrl.updateRow(widget.existing!.id, Map.from(_values));
//     }
//     if (ok && mounted) {
//       Navigator.pop(context);
//       Get.snackbar(
//         widget.existing == null ? '✅ Row Added' : '✅ Row Updated',
//         widget.existing == null
//             ? 'New row created successfully.'
//             : 'Row updated.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppTheme.successColor.withValues(alpha: 0.15),
//         duration: const Duration(seconds: 2),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEdit = widget.existing != null;
//     return DraggableScrollableSheet(
//       initialChildSize: 0.75,
//       minChildSize: 0.4,
//       maxChildSize: 0.95,
//       expand: false,
//       builder: (_, scrollCtrl) => Column(
//         children: [
//           // Handle
//           Center(
//             child: Container(
//               margin: const EdgeInsets.only(top: 10, bottom: 4),
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: AppTheme.darkBorder,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           // Header
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
//             child: Row(
//               children: [
//                 Text(
//                   isEdit ? 'Edit Row' : 'Add Row',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                       ),
//                 ),
//                 const Spacer(),
//                 // ✅ FIX: Use _ctrl (local field) instead of widget.ctrl
//                 //         so GetX properly registers the reactive subscription.
//                 Obx(
//                   () => _ctrl.isSaving.value
//                       ? const Padding(
//                           padding: EdgeInsets.all(12),
//                           child: SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: AppTheme.primaryColor,
//                             ),
//                           ),
//                         )
//                       : TextButton.icon(
//                           onPressed: _save,
//                           icon: const Icon(Icons.save_rounded, size: 16),
//                           label: Text(isEdit ? 'Update' : 'Save'),
//                           style: TextButton.styleFrom(
//                             foregroundColor: AppTheme.primaryColor,
//                             textStyle: const TextStyle(
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           // Fields
//           Expanded(
//             child: ListView(
//               controller: scrollCtrl,
//               padding: const EdgeInsets.all(20),
//               children: widget.table.columns.map((col) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 18),
//                   child: _FieldEditor(
//                     col: col,
//                     value: _values[col.id],
//                     textCtrl: _textCtrls[col.id],
//                     onChanged: (v) => setState(() => _values[col.id] = v),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FieldEditor extends StatelessWidget {
//   final TableColumn col;
//   final dynamic value;
//   final TextEditingController? textCtrl;
//   final ValueChanged<dynamic> onChanged;

//   const _FieldEditor({
//     required this.col,
//     required this.value,
//     required this.textCtrl,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               col.name,
//               style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: Theme.of(context).textTheme.bodyLarge?.color,
//                   ),
//             ),
//             if (col.required) ...[
//               const SizedBox(width: 4),
//               const Text(
//                 '*',
//                 style: TextStyle(color: AppTheme.errorColor, fontSize: 14),
//               ),
//             ],
//             const Spacer(),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//               decoration: BoxDecoration(
//                 color: AppTheme.primaryColor.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 TableColumn.typeLabel(col.type),
//                 style: const TextStyle(
//                   color: AppTheme.primaryColor,
//                   fontSize: 10,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         _buildInput(context),
//       ],
//     );
//   }

//   Widget _buildInput(BuildContext context) {
//     switch (col.type) {
//       case ColumnType.boolean:
//         final v = value == true || value == 'true';
//         return GestureDetector(
//           onTap: () => onChanged(!v),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: v
//                   ? AppTheme.successColor.withValues(alpha: 0.1)
//                   : Theme.of(context).cardColor,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: v
//                     ? AppTheme.successColor.withValues(alpha: 0.4)
//                     : AppTheme.darkBorder,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   v ? Icons.check_circle_rounded : Icons.circle_outlined,
//                   color: v ? AppTheme.successColor : AppTheme.darkTextMuted,
//                   size: 22,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   v ? 'True' : 'False',
//                   style: TextStyle(
//                     color: v ? AppTheme.successColor : AppTheme.darkTextMuted,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const Spacer(),
//                 Switch(value: v, onChanged: onChanged),
//               ],
//             ),
//           ),
//         );

//       case ColumnType.select:
//         return DropdownButtonFormField<String>(
//           initialValue: col.options.contains(value?.toString())
//               ? value?.toString()
//               : null,
//           hint: Text('Select ${col.name}...'),
//           decoration: const InputDecoration(isDense: true),
//           dropdownColor: Theme.of(context).cardColor,
//           items: col.options
//               .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
//               .toList(),
//           onChanged: onChanged,
//         );

//       case ColumnType.date:
//         return GestureDetector(
//           onTap: () async {
//             final picked = await showDatePicker(
//               context: context,
//               initialDate:
//                   DateTime.tryParse(textCtrl?.text ?? '') ?? DateTime.now(),
//               firstDate: DateTime(2000),
//               lastDate: DateTime(2100),
//             );
//             if (picked != null) {
//               final formatted = picked.toIso8601String().substring(0, 10);
//               textCtrl?.text = formatted;
//               onChanged(formatted);
//             }
//           },
//           child: AbsorbPointer(
//             child: TextFormField(
//               controller: textCtrl,
//               decoration: const InputDecoration(
//                 hintText: 'YYYY-MM-DD',
//                 prefixIcon: Icon(Icons.calendar_today_rounded, size: 18),
//               ),
//             ),
//           ),
//         );

//       case ColumnType.number:
//         return TextFormField(
//           controller: textCtrl,
//           keyboardType: const TextInputType.numberWithOptions(decimal: true),
//           decoration: InputDecoration(
//             hintText: 'Enter ${col.name}...',
//             prefixIcon: const Icon(Icons.numbers_rounded, size: 18),
//           ),
//         );

//       default: // text
//         return TextFormField(
//           controller: textCtrl,
//           maxLines: col.name.toLowerCase().contains('note') ||
//                   col.name.toLowerCase().contains('desc')
//               ? 3
//               : 1,
//           decoration: InputDecoration(
//             hintText: 'Enter ${col.name}...',
//             prefixIcon: const Icon(Icons.text_fields_rounded, size: 18),
//           ),
//         );
//     }
//   }
// }

// // ══════════════════════════════════════════════════════════════════════════════
// // TABLE SCHEMA EDITOR  (create new / edit existing table structure)
// // ══════════════════════════════════════════════════════════════════════════════
// class TableEditorScreen extends StatefulWidget {
//   final DataTableModel? existing;
//   const TableEditorScreen({super.key, this.existing});

//   @override
//   State<TableEditorScreen> createState() => _TableEditorScreenState();
// }

// class _TableEditorScreenState extends State<TableEditorScreen> {
//   // ✅ FIX: Store as local field for the same reason — reliable Obx tracking.
//   late final DataTableEditController _ctrl;

//   final _nameCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = Get.put(DataTableEditController()); // ✅ assigned to local field
//     if (widget.existing != null) {
//       _nameCtrl.text = widget.existing!.name;
//       _descCtrl.text = widget.existing!.description;
//       _ctrl.loadFromTable(widget.existing!);
//     } else {
//       // Default columns
//       _ctrl.columns.value = [
//         TableColumn(
//           id: const Uuid().v4(),
//           name: 'Name',
//           type: ColumnType.text,
//           required: true,
//         ),
//         TableColumn(
//           id: const Uuid().v4(),
//           name: 'Status',
//           type: ColumnType.select,
//           options: ['Active', 'Inactive'],
//         ),
//       ];
//     }
//   }

//   @override
//   void dispose() {
//     Get.delete<DataTableEditController>();
//     _nameCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate()) return;
//     FocusScope.of(context).unfocus();

//     DataTableModel? result;
//     if (widget.existing == null) {
//       result = await _ctrl.createTable(_nameCtrl.text, _descCtrl.text);
//     } else {
//       result = await _ctrl.updateTable(
//         widget.existing!,
//         _nameCtrl.text,
//         _descCtrl.text,
//       );
//     }

//     if (result != null && mounted) {
//       Get.back(result: true);
//       Get.snackbar(
//         widget.existing == null ? '✅ Table Created' : '✅ Table Updated',
//         '"${result.name}" saved successfully.',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: AppTheme.successColor.withValues(alpha: 0.15),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isNew = widget.existing == null;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isNew ? 'New Table' : 'Edit Schema'),
//         leading: IconButton(
//           icon: const Icon(Icons.close_rounded),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           // ✅ FIX: Use _ctrl (local field) instead of Get.put(...)
//           //         so GetX reliably tracks isSaving inside the Obx.
//           Obx(
//             () => _ctrl.isSaving.value
//                 ? const Padding(
//                     padding: EdgeInsets.all(14),
//                     child: SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: AppTheme.primaryColor,
//                       ),
//                     ),
//                   )
//                 : TextButton.icon(
//                     onPressed: _save,
//                     icon: const Icon(Icons.save_rounded, size: 18),
//                     label: const Text('Save'),
//                     style: TextButton.styleFrom(
//                       foregroundColor: AppTheme.primaryColor,
//                       textStyle: const TextStyle(fontWeight: FontWeight.w700),
//                     ),
//                   ),
//           ),
//         ],
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(20),
//           children: [
//             // Error banner
//             Obx(() {
//               if (_ctrl.errorMessage.value.isEmpty) {
//                 return const SizedBox.shrink();
//               }
//               return Container(
//                 margin: const EdgeInsets.only(bottom: 16),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: AppTheme.errorColor.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppTheme.errorColor.withValues(alpha: 0.3),
//                   ),
//                 ),
//                 child: Text(
//                   _ctrl.errorMessage.value,
//                   style: const TextStyle(
//                     color: AppTheme.errorColor,
//                     fontSize: 13,
//                   ),
//                 ),
//               );
//             }),

//             // Basic info card
//             _SchemaCard(
//               title: 'Table Info',
//               icon: Icons.info_outline_rounded,
//               children: [
//                 TextFormField(
//                   controller: _nameCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'Table Name',
//                     hintText: 'e.g. Customers, Orders...',
//                     prefixIcon: Icon(Icons.table_chart_rounded),
//                   ),
//                   validator: (v) =>
//                       v == null || v.trim().isEmpty ? 'Name is required' : null,
//                 ),
//                 const SizedBox(height: 14),
//                 TextFormField(
//                   controller: _descCtrl,
//                   decoration: const InputDecoration(
//                     labelText: 'Description (optional)',
//                     hintText: 'What is this table for?',
//                     prefixIcon: Icon(Icons.notes_rounded),
//                   ),
//                   maxLines: 2,
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // Columns section
//             Row(
//               children: [
//                 const Text(
//                   'Columns',
//                   style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
//                 ),
//                 const Spacer(),
//                 TextButton.icon(
//                   onPressed: () => _showAddColumnSheet(context),
//                   icon: const Icon(Icons.add_rounded, size: 16),
//                   label: const Text('Add Column'),
//                   style: TextButton.styleFrom(
//                     foregroundColor: AppTheme.primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             // Column list (reorderable)
//             Obx(
//               () => ReorderableListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _ctrl.columns.length,
//                 onReorder: _ctrl.reorderColumns,
//                 itemBuilder: (ctx, i) {
//                   final col = _ctrl.columns[i];
//                   return _ColumnTile(
//                     key: ValueKey(col.id),
//                     col: col,
//                     index: i,
//                     onEdit: () => _showEditColumnSheet(context, col),
//                     onDelete: () => _ctrl.removeColumn(col.id),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 8),
//             // Add column hint
//             GestureDetector(
//               onTap: () => _showAddColumnSheet(context),
//               child: Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: AppTheme.primaryColor.withValues(alpha: 0.3),
//                     style: BorderStyle.solid,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.add_rounded,
//                       color: AppTheme.primaryColor,
//                       size: 18,
//                     ),
//                     SizedBox(width: 8),
//                     Text(
//                       'Add Column',
//                       style: TextStyle(
//                         color: AppTheme.primaryColor,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 80),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAddColumnSheet(BuildContext context) =>
//       _showColumnSheet(context, null);

//   void _showEditColumnSheet(BuildContext context, TableColumn col) =>
//       _showColumnSheet(context, col);

//   void _showColumnSheet(BuildContext context, TableColumn? existing) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Theme.of(context).cardColor,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (_) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: ColumnEditorSheet(
//           existing: existing,
//           onSave: (col) {
//             if (existing == null) {
//               _ctrl.addColumn(col);
//             } else {
//               _ctrl.updateColumn(col);
//             }
//           },
//         ),
//       ),
//     );
//   }
// }

// // ── Column tile ───────────────────────────────────────────────────────────────
// class _ColumnTile extends StatelessWidget {
//   final TableColumn col;
//   final int index;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _ColumnTile({
//     super.key,
//     required this.col,
//     required this.index,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     const typeColors = {
//       ColumnType.text: AppTheme.accentColor,
//       ColumnType.number: AppTheme.warningColor,
//       ColumnType.boolean: AppTheme.successColor,
//       ColumnType.date: AppTheme.primaryColor,
//       ColumnType.select: Color(0xFF9B59B6),
//     };
//     final color = typeColors[col.type] ?? AppTheme.primaryColor;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
//         ),
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: color.withValues(alpha: 0.12),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: _colTypeIcon(col.type, color),
//         ),
//         title: Row(
//           children: [
//             Text(
//               col.name,
//               style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                     fontWeight: FontWeight.w700,
//                     color: Theme.of(context).textTheme.bodyLarge?.color,
//                   ),
//             ),
//             if (col.required) ...[
//               const SizedBox(width: 6),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
//                 decoration: BoxDecoration(
//                   color: AppTheme.errorColor.withValues(alpha: 0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: const Text(
//                   'required',
//                   style: TextStyle(
//                     color: AppTheme.errorColor,
//                     fontSize: 9,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//         subtitle: Text(
//           col.type == ColumnType.select
//               ? 'Select: ${col.options.take(3).join(", ")}${col.options.length > 3 ? "..." : ""}'
//               : TableColumn.typeLabel(col.type),
//           style: const TextStyle(fontSize: 11, color: AppTheme.darkTextMuted),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(
//                 Icons.edit_rounded,
//                 size: 16,
//                 color: AppTheme.primaryColor,
//               ),
//               onPressed: onEdit,
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//             ),
//             IconButton(
//               icon: const Icon(
//                 Icons.delete_rounded,
//                 size: 16,
//                 color: AppTheme.errorColor,
//               ),
//               onPressed: onDelete,
//               padding: EdgeInsets.zero,
//               constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
//             ),
//             const Icon(
//               Icons.drag_handle_rounded,
//               color: AppTheme.darkTextMuted,
//               size: 20,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _colTypeIcon(ColumnType t, Color color) {
//     const icons = {
//       ColumnType.text: Icons.text_fields_rounded,
//       ColumnType.number: Icons.numbers_rounded,
//       ColumnType.boolean: Icons.toggle_on_rounded,
//       ColumnType.date: Icons.calendar_today_rounded,
//       ColumnType.select: Icons.list_rounded,
//     };
//     return Icon(icons[t] ?? Icons.text_fields_rounded, size: 16, color: color);
//   }
// }

// // ── Column editor bottom sheet ────────────────────────────────────────────────
// class ColumnEditorSheet extends StatefulWidget {
//   final TableColumn? existing;
//   final ValueChanged<TableColumn> onSave;

//   const ColumnEditorSheet({
//     super.key,
//     required this.existing,
//     required this.onSave,
//   });

//   @override
//   State<ColumnEditorSheet> createState() => _ColumnEditorSheetState();
// }

// class _ColumnEditorSheetState extends State<ColumnEditorSheet> {
//   final _nameCtrl = TextEditingController();
//   final _optionCtrl = TextEditingController();
//   ColumnType _type = ColumnType.text;
//   bool _required = false;
//   List<String> _options = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.existing != null) {
//       _nameCtrl.text = widget.existing!.name;
//       _type = widget.existing!.type;
//       _required = widget.existing!.required;
//       _options = List.from(widget.existing!.options);
//     }
//   }

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _optionCtrl.dispose();
//     super.dispose();
//   }

//   void _save() {
//     if (_nameCtrl.text.trim().isEmpty) {
//       Get.snackbar(
//         'Error',
//         'Column name is required',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }
//     widget.onSave(
//       TableColumn(
//         id: widget.existing?.id ?? const Uuid().v4(),
//         name: _nameCtrl.text.trim(),
//         type: _type,
//         required: _required,
//         options: _options,
//       ),
//     );
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Handle
//           Center(
//             child: Container(
//               width: 36,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: AppTheme.darkBorder,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Text(
//                 widget.existing == null ? 'Add Column' : 'Edit Column',
//                 style: Theme.of(
//                   context,
//                 ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
//               ),
//               const Spacer(),
//               ElevatedButton(onPressed: _save, child: const Text('Save')),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Name
//           TextFormField(
//             controller: _nameCtrl,
//             autofocus: true,
//             decoration: const InputDecoration(
//               labelText: 'Column Name',
//               hintText: 'e.g. Email, Status...',
//               prefixIcon: Icon(Icons.text_fields_rounded),
//             ),
//           ),
//           const SizedBox(height: 14),

//           // Type
//           Text(
//             'Type',
//             style: Theme.of(
//               context,
//             ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: ColumnType.values
//                 .map(
//                   (t) => ChoiceChip(
//                     label: Text(TableColumn.typeLabel(t)),
//                     selected: _type == t,
//                     onSelected: (_) => setState(() {
//                       _type = t;
//                       if (t != ColumnType.select) _options = [];
//                     }),
//                     selectedColor: AppTheme.primaryColor,
//                     labelStyle: TextStyle(
//                       color: _type == t ? Colors.white : null,
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     side: BorderSide(
//                       color: _type == t
//                           ? AppTheme.primaryColor
//                           : AppTheme.darkBorder,
//                     ),
//                     backgroundColor: Theme.of(context).cardColor,
//                   ),
//                 )
//                 .toList(),
//           ),

//           // Select options
//           if (_type == ColumnType.select) ...[
//             const SizedBox(height: 14),
//             Text(
//               'Options',
//               style: Theme.of(
//                 context,
//               ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 8),
//             if (_options.isNotEmpty)
//               Wrap(
//                 spacing: 6,
//                 runSpacing: 6,
//                 children: _options
//                     .map(
//                       (opt) => Chip(
//                         label: Text(opt, style: const TextStyle(fontSize: 12)),
//                         deleteIcon: const Icon(Icons.close_rounded, size: 14),
//                         onDeleted: () => setState(() => _options.remove(opt)),
//                         backgroundColor:
//                             AppTheme.primaryColor.withValues(alpha: 0.1),
//                         side: const BorderSide(
//                           color: AppTheme.primaryColor,
//                           width: 0.5,
//                         ),
//                       ),
//                     )
//                     .toList(),
//               ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _optionCtrl,
//                     decoration: const InputDecoration(
//                       hintText: 'Add option...',
//                       isDense: true,
//                       prefixIcon: Icon(Icons.add_rounded, size: 16),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 10,
//                       ),
//                     ),
//                     onSubmitted: (v) {
//                       if (v.trim().isNotEmpty) {
//                         setState(() {
//                           _options.add(v.trim());
//                           _optionCtrl.clear();
//                         });
//                       }
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     if (_optionCtrl.text.trim().isNotEmpty) {
//                       setState(() {
//                         _options.add(_optionCtrl.text.trim());
//                         _optionCtrl.clear();
//                       });
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text('Add'),
//                 ),
//               ],
//             ),
//           ],

//           const SizedBox(height: 14),
//           // Required toggle
//           Row(
//             children: [
//               const Text(
//                 'Required field',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//               const Spacer(),
//               Switch(
//                 value: _required,
//                 onChanged: (v) => setState(() => _required = v),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }

// // ── Shared card wrapper ───────────────────────────────────────────────────────
// class _SchemaCard extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final List<Widget> children;

//   const _SchemaCard({
//     required this.title,
//     required this.icon,
//     required this.children,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
//             child: Row(
//               children: [
//                 Icon(icon, size: 16, color: AppTheme.primaryColor),
//                 const SizedBox(width: 8),
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.labelMedium?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: Theme.of(context).textTheme.bodyLarge?.color,
//                       ),
//                 ),
//               ],
//             ),
//           ),
//           const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             child: Divider(height: 1),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//             child: Column(children: children),
//           ),
//         ],
//       ),
//     );
//   }
// }
