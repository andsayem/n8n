import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/credential_controller.dart';
import '../../../data/models/n8n_credential_model.dart';
import 'credential_create_screen.dart';

class CredentialListScreen extends StatelessWidget {
  const CredentialListScreen({super.key});

  static const _black = Color(0xFF18181B);
  static const _zinc500 = Color(0xFF71717A);
  static const _zinc200 = Color(0xFFE4E4E7);
  static const _orange = Color(0xFFEA580C);
  static const _orangeTint = Color(0xFFFFF4EE);
  static const _orangeBorder = Color(0xFFFFD9C2);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CredentialController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Credentials',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _black,
                letterSpacing: -0.3)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _zinc500, size: 20),
            onPressed: controller.loadCredentials,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _zinc200),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CredentialCreateScreen()),
        backgroundColor: _orange,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: _orange, strokeWidth: 2));
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return _buildError(controller);
        }
        if (controller.credentials.isEmpty) {
          return _buildEmpty();
        }
        return RefreshIndicator(
          color: _orange,
          onRefresh: controller.loadCredentials,
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.credentials.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cred = controller.credentials[index];
              return _CredentialCard(
                credential: cred,
                onDelete: () => _confirmDelete(context, controller, cred),
              )
                  .animate()
                  .fadeIn(delay: (index * 40).ms, duration: 300.ms)
                  .slideY(begin: 0.1, end: 0);
            },
          ),
        );
      }),
    );
  }

  Widget _buildError(CredentialController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          Text(controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _zinc500, fontSize: 14)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: controller.loadCredentials,
            child: const Text('Retry',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _orangeTint,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _orangeBorder),
          ),
          child: const Icon(Icons.key_rounded, size: 32, color: _orange),
        ),
        const SizedBox(height: 16),
        const Text('No credentials yet',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: _black)),
        const SizedBox(height: 6),
        const Text('Add credentials to connect external services',
            style: TextStyle(fontSize: 13, color: _zinc500)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => Get.to(() => const CredentialCreateScreen()),
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('Add Credential'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _orange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ]),
    );
  }

  void _confirmDelete(BuildContext context, CredentialController controller,
      N8nCredential cred) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Credential',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Delete "${cred.name}"? This cannot be undone.',
            style: const TextStyle(fontSize: 14, color: _zinc500)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: _zinc500))),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteCredential(cred.id);
            },
            child: const Text('Delete',
                style: TextStyle(
                    color: Color(0xFFEF4444), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Credential type icon map ────────────────────────────────────────────────
IconData _iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'postgres':
    case 'mysql':
    case 'mongodb':
      return Icons.storage_rounded;
    case 'slack':
      return Icons.chat_bubble_outline_rounded;
    case 'gmail':
    case 'smtp':
      return Icons.email_outlined;
    case 'github':
    case 'gitlab':
      return Icons.code_rounded;
    case 'googledriveoauth2api':
    case 'googlesheetsOAuth2Api':
      return Icons.cloud_outlined;
    case 'stripe':
      return Icons.payment_rounded;
    default:
      return Icons.vpn_key_outlined;
  }
}

class _CredentialCard extends StatelessWidget {
  final N8nCredential credential;
  final VoidCallback onDelete;

  const _CredentialCard({required this.credential, required this.onDelete});

  static const _black = Color(0xFF18181B);
  static const _zinc400 = Color(0xFFA1A1AA);
  static const _zinc200 = Color(0xFFE4E4E7);
  static const _orange = Color(0xFFEA580C);
  static const _orangeTint = Color(0xFFFFF4EE);
  static const _orangeBorder = Color(0xFFFFD9C2);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _zinc200),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _orangeTint,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _orangeBorder),
          ),
          child: Icon(_iconForType(credential.type), size: 20, color: _orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(credential.name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _black)),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _orangeTint,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _orangeBorder),
                ),
                child: Text(credential.type,
                    style: const TextStyle(
                        fontSize: 10,
                        color: _orange,
                        fontWeight: FontWeight.w600)),
              ),
              if (credential.isManaged) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Text('Managed',
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF16A34A),
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ]),
            if (credential.createdAt != null) ...[
              const SizedBox(height: 3),
              Text(
                'Created ${credential.createdAt!.day}/${credential.createdAt!.month}/${credential.createdAt!.year}',
                style: const TextStyle(fontSize: 11, color: _zinc400),
              ),
            ],
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded,
              size: 18, color: Color(0xFFEF4444)),
          onPressed: onDelete,
          splashRadius: 20,
        ),
      ]),
    );
  }
}
