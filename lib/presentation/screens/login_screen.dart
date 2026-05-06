// // import 'package:flutter/material.dart';
// // import 'package:flutter_animate/flutter_animate.dart';
// // import 'package:get/get.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../core/theme/app_theme.dart';
// // import '../controllers/auth_controller.dart';

// // class AddInstanceScreen extends StatefulWidget {
// //   final bool isFirstTime;

// //   const AddInstanceScreen({super.key, this.isFirstTime = false});

// //   @override
// //   State<AddInstanceScreen> createState() => _AddInstanceScreenState();
// // }

// // class _AddInstanceScreenState extends State<AddInstanceScreen> {
// //   final _formKey = GlobalKey<FormState>();
// //   final _nameController = TextEditingController(text: 'My n8n Server');
// //   final _urlController = TextEditingController();
// //   final _apiKeyController = TextEditingController();
// //   bool _obscureApiKey = true;
// //   var isLoggedIn = false.obs;
// //   late AuthController _authController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _authController = Get.find<AuthController>();
// //   }

// //   @override
// //   void dispose() {
// //     _nameController.dispose();
// //     _urlController.dispose();
// //     _apiKeyController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _submit() async {
// //     if (!_formKey.currentState!.validate()) return;
// //     FocusScope.of(context).unfocus();
// //     final prefs = await SharedPreferences.getInstance();
// //     await prefs.setBool('is_logged_in', true);

// //     final success = await _authController.addInstance(
// //       name: _nameController.text.trim(),
// //       baseUrl: _urlController.text.trim(),
// //       apiKey: _apiKeyController.text.trim(),
// //     );

// //     print('-------------++----------------');

// //     print(success);

// //     if (!success && mounted) {
// //       // Error is shown via controller
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 if (widget.isFirstTime) ...[
// //                   const SizedBox(height: 32),
// //                   _buildHeader(),
// //                   const SizedBox(height: 40),
// //                 ] else ...[
// //                   const SizedBox(height: 8),
// //                 ],
// //                 _buildFormFields(),
// //                 const SizedBox(height: 32),
// //                 const SizedBox(height: 12),
// //                 SizedBox(
// //                   height: 52,
// //                   child: OutlinedButton(
// //                     onPressed: () {
// //                       _authController.loginWithDemo();
// //                     },
// //                     style: OutlinedButton.styleFrom(
// //                       side: const BorderSide(
// //                         color: Colors.deepOrange, // 👉 border color
// //                         width: 1.5,
// //                       ),
// //                       foregroundColor:
// //                           Colors.deepOrange, // 👉 icon + text color
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius:
// //                             BorderRadius.circular(10), // 👉 border radius
// //                       ),
// //                     ),
// //                     child: const Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Icon(Icons.bolt_rounded, size: 18),
// //                         SizedBox(width: 8),
// //                         Text('Try Demo'),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //                 _buildSubmitButton(),
// //                 const SizedBox(height: 24),
// //                 _buildMockDataNote(),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHeader() {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.center,
// //       children: [
// //         Column(
// //           children: [
// //             Center(
// //               child: Image.asset(
// //                 'assets/icon/icon.png',
// //                 width: 200,
// //                 height: 200,
// //                 fit: BoxFit.contain,
// //               ),
// //             ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0),
// //             const SizedBox(width: 20),
// //             Text(
// //               'Connect to\nn8n Server',
// //               style: Theme.of(context).textTheme.displaySmall?.copyWith(
// //                     fontWeight: FontWeight.w600,
// //                     height: 1.1,
// //                   ),
// //             )
// //                 .animate()
// //                 .fadeIn(delay: 100.ms, duration: 400.ms)
// //                 .slideY(begin: 0.3, end: 0),
// //           ],
// //         ),
// //         const SizedBox(height: 10),
// //         Text(
// //           'Enter your n8n instance details to get started.',
// //           style: Theme.of(context).textTheme.bodyMedium,
// //         ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
// //       ],
// //     );
// //   }

// //   Widget _buildFormFields() {
// //     return Column(
// //       children: [
// //         // _buildLabel('Instance Name'),
// //         // const SizedBox(height: 8),
// //         // TextFormField(
// //         //   controller: _nameController,
// //         //   decoration: const InputDecoration(
// //         //     hintText: 'My n8n Server',
// //         //     prefixIcon: Icon(Icons.label_rounded),
// //         //   ),
// //         //   validator: (v) => v?.isEmpty == true ? 'Enter a name' : null,
// //         // ),
// //         //  const SizedBox(height: 20),
// //         _buildLabel('Server URL'),
// //         const SizedBox(height: 8),
// //         TextFormField(
// //           controller: _urlController,
// //           keyboardType: TextInputType.url,
// //           autocorrect: false,
// //           decoration: const InputDecoration(
// //             hintText: 'https://your-n8n.example.com',
// //             prefixIcon: Icon(Icons.link_rounded),
// //           ),
// //           validator: (v) {
// //             if (v == null || v.isEmpty) return 'Enter server URL';
// //             return null;
// //           },
// //         ),
// //         const SizedBox(height: 10),
// //         _buildLabel('API Key'),
// //         const SizedBox(height: 8),
// //         TextFormField(
// //           controller: _apiKeyController,
// //           obscureText: _obscureApiKey,
// //           autocorrect: false,
// //           decoration: InputDecoration(
// //             hintText: 'n8n_api_xxxxxxxxxxxxxxxx',
// //             prefixIcon: const Icon(Icons.key_rounded),
// //             suffixIcon: IconButton(
// //               icon: Icon(
// //                 _obscureApiKey
// //                     ? Icons.visibility_rounded
// //                     : Icons.visibility_off_rounded,
// //               ),
// //               onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
// //             ),
// //           ),
// //           validator: (v) => v?.isEmpty == true ? 'Enter your API key' : null,
// //         ),
// //         const SizedBox(height: 8),
// //         Text(
// //           'Find your API key in n8n → Settings → API',
// //           style: Theme.of(context).textTheme.labelSmall,
// //         ),
// //       ],
// //     )
// //         .animate()
// //         .fadeIn(delay: 300.ms, duration: 400.ms)
// //         .slideY(begin: 0.2, end: 0);
// //   }

// //   Widget _buildLabel(String text) {
// //     return Text(
// //       text,
// //       style: Theme.of(context).textTheme.labelMedium?.copyWith(
// //             fontWeight: FontWeight.w600,
// //           ),
// //     );
// //   }

// //   Widget _buildSubmitButton() {
// //     return Obx(() {
// //       final isLoading = _authController.isLoading.value;
// //       final error = _authController.errorMessage.value;

// //       return Column(
// //         crossAxisAlignment: CrossAxisAlignment.stretch,
// //         children: [
// //           if (error.isNotEmpty) ...[
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: AppTheme.errorColor.withValues(alpha: 0.1),
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(
// //                     color: AppTheme.errorColor.withValues(alpha: 0.3)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   const Icon(Icons.error_outline_rounded,
// //                       color: AppTheme.errorColor, size: 18),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: Text(
// //                       error,
// //                       style: const TextStyle(
// //                           color: AppTheme.errorColor, fontSize: 13),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //           ],
// //           SizedBox(
// //             height: 52,
// //             child: ElevatedButton(
// //               onPressed: isLoading ? null : _submit,
// //               child: isLoading
// //                   ? const SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         color: Colors.white,
// //                       ),
// //                     )
// //                   : const Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Icon(Icons.rocket_launch_rounded, size: 18),
// //                         SizedBox(width: 8),
// //                         Text('Connect Instance'),
// //                       ],
// //                     ),
// //             ),
// //           ),
// //         ],
// //       );
// //     });
// //   }

// //   Widget _buildMockDataNote() {
// //     return Container(
// //       padding: const EdgeInsets.all(14),
// //       decoration: BoxDecoration(
// //         color: AppTheme.accentColor.withValues(alpha: 0.08),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(Icons.info_outline_rounded,
// //               color: AppTheme.accentColor, size: 16),
// //           const SizedBox(width: 10),
// //           Expanded(
// //             child: Text(
// //               'For testing, use any URL and API key — the app will show mock data if the server is unreachable.',
// //               style: Theme.of(context).textTheme.labelSmall?.copyWith(
// //                     color: AppTheme.accentColor,
// //                   ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // ─── Splash / Route Gate
// // class LoginScreen extends StatelessWidget {
// //   const LoginScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return const Scaffold(
// //       backgroundColor: Colors.white,
// //       body: AddInstanceScreen(isFirstTime: true),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../core/theme/app_theme.dart';
// import '../controllers/auth_controller.dart';

// // ─── Font: Plus Jakarta Sans ───────────────────────────────────────────────────
// // pubspec.yaml এ add করুন:
// //   google_fonts: ^6.2.1
// // থিমে:
// //   textTheme: GoogleFonts.plusJakartaSansTextTheme()
// // ─────────────────────────────────────────────────────────────────────────────

// class AddInstanceScreen extends StatefulWidget {
//   final bool isFirstTime;

//   const AddInstanceScreen({super.key, this.isFirstTime = false});

//   @override
//   State<AddInstanceScreen> createState() => _AddInstanceScreenState();
// }

// class _AddInstanceScreenState extends State<AddInstanceScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _urlController = TextEditingController();
//   final _apiKeyController = TextEditingController();
//   bool _obscureApiKey = true;
//   late AuthController _authController;

//   // ─── Colors ──────────────────────────────────────────────────────────────────
//   static const _black = Color(0xFF18181B);
//   static const _zinc700 = Color(0xFF3F3F46);
//   static const _zinc500 = Color(0xFF71717A);
//   static const _zinc400 = Color(0xFFA1A1AA);
//   static const _zinc200 = Color(0xFFE4E4E7);
//   static const _zinc100 = Color(0xFFF4F4F5);
//   static const _zinc50 = Color(0xFFFAFAFA);
//   static const _orange = Color(0xFFF97316);

//   @override
//   void initState() {
//     super.initState();
//     _authController = Get.find<AuthController>();
//   }

//   @override
//   void dispose() {
//     _urlController.dispose();
//     _apiKeyController.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) return;
//     FocusScope.of(context).unfocus();
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('is_logged_in', true);
//     await _authController.addInstance(
//       name: 'My n8n Server',
//       baseUrl: _urlController.text.trim(),
//       apiKey: _apiKeyController.text.trim(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 28),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 if (widget.isFirstTime) ...[
//                   const SizedBox(height: 36),
//                   _buildHeader(),
//                   const SizedBox(height: 40),
//                 ] else
//                   const SizedBox(height: 16),
//                 _buildUrlField(),
//                 const SizedBox(height: 14),
//                 _buildApiKeyField(),
//                 const SizedBox(height: 28),
//                 _buildConnectButton(),
//                 _buildDivider(),
//                 _buildDemoButton(),
//                 const SizedBox(height: 20),
//                 _buildInfoNote(),
//                 const SizedBox(height: 32),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ─── Header ──────────────────────────────────────────────────────────────────

//   Widget _buildHeader() {
//     return Column(
//       children: [
//         Container(
//           width: 64,
//           height: 64,
//           decoration: BoxDecoration(
//             color: _zinc100,
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(color: _zinc200),
//           ),
//           child: const Icon(Icons.api_rounded, size: 28, color: _black),
//         )
//             .animate()
//             .fadeIn(duration: 400.ms)
//             .slideY(begin: -0.2, end: 0),
//         const SizedBox(height: 20),
//         const Text(
//           'Connect to n8n Server',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.w700,
//             color: _black,
//             letterSpacing: -0.4,
//             height: 1.25,
//           ),
//         )
//             .animate()
//             .fadeIn(delay: 80.ms, duration: 400.ms)
//             .slideY(begin: 0.15, end: 0),
//         const SizedBox(height: 8),
//         const Text(
//           'Enter your instance details to get started',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 13,
//             color: _zinc500,
//             fontWeight: FontWeight.w400,
//           ),
//         ).animate().fadeIn(delay: 140.ms, duration: 400.ms),
//       ],
//     );
//   }

//   // ─── Fields ──────────────────────────────────────────────────────────────────

//   Widget _buildUrlField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _fieldLabel('Server URL'),
//         const SizedBox(height: 7),
//         TextFormField(
//           controller: _urlController,
//           keyboardType: TextInputType.url,
//           autocorrect: false,
//           style: const TextStyle(
//             fontSize: 14,
//             color: _black,
//             fontWeight: FontWeight.w400,
//           ),
//           decoration: _inputDecoration(
//             hint: 'https://your-n8n.example.com',
//             icon: Icons.link_rounded,
//           ),
//           validator: (v) {
//             if (v == null || v.isEmpty) return 'Server URL is required';
//             return null;
//           },
//         ),
//       ],
//     )
//         .animate()
//         .fadeIn(delay: 180.ms, duration: 400.ms)
//         .slideY(begin: 0.12, end: 0);
//   }

//   Widget _buildApiKeyField() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _fieldLabel('API Key'),
//         const SizedBox(height: 7),
//         TextFormField(
//           controller: _apiKeyController,
//           obscureText: _obscureApiKey,
//           autocorrect: false,
//           style: const TextStyle(
//             fontSize: 14,
//             color: _black,
//             fontWeight: FontWeight.w400,
//           ),
//           decoration: _inputDecoration(
//             hint: 'n8n_api_xxxxxxxxxxxxxxxx',
//             icon: Icons.key_rounded,
//             suffix: IconButton(
//               icon: Icon(
//                 _obscureApiKey
//                     ? Icons.visibility_outlined
//                     : Icons.visibility_off_outlined,
//                 size: 18,
//                 color: _zinc400,
//               ),
//               onPressed: () =>
//                   setState(() => _obscureApiKey = !_obscureApiKey),
//             ),
//           ),
//           validator: (v) =>
//               v?.isEmpty == true ? 'API key is required' : null,
//         ),
//         const SizedBox(height: 6),
//         const Text(
//           'Find in n8n → Settings → API',
//           style: TextStyle(
//             fontSize: 11,
//             color: _zinc400,
//             fontWeight: FontWeight.w400,
//           ),
//         ),
//       ],
//     )
//         .animate()
//         .fadeIn(delay: 240.ms, duration: 400.ms)
//         .slideY(begin: 0.12, end: 0);
//   }

//   InputDecoration _inputDecoration({
//     required String hint,
//     required IconData icon,
//     Widget? suffix,
//   }) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(
//         color: _zinc400,
//         fontSize: 14,
//         fontWeight: FontWeight.w400,
//       ),
//       filled: true,
//       fillColor: _zinc50,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 14,
//         vertical: 14,
//       ),
//       prefixIcon: Padding(
//         padding: const EdgeInsets.only(left: 12, right: 8),
//         child: Icon(icon, size: 18, color: _zinc400),
//       ),
//       prefixIconConstraints: const BoxConstraints(minWidth: 40),
//       suffixIcon: suffix,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: _zinc200, width: 1),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: _black, width: 1.2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
//       ),
//       errorStyle: const TextStyle(
//         fontSize: 11,
//         color: Color(0xFFEF4444),
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

//   // ─── Buttons ─────────────────────────────────────────────────────────────────

//   Widget _buildConnectButton() {
//     return Obx(() {
//       final isLoading = _authController.isLoading.value;
//       final error = _authController.errorMessage.value;

//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           if (error.isNotEmpty) ...[
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 14,
//                 vertical: 12,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFEF2F2),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: const Color(0xFFFECACA)),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.error_outline_rounded,
//                     color: Color(0xFFEF4444),
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       error,
//                       style: const TextStyle(
//                         color: Color(0xFFDC2626),
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 14),
//           ],
//           SizedBox(
//             height: 50,
//             child: ElevatedButton(
//               onPressed: isLoading ? null : _submit,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: _black,
//                 foregroundColor: Colors.white,
//                 disabledBackgroundColor: _zinc200,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: isLoading
//                   ? const SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.power_settings_new_rounded, size: 17),
//                         SizedBox(width: 8),
//                         Text(
//                           'Connect Instance',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.1,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//           ),
//         ],
//       );
//     }).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
//   }

//   Widget _buildDivider() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 18),
//       child: Row(
//         children: const [
//           Expanded(child: Divider(color: _zinc200, thickness: 1)),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 12),
//             child: Text(
//               'OR',
//               style: TextStyle(
//                 fontSize: 11,
//                 color: _zinc400,
//                 fontWeight: FontWeight.w500,
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//           Expanded(child: Divider(color: _zinc200, thickness: 1)),
//         ],
//       ),
//     ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
//   }

//   Widget _buildDemoButton() {
//     return SizedBox(
//       height: 50,
//       child: OutlinedButton(
//         onPressed: _authController.loginWithDemo,
//         style: OutlinedButton.styleFrom(
//           side: const BorderSide(color: _zinc200, width: 1),
//           foregroundColor: _zinc700,
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 0,
//         ),
//         child: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.bolt_rounded, size: 17, color: _orange),
//             SizedBox(width: 8),
//             Text(
//               'Try Demo',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: _zinc700,
//               ),
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
//   }

//   // ─── Info Note ───────────────────────────────────────────────────────────────

//   Widget _buildInfoNote() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: _zinc100,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: const Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.info_outline_rounded, size: 15, color: _zinc500),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               'For testing, use any URL and API key — the app will show mock data if the server is unreachable.',
//               style: TextStyle(
//                 fontSize: 11.5,
//                 color: _zinc500,
//                 height: 1.6,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ).animate().fadeIn(delay: 450.ms, duration: 400.ms);
//   }
// }

// // ─── Login Screen Gate ────────────────────────────────────────────────────────

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: Colors.white,
//       body: AddInstanceScreen(isFirstTime: true),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';

class AddInstanceScreen extends StatefulWidget {
  final bool isFirstTime;

  const AddInstanceScreen({super.key, this.isFirstTime = false});

  @override
  State<AddInstanceScreen> createState() => _AddInstanceScreenState();
}

class _AddInstanceScreenState extends State<AddInstanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  late AuthController _authController;

  // ─── Colors ──────────────────────────────────────────────────────────────────
  static const _black = Color(0xFF18181B);
  static const _zinc700 = Color(0xFF3F3F46);
  static const _zinc500 = Color(0xFF71717A);
  static const _zinc400 = Color(0xFFA1A1AA);
  static const _zinc200 = Color(0xFFE4E4E7);
  static const _zinc50 = Color(0xFFFAFAFA);

  // Orange palette
  static const _orange = Color(0xFFEA580C); // primary
// darker
  static const _orangeTint = Color(0xFFFFF4EE); // light bg
  static const _orangeBorder = Color(0xFFFFD9C2); // subtle border
  static const _orangeText = Color(0xFF9A3412); // dark text on tint

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await _authController.addInstance(
      name: 'My n8n Server',
      baseUrl: _urlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.isFirstTime) ...[
                  const SizedBox(height: 106),
                  _buildHeader(),
                  const SizedBox(height: 40),
                ] else
                  const SizedBox(height: 16),
                _buildUrlField(),
                const SizedBox(height: 14),
                _buildApiKeyField(),
                const SizedBox(height: 28),
                _buildConnectButton(),
                _buildDivider(),
                _buildDemoButton(),
                const SizedBox(height: 20),
                _buildInfoNote(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        // Image.asset(
        //   "assets/icon/icon.png",
        //   height: 200,
        //   width: 200,
        // ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
        const SizedBox(height: 20),
        const Text(
          'Connect to n8n Server',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _black,
            letterSpacing: -0.4,
            height: 1.25,
          ),
        )
            .animate()
            .fadeIn(delay: 80.ms, duration: 400.ms)
            .slideY(begin: 0.15, end: 0),
        const SizedBox(height: 12),
        const Text(
          'Enter your instance details to get started',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: _zinc500,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 140.ms, duration: 400.ms),
      ],
    );
  }

  // ─── Fields ──────────────────────────────────────────────────────────────────

  Widget _buildUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Server URL'),
        const SizedBox(height: 7),
        TextFormField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          autocorrect: false,
          style: const TextStyle(fontSize: 14, color: _black),
          decoration: _inputDecoration(
            hint: 'https://your-n8n.example.com',
            icon: Icons.link_rounded,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Server URL is required';
            return null;
          },
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 180.ms, duration: 400.ms)
        .slideY(begin: 0.12, end: 0);
  }

  Widget _buildApiKeyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('API Key'),
        const SizedBox(height: 7),
        TextFormField(
          controller: _apiKeyController,
          obscureText: _obscureApiKey,
          autocorrect: false,
          style: const TextStyle(fontSize: 14, color: _black),
          decoration: _inputDecoration(
            hint: 'n8n_api_xxxxxxxxxxxxxxxx',
            icon: Icons.key_rounded,
            suffix: IconButton(
              icon: Icon(
                _obscureApiKey
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
                color: _zinc400,
              ),
              onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
            ),
          ),
          validator: (v) => v?.isEmpty == true ? 'API key is required' : null,
        ),
        const SizedBox(height: 6),
        const Text(
          'Find in n8n → Settings → API',
          style: TextStyle(fontSize: 11, color: _zinc400),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 240.ms, duration: 400.ms)
        .slideY(begin: 0.12, end: 0);
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _zinc400, fontSize: 14),
      filled: true,
      fillColor: _zinc50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8),
        child: Icon(icon, size: 18, color: _orange),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 40),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _zinc200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _orange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _zinc700,
        letterSpacing: 0.2,
      ),
    );
  }

  // ─── Buttons ─────────────────────────────────────────────────────────────────

  Widget _buildConnectButton() {
    return Obx(() {
      final isLoading = _authController.isLoading.value;
      final error = _authController.errorMessage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _zinc200,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.power_settings_new_rounded, size: 17),
                        SizedBox(width: 8),
                        Text(
                          'Connect Instance',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      );
    })
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(child: Divider(color: _zinc200, thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'OR',
              style: TextStyle(
                fontSize: 11,
                color: _zinc400,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: _zinc200, thickness: 1)),
        ],
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms);
  }

  Widget _buildDemoButton() {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: _authController.loginWithDemo,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _orangeBorder, width: 1),
          foregroundColor: _orange,
          backgroundColor: _orangeTint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt_rounded, size: 17, color: _orange),
            SizedBox(width: 8),
            Text(
              'Try Demo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _orange,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0);
  }

  // ─── Info Note ───────────────────────────────────────────────────────────────

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _orangeTint,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _orangeBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 15, color: _orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'For testing, use any URL and API key — the app will show mock data if the server is unreachable.',
              style: TextStyle(
                fontSize: 11.5,
                color: _orangeText,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms, duration: 400.ms);
  }
}

// ─── Login Screen Gate ────────────────────────────────────────────────────────

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: AddInstanceScreen(isFirstTime: true),
    );
  }
}
