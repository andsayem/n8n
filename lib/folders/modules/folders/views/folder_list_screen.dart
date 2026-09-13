import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:n8n_manager/core/theme/app_theme.dart';
import 'package:n8n_manager/folders/data/models/n8n_folder_model.dart';
import 'package:n8n_manager/folders/modules/folders/controllers/folder_controller.dart';
import 'package:n8n_manager/presentation/widgets/common_widgets.dart';

class FolderListScreen extends StatefulWidget {
  const FolderListScreen({super.key});

  @override
  State<FolderListScreen> createState() => _FolderListScreenState();
}

class _FolderListScreenState extends State<FolderListScreen> {
  late final FolderController _ctrl;
  N8nFolder? _current;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<FolderController>()
        ? Get.find<FolderController>()
        : Get.put(FolderController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            title: const Text('Folders'),
            actions: [
              IconButton(
                tooltip: 'New Folder',
                onPressed: () => _showCreateDialog(),
                icon: const Icon(Icons.create_new_folder_rounded),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: _Breadcrumb(
                  current: _current,
                  onHome: () => setState(() => _current = null),
                ),
              ),
            ),
          ),
        ],
        body: Obx(() {
          if (_ctrl.isLoading.value) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: SkeletonLoader(height: 64, borderRadius: 12),
              ),
            );
          }

          if (_ctrl.hasError.value && _ctrl.folders.isEmpty) {
            return Column(
              children: [
                _NotSupportedBanner(controller: _ctrl),
                Expanded(
                  child: ErrorRetryWidget(
                    message: _ctrl.errorMessage.value,
                    onRetry: _ctrl.loadFolders,
                  ),
                ),
              ],
            );
          }

          final children = _ctrl.childrenOf(_current?.id);

          if (children.isEmpty) {
            return _NotSupportedBanner(controller: _ctrl);
          }

          if (children.isEmpty) {
            return EmptyStateWidget(
              title: 'No ${_current == null ? 'Top-Level ' : ''}Folders',
              subtitle: _current == null
                  ? 'Create a folder to organize your workflows.'
                  : 'No sub-folders inside "${_current!.name}".',
              icon: Icons.folder_off_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) => _FolderCard(
              folder: children[index],
              index: index,
              hasChildren: _ctrl.hasChildren(children[index].id),
              onOpen: _ctrl.hasChildren(children[index].id)
                  ? () => setState(() => _current = children[index])
                  : null,
              onRename: () => _showRenameDialog(children[index]),
              onDelete: () => _confirmDelete(children[index]),
            ),
          );
        }),
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_current == null
            ? 'New Folder'
            : 'New Sub-folder in "${_current!.name}"'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            prefixIcon: Icon(Icons.folder_rounded, size: 18),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              final ok = await _ctrl.createFolder(
                name,
                parentFolderId: _current?.id,
              );
              if (!ok && mounted) {
                Get.snackbar(
                  'Error',
                  _ctrl.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(N8nFolder folder) {
    final nameCtrl = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename Folder'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            prefixIcon: Icon(Icons.folder_rounded, size: 18),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty || name == folder.name) {
                Navigator.pop(ctx);
                return;
              }
              Navigator.pop(ctx);
              final ok = await _ctrl.renameFolder(folder, name);
              if (!ok && mounted) {
                Get.snackbar(
                  'Error',
                  _ctrl.errorMessage.value,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              'Rename',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(N8nFolder folder) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Folder?'),
        content: Text(
            'Delete "${folder.name}"? Contents move to the project root.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.deleteFolder(folder);
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

class _Breadcrumb extends StatelessWidget {
  final N8nFolder? current;
  final VoidCallback onHome;

  const _Breadcrumb({required this.current, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final items = <(String, VoidCallback)>[
      ('All Folders', onHome),
      if (current != null)
        (current!.name, () {}),
    ];

    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Row(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Row(
                children: [
                  GestureDetector(
                    onTap: items[i].$2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLast
                            ? AppTheme.primaryColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLast
                                ? Icons.folder_rounded
                                : Icons.home_rounded,
                            size: 14,
                            color: isLast
                                ? AppTheme.primaryColor
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            items[i].$1,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isLast
                                  ? AppTheme.primaryColor
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NotSupportedBanner extends StatelessWidget {
  final FolderController controller;

  const _NotSupportedBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_rounded,
                  color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'No folders yet',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Create folders to organize and browse your workflows by topic. Folders require an n8n instance with the folders feature enabled.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.lightTextSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final N8nFolder folder;
  final int index;
  final bool hasChildren;
  final VoidCallback? onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _FolderCard({
    required this.folder,
    required this.index,
    required this.hasChildren,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final subCount = folder.subFolderCount ?? (hasChildren ? 1 : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.folder_rounded,
              color: AppTheme.primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folder.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$subCount subfolder${subCount == 1 ? '' : 's'}'
                  '${folder.workflowCount != null ? ' · ${folder.workflowCount} workflows' : ''}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          if (onOpen != null)
            IconButton(
              tooltip: 'Open',
              icon: const Icon(Icons.chevron_right_rounded),
              color: AppTheme.primaryColor,
              onPressed: onOpen,
            ),
          PopupMenuButton<String>(
            color: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (v) {
              if (v == 'rename') onRename();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Rename'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded,
                        size: 16, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Delete',
                        style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}