import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

class AddInstanceScreen extends StatefulWidget {
  final bool isFirstTime;

  const AddInstanceScreen({super.key, this.isFirstTime = false});

  @override
  State<AddInstanceScreen> createState() => _AddInstanceScreenState();
}

class _AddInstanceScreenState extends State<AddInstanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'My n8n Server');
  final _urlController = TextEditingController();
  final _apiKeyController = TextEditingController();
  bool _obscureApiKey = true;
  var isLoggedIn = false.obs;
  late AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    print('--------++----------------');

    print(_nameController.text.trim());
    print(_urlController.text.trim());
    print(_apiKeyController.text.trim());

    final success = await _authController.addInstance(
      name: _nameController.text.trim(),
      baseUrl: _urlController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
    );

    print('-------------++----------------');

    print(success);

    if (!success && mounted) {
      // Error is shown via controller
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isFirstTime) ...[
                  const SizedBox(height: 32),
                  _buildHeader(),
                  const SizedBox(height: 40),
                ] else ...[
                  const SizedBox(height: 8),
                ],
                _buildFormFields(),
                const SizedBox(height: 32),
                const SizedBox(height: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      _authController.loginWithDemo();
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bolt_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Try Demo'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 24),
                _buildMockDataNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 28),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3, end: 0),
        const SizedBox(height: 24),
        Text(
          'Connect to\nn8n Server',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
        const SizedBox(height: 12),
        Text(
          'Enter your n8n instance details to get started.',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildLabel('Instance Name'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'My n8n Server',
            prefixIcon: Icon(Icons.label_rounded),
          ),
          validator: (v) => v?.isEmpty == true ? 'Enter a name' : null,
        ),
        const SizedBox(height: 20),
        _buildLabel('Server URL'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _urlController,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: const InputDecoration(
            hintText: 'https://your-n8n.example.com',
            prefixIcon: Icon(Icons.link_rounded),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Enter server URL';
            return null;
          },
        ),
        const SizedBox(height: 20),
        _buildLabel('API Key'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _apiKeyController,
          obscureText: _obscureApiKey,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: 'n8n_api_xxxxxxxxxxxxxxxx',
            prefixIcon: const Icon(Icons.key_rounded),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureApiKey
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
              ),
              onPressed: () => setState(() => _obscureApiKey = !_obscureApiKey),
            ),
          ),
          validator: (v) => v?.isEmpty == true ? 'Enter your API key' : null,
        ),
        const SizedBox(height: 8),
        Text(
          'Find your API key in n8n → Settings → API',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final isLoading = _authController.isLoading.value;
      final error = _authController.errorMessage.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppTheme.errorColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                          color: AppTheme.errorColor, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rocket_launch_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Connect Instance'),
                      ],
                    ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMockDataNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.accentColor, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'For testing, use any URL and API key — the app will show mock data if the server is unreachable.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.accentColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Splash / Route Gate
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add n8n Instance')),
      body: const AddInstanceScreen(isFirstTime: true),
    );
  }
}
