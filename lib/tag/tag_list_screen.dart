// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import 'package:n8n_manager/tag/tag_controller.dart';

// class TagListScreen extends StatelessWidget {
//   const TagListScreen({super.key});

//   // ─── Colors ────────────────────────────────────────────────────────────────
//   static const _black = Color(0xFF18181B);
//   static const _zinc500 = Color(0xFF71717A);
//   static const _zinc400 = Color(0xFFA1A1AA);
//   static const _zinc200 = Color(0xFFE4E4E7);
//   static const _zinc100 = Color(0xFFF4F4F5);
//   static const _orange = Color(0xFFEA580C);
//   static const _orangeTint = Color(0xFFFFF4EE);
//   static const _orangeBorder = Color(0xFFFFD9C2);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<TagController>();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         title: const Text(
//           'Tags',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: _black,
//             letterSpacing: -0.3,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded, color: _zinc500, size: 20),
//             onPressed: controller.loadTags,
//           ),
//           const SizedBox(width: 4),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(height: 1, color: _zinc200),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _showTagForm(context, controller),
//         backgroundColor: _orange,
//         elevation: 0,
//         child: const Icon(Icons.add_rounded, color: Colors.white),
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return const Center(
//             child: CircularProgressIndicator(
//               color: _orange,
//               strokeWidth: 2,
//             ),
//           );
//         }

//         if (controller.errorMessage.value.isNotEmpty) {
//           return _buildError(controller);
//         }

//         if (controller.tags.isEmpty) {
//           return _buildEmpty(context, controller);
//         }

//         return RefreshIndicator(
//           color: _orange,
//           onRefresh: controller.loadTags,
//           child: ListView.separated(
//             padding: const EdgeInsets.all(20),
//             itemCount: controller.tags.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 10),
//             itemBuilder: (context, index) {
//               final tag = controller.tags[index];
//               return _TagCard(
//                 tag: tag,
//                 onEdit: () => _showTagForm(context, controller, tag: tag),
//                 onDelete: () => _confirmDelete(context, controller, tag),
//               )
//                   .animate()
//                   .fadeIn(delay: (index * 40).ms, duration: 300.ms)
//                   .slideY(begin: 0.1, end: 0);
//             },
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildError(TagController controller) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.error_outline_rounded,
//                 size: 48, color: Color(0xFFEF4444)),
//             const SizedBox(height: 16),
//             Text(
//               controller.errorMessage.value,
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: _zinc500, fontSize: 14),
//             ),
//             const SizedBox(height: 20),
//             TextButton(
//               onPressed: controller.loadTags,
//               child: const Text('Retry',
//                   style:
//                       TextStyle(color: _orange, fontWeight: FontWeight.w600)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmpty(BuildContext context, TagController controller) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               color: _orangeTint,
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: _orangeBorder),
//             ),
//             child: const Icon(Icons.label_outline_rounded,
//                 size: 32, color: _orange),
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'No tags yet',
//             style: TextStyle(
//                 fontSize: 16, fontWeight: FontWeight.w600, color: _black),
//           ),
//           const SizedBox(height: 6),
//           const Text(
//             'Create your first tag to organize workflows',
//             style: TextStyle(fontSize: 13, color: _zinc500),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () => _showTagForm(context, controller),
//             icon: const Icon(Icons.add_rounded, size: 16),
//             label: const Text('Create Tag'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _orange,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10)),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTagForm(BuildContext context, TagController controller,
//       {N8nTag? tag}) {
//     Get.to(() => TagFormScreen(existingTag: tag));
//   }

//   void _confirmDelete(
//       BuildContext context, TagController controller, N8nTag tag) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete Tag',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//         content: Text(
//           'Are you sure you want to delete "${tag.name}"?',
//           style: const TextStyle(fontSize: 14, color: _zinc500),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: const Text('Cancel', style: TextStyle(color: _zinc500)),
//           ),
//           TextButton(
//             onPressed: () {
//               Get.back();
//               controller.deleteTag(tag.id);
//             },
//             child: const Text('Delete',
//                 style: TextStyle(
//                     color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TagCard extends StatelessWidget {
//   final N8nTag tag;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _TagCard({
//     required this.tag,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   static const _black = Color(0xFF18181B);
//   static const _zinc500 = Color(0xFF71717A);
//   static const _zinc200 = Color(0xFFE4E4E7);
//   static const _orange = Color(0xFFEA580C);
//   static const _orangeTint = Color(0xFFFFF4EE);
//   static const _orangeBorder = Color(0xFFFFD9C2);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: _zinc200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: BoxDecoration(
//               color: _orangeTint,
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: _orangeBorder),
//             ),
//             child: const Icon(Icons.label_rounded, size: 18, color: _orange),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   tag.name,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: _black,
//                   ),
//                 ),
//                 if (tag.createdAt != null) ...[
//                   const SizedBox(height: 2),
//                   Text(
//                     'Created ${_formatDate(tag.createdAt!)}',
//                     style: const TextStyle(fontSize: 11, color: _zinc500),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//           IconButton(
//             icon: const Icon(Icons.edit_outlined, size: 18, color: _zinc500),
//             onPressed: onEdit,
//             splashRadius: 20,
//           ),
//           IconButton(
//             icon: const Icon(Icons.delete_outline_rounded,
//                 size: 18, color: Color(0xFFEF4444)),
//             onPressed: onDelete,
//             splashRadius: 20,
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime dt) {
//     return '${dt.day}/${dt.month}/${dt.year}';
//   }
// }
