import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/medium_rect_ad.dart';

/// Standard layout for the n8n tool pages: a header card as the first
/// section, the 300x250 ad as the second, then the page content.
class ToolPage extends StatelessWidget {
  final String title;
  final Widget header;
  final List<Widget> children;
  final List<Widget>? actions;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;

  const ToolPage({
    super.key,
    required this.title,
    required this.header,
    required this.children,
    this.actions,
    this.onRefresh,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Untinted text on these pages uses the primary text colour (the theme's
    // default body colour is a muted grey).
    final list = DefaultTextStyle.merge(
      style: TextStyle(
          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          header,
          const MediumRectAd(padding: EdgeInsets.symmetric(vertical: 14)),
          ...children,
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      floatingActionButton: floatingActionButton,
      body: onRefresh == null
          ? list
          : RefreshIndicator(
              color: AppTheme.primaryColor,
              onRefresh: onRefresh!,
              child: list,
            ),
    );
  }
}

/// Gradient intro card used as the first section of tool pages.
class ToolHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget? trailing;

  const ToolHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = AppTheme.primaryColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: mutedText(context))),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

/// Bordered card matching the app's surface colours.
class ToolCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const ToolCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: borderColor ??
                      (isDark ? AppTheme.darkBorder : AppTheme.lightBorder)),
            ),
            // Material resets DefaultTextStyle to the muted body colour.
            child: DefaultTextStyle.merge(
              style: TextStyle(
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.lightTextPrimary),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading / error / empty states inside a [ToolPage] list.
class ToolState extends StatelessWidget {
  final bool loading;
  final String? error;
  final bool empty;
  final String emptyTitle;
  final String emptySubtitle;
  final IconData emptyIcon;
  final VoidCallback? onRetry;

  const ToolState({
    super.key,
    required this.loading,
    this.error,
    required this.empty,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.emptyIcon,
    this.onRetry,
  });

  bool get shows => loading || error != null || empty;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }
    final isError = error != null;
    final needsLicense = isError && error!.contains('Enterprise licence');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          Icon(
              needsLicense
                  ? Icons.workspace_premium_rounded
                  : isError
                      ? Icons.cloud_off_rounded
                      : emptyIcon,
              size: 44,
              color: needsLicense
                  ? AppTheme.warningColor
                  : isError
                      ? AppTheme.errorColor
                      : AppTheme.darkTextMuted),
          const SizedBox(height: 12),
          Text(
              needsLicense
                  ? 'Enterprise feature'
                  : isError
                      ? 'Something went wrong'
                      : emptyTitle,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(isError ? error! : emptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12.5, height: 1.4, color: mutedText(context))),
          if (isError && !needsLicense && onRetry != null) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Small coloured pill.
class ToolChip extends StatelessWidget {
  final String label;
  final Color color;
  const ToolChip(this.label, {super.key, this.color = AppTheme.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

/// Monospace command block with a copy button.
class CodeBlock extends StatelessWidget {
  final String code;
  const CodeBlock(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0B0B12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A3A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(code,
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.45,
                      color: Color(0xFFB8F5D8))),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Copy',
            icon: const Icon(Icons.copy_rounded,
                size: 18, color: Color(0xFF8888AA)),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              toolToast('Copied to clipboard');
            },
          ),
        ],
      ),
    );
  }
}

void toolToast(String message, {bool error = false}) {
  Get.closeAllSnackbars();
  Get.snackbar(
    error ? 'Error' : 'Done',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    backgroundColor: (error ? AppTheme.errorColor : AppTheme.successColor)
        .withValues(alpha: 0.92),
    colorText: Colors.white,
    duration: Duration(seconds: error ? 4 : 2),
  );
}

Future<bool> confirmDialog(String title, String message,
    {String confirm = 'Delete', bool destructive = true}) async {
  final ok = await Get.dialog<bool>(AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
          onPressed: () => Get.back(result: false),
          child: const Text('Cancel')),
      TextButton(
        onPressed: () => Get.back(result: true),
        child: Text(confirm,
            style: TextStyle(
                color:
                    destructive ? AppTheme.errorColor : AppTheme.primaryColor,
                fontWeight: FontWeight.w700)),
      ),
    ],
  ));
  return ok ?? false;
}

class FormFieldSpec {
  final String label;
  final String initial;
  final String? hint;
  final int maxLines;
  final bool required;
  const FormFieldSpec(this.label,
      {this.initial = '', this.hint, this.maxLines = 1, this.required = true});
}

/// Bottom sheet with text fields. Returns the values or null if cancelled.
Future<List<String>?> showFormSheet({
  required String title,
  required List<FormFieldSpec> fields,
  String submit = 'Save',
}) {
  final controllers =
      fields.map((f) => TextEditingController(text: f.initial)).toList();
  final formKey = GlobalKey<FormState>();
  return Get.bottomSheet<List<String>>(
    Builder(builder: (context) {
      return Container(
        padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 +
                MediaQuery.of(context).viewInsets.bottom +
                MediaQuery.of(context).viewPadding.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.darkTextMuted,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                for (var i = 0; i < fields.length; i++) ...[
                  TextFormField(
                    controller: controllers[i],
                    maxLines: fields[i].maxLines,
                    decoration: InputDecoration(
                      labelText: fields[i].label,
                      hintText: fields[i].hint,
                    ),
                    validator: (v) =>
                        fields[i].required && (v == null || v.trim().isEmpty)
                            ? '${fields[i].label} is required'
                            : null,
                  ),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Get.back(
                        result: controllers.map((c) => c.text.trim()).toList());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(submit,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      );
    }),
    isScrollControlled: true,
  );
}

/// Like [runWithProgress] for actions without a result; true on success.
Future<bool> runAction(Future<void> Function() action,
    {String? success}) async {
  final ok = await runWithProgress<bool>(() async {
    await action();
    return true;
  }, success: success);
  return ok ?? false;
}

/// Runs [action] with a blocking progress dialog and reports the result.
/// Returns null when the action failed (the error is shown as a toast).
Future<T?> runWithProgress<T>(Future<T> Function() action,
    {String? success}) async {
  Get.dialog(
    const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor)),
    barrierDismissible: false,
  );
  try {
    final result = await action();
    if (Get.isDialogOpen ?? false) Get.back();
    if (success != null) toolToast(success);
    return result;
  } catch (e) {
    if (Get.isDialogOpen ?? false) Get.back();
    toolToast(e.toString().replaceFirst('Exception: ', ''), error: true);
    return null;
  }
}

/// Secondary text colour that stays readable on the dark theme (the theme's
/// bodySmall colour is too dim on cards).
Color mutedText(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? AppTheme.darkTextSecondary
        : AppTheme.lightTextSecondary;
