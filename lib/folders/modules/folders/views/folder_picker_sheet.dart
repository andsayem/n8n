import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/core/theme/app_theme.dart';
import 'package:n8n_manager/folders/data/models/n8n_folder_model.dart';
import 'package:n8n_manager/folders/modules/folders/controllers/folder_controller.dart';

typedef FolderPickResult = ({N8nFolder? folder, bool root});

Future<FolderPickResult?> showFolderPickerSheet(
  BuildContext context, {
  String? currentFolderId,
}) async {
  final ctrl = Get.find<FolderController>();
  return showModalBottomSheet<FolderPickResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _FolderPickerSheet(
      controller: ctrl,
      currentFolderId: currentFolderId,
    ),
  );
}

class _FolderPickerSheet extends StatelessWidget {
  final FolderController controller;
  final String? currentFolderId;

  const _FolderPickerSheet({
    required this.controller,
    required this.currentFolderId,
  });

  List<(N8nFolder, int)> _tree(BuildContext context) {
    final result = <(N8nFolder, int)>[];
    void walk(List<N8nFolder> folders, int depth) {
      for (final f in folders) {
        result.add((f, depth));
        walk(controller.childrenOf(f.id), depth + 1);
      }
    }

    walk(controller.topLevelFolders(), 0);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final tree = _tree(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
            child: Row(
              children: [
                Text(
                  'Move Workflow',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(12),
              children: [
                _OptionTile(
                  icon: Icons.home_rounded,
                  label: 'Root (no folder)',
                  isSelected: currentFolderId == null,
                  onTap: () =>
                      Navigator.pop(context, (folder: null, root: true)),
                ),
                if (tree.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No folders available.\nCreate one from the Folders screen.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                else
                  ...tree.map(
                    (item) {
                      final (folder, depth) = item;
                      return _OptionTile(
                        icon: depth > 0
                            ? Icons.subdirectory_arrow_right_rounded
                            : Icons.folder_rounded,
                        iconColor: depth > 0 ? AppTheme.accentColor : null,
                        label: folder.name,
                        indent: depth * 20.0,
                        isSelected: currentFolderId == folder.id,
                        onTap: () =>
                            Navigator.pop(context, (folder: folder, root: false)),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double indent;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? iconColor;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.indent = 0,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: EdgeInsetsDirectional.fromSTEB(10 + indent, 10, 10, 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor ??
                  (isSelected ? AppTheme.primaryColor : AppTheme.darkTextMuted),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}