// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import '../controllers/tag_controller.dart';
// import '../../../data/models/n8n_tag_model.dart';

// class TagFormScreen extends StatefulWidget {
//   final N8nTag? existingTag;

//   const TagFormScreen({super.key, this.existingTag});

//   @override
//   State<TagFormScreen> createState() => _TagFormScreenState();
// }

// class _TagFormScreenState extends State<TagFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController _nameController;

//   bool get _isEdit => widget.existingTag != null;

//   // ─── Colors ────────────────────────────────────────────────────────────────
//   static const _black = Color(0xFF18181B);
//   static const _zinc700 = Color(0xFF3F3F46);
//   static const _zinc500 = Color(0xFF71717A);
//   static const _zinc400 = Color(0xFFA1A1AA);
//   static const _zinc200 = Color(0xFFE4E4E7);
//   static const _zinc50 = Color(0xFFFAFAFA);
//   static const _orange = Color(0xFFEA580C);
//   static const _orangeTint = Color(0xFFFFF4EE);
//   static const _orangeBorder = Color(0xFFFFD9C2);

//   @override
//   void initState() {
//     super.initState();
//     _nameController =
//         TextEditingController(text: widget.existingTag?.name ?? '');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     FocusScope.of(context).unfocus();

//     final controller = Get.find<TagController>();
//     bool success;

//     if (_isEdit) {
//       success = await controller.updateTag(
//           widget.existingTag!.id, _nameController.text);
//     } else {
//       success = await controller.createTag(_nameController.text);
//     }

//     if (success) Get.back();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<TagController>();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         surfaceTintColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_rounded, color: _black, size: 22),
//           onPressed: () => Get.back(),
//         ),
//         title: Text(
//           _isEdit ? 'Edit Tag' : 'Create Tag',
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: _black,
//             letterSpacing: -0.3,
//           ),
//         ),
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(1),
//           child: Container(height: 1, color: _zinc200),
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 8),
//               // Icon header
//               Center(
//                 child: Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(
//                     color: _orangeTint,
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: _orangeBorder),
//                   ),
//                   child:
//                       const Icon(Icons.label_rounded, size: 28, color: _orange),
//                 )
//                     .animate()
//                     .fadeIn(duration: 350.ms)
//                     .scale(begin: const Offset(0.85, 0.85)),
//               ),
//               const SizedBox(height: 28),

//               // Tag name field
//               _fieldLabel('Tag Name'),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _nameController,
//                 autofocus: true,
//                 textCapitalization: TextCapitalization.words,
//                 style: const TextStyle(
//                     fontSize: 14, color: _black, fontWeight: FontWeight.w500),
//                 decoration: InputDecoration(
//                   hintText: 'e.g. production, staging, internal',
//                   hintStyle: const TextStyle(color: _zinc400, fontSize: 14),
//                   filled: true,
//                   fillColor: _zinc50,
//                   contentPadding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//                   prefixIcon: const Padding(
//                     padding: EdgeInsets.only(left: 12, right: 8),
//                     child: Icon(Icons.label_outline_rounded,
//                         size: 18, color: _orange),
//                   ),
//                   prefixIconConstraints: const BoxConstraints(minWidth: 40),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: _zinc200, width: 1),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: _orange, width: 1.5),
//                   ),
//                   errorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide:
//                         const BorderSide(color: Color(0xFFEF4444), width: 1),
//                   ),
//                   focusedErrorBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide:
//                         const BorderSide(color: Color(0xFFEF4444), width: 1.5),
//                   ),
//                 ),
//                 validator: (v) {
//                   if (v == null || v.trim().isEmpty) {
//                     return 'Tag name is required';
//                   }
//                   if (v.trim().length < 2) {
//                     return 'Tag name must be at least 2 characters';
//                   }
//                   return null;
//                 },
//               )
//                   .animate()
//                   .fadeIn(delay: 100.ms, duration: 350.ms)
//                   .slideY(begin: 0.1, end: 0),

//               const SizedBox(height: 8),
//               Text(
//                 'Use tags to organize and filter your workflows',
//                 style: TextStyle(fontSize: 11, color: _zinc400),
//               ),

//               const Spacer(),

//               // Error message
//               Obx(() {
//                 final error = controller.errorMessage.value;
//                 if (error.isEmpty) return const SizedBox.shrink();
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 16),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFEF2F2),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: const Color(0xFFFECACA)),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.error_outline_rounded,
//                             color: Color(0xFFEF4444), size: 16),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             error,
//                             style: const TextStyle(
//                               color: Color(0xFFDC2626),
//                               fontSize: 12.5,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),

//               // Submit button
//               Obx(() {
//                 final isLoading = controller.isSubmitting.value;
//                 return SizedBox(
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: isLoading ? null : _submit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: _orange,
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor: _zinc200,
//                       elevation: 0,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: isLoading
//                         ? const SizedBox(
//                             width: 18,
//                             height: 18,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.white),
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 _isEdit
//                                     ? Icons.check_rounded
//                                     : Icons.add_rounded,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 _isEdit ? 'Save Changes' : 'Create Tag',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 );
//               }),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _fieldLabel(String text) {
//     return Text(
//       text,
//       style: const TextStyle(
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//         color: _zinc700,
//         letterSpacing: 0.2,
//       ),
//     );
//   }
// }
