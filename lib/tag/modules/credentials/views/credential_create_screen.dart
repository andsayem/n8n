import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/credential_controller.dart';

// Common n8n credential types
const _credentialTypes = [
  'postgres',
  'mysql',
  'mongodb',
  'redis',
  'slack',
  'gmail',
  'smtp',
  'github',
  'gitlab',
  'googleDriveOAuth2Api',
  'googleSheetsOAuth2Api',
  'stripe',
  'httpBasicAuth',
  'httpHeaderAuth',
  'other',
];

class CredentialCreateScreen extends StatefulWidget {
  const CredentialCreateScreen({super.key});

  @override
  State<CredentialCreateScreen> createState() => _CredentialCreateScreenState();
}

class _CredentialCreateScreenState extends State<CredentialCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  String? _selectedType;
  bool _showCustomType = false;

  static const _black = Color(0xFF18181B);
  static const _zinc700 = Color(0xFF3F3F46);
  static const _zinc400 = Color(0xFFA1A1AA);
  static const _zinc200 = Color(0xFFE4E4E7);
  static const _zinc50 = Color(0xFFFAFAFA);
  static const _orange = Color(0xFFEA580C);
  static const _orangeTint = Color(0xFFFFF4EE);
  static const _orangeBorder = Color(0xFFFFD9C2);

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final controller = Get.find<CredentialController>();
    final type = _showCustomType ? _typeController.text.trim() : _selectedType!;

    final success = await controller.createCredential(
      name: _nameController.text.trim(),
      type: type,
      data: {}, // actual credential data fields are type-specific
    );

    if (success) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CredentialController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _black, size: 22),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Credential',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _black,
                letterSpacing: -0.3)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _zinc200),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _orangeTint,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _orangeBorder),
                  ),
                  child:
                      const Icon(Icons.key_rounded, size: 28, color: _orange),
                )
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .scale(begin: const Offset(0.85, 0.85)),
              ),
              const SizedBox(height: 28),

              // Name field
              _label('Credential Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                autofocus: true,
                style: const TextStyle(fontSize: 14, color: _black),
                decoration: _inputDeco(
                  hint: 'e.g. My Postgres DB, Slack Bot',
                  icon: Icons.badge_outlined,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Name is required' : null,
              )
                  .animate()
                  .fadeIn(delay: 80.ms, duration: 350.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),

              // Type selector
              _label('Credential Type'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: _zinc50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _zinc200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    hint: const Text('Select a type',
                        style: TextStyle(color: _zinc400, fontSize: 14)),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: _zinc400),
                    style: const TextStyle(fontSize: 14, color: _black),
                    items: _credentialTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type == 'other' ? 'Other (custom)' : type),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedType = val;
                        _showCustomType = val == 'other';
                      });
                    },
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 140.ms, duration: 350.ms)
                  .slideY(begin: 0.1, end: 0),

              // Custom type input (shown when "other" selected)
              if (_showCustomType) ...[
                const SizedBox(height: 14),
                _label('Custom Type Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _typeController,
                  style: const TextStyle(fontSize: 14, color: _black),
                  decoration: _inputDeco(
                    hint: 'e.g. myCustomApi',
                    icon: Icons.tune_rounded,
                  ),
                  validator: (v) {
                    if (_showCustomType && (v == null || v.trim().isEmpty)) {
                      return 'Custom type name is required';
                    }
                    return null;
                  },
                ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.1, end: 0),
              ] else ...[
                // Hidden validator for type dropdown
                FormField<String>(
                  validator: (_) {
                    if (!_showCustomType && _selectedType == null) {
                      return 'Please select a credential type';
                    }
                    return null;
                  },
                  builder: (state) {
                    if (state.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6, left: 4),
                        child: Text(state.errorText!,
                            style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 11)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],

              const SizedBox(height: 16),

              // Info card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        'After creating, go to n8n → Credentials to fill in the actual values (passwords, tokens, etc.).',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF9A3412),
                            height: 1.6),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 350.ms),

              const SizedBox(height: 32),

              // Error message
              Obx(() {
                final error = controller.errorMessage.value;
                if (error.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Color(0xFFEF4444), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(error,
                              style: const TextStyle(
                                  color: Color(0xFFDC2626), fontSize: 12.5))),
                    ]),
                  ),
                );
              }),

              // Submit button
              Obx(() {
                final isLoading = controller.isSubmitting.value;
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _zinc200,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(Icons.add_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Add Credential',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ]),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
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
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _zinc200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _orange, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444))),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
      errorStyle: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _zinc700,
          letterSpacing: 0.2));
}
