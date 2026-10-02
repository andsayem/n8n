import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../data/n8n_tools_service.dart';
import '../data/tools_models.dart';
import '../widgets/tool_widgets.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _svc = Get.find<N8nToolsService>();
  List<N8nProject> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _items.isEmpty;
      _error = null;
    });
    try {
      final items = await _svc.getProjects();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([N8nProject? p]) async {
    final values = await showFormSheet(
      title: p == null ? 'New Project' : 'Rename Project',
      fields: [FormFieldSpec('Project name', initial: p?.name ?? '')],
      submit: p == null ? 'Create' : 'Save',
    );
    if (values == null) return;
    final ok = await runAction(
      () => p == null
          ? _svc.createProject(values[0])
          : _svc.renameProject(p.id, values[0]),
      success: p == null ? 'Project created' : 'Project renamed',
    );
    if (ok) _load();
  }

  Future<void> _delete(N8nProject p) async {
    if (!await confirmDialog('Delete project',
        'Delete "${p.name}"? Its workflows and credentials are removed too.')) {
      return;
    }
    final ok = await runAction(() => _svc.deleteProject(p.id),
        success: 'Project deleted');
    if (ok) _load();
  }

  @override
  Widget build(BuildContext context) {
    final team = _items.where((p) => !p.isPersonal).length;
    final state = ToolState(
      loading: _loading,
      error: _error,
      empty: _items.isEmpty,
      emptyTitle: 'No projects',
      emptySubtitle:
          'Create a team project to share workflows and credentials.',
      emptyIcon: Icons.workspaces_rounded,
      onRetry: _load,
    );
    return ToolPage(
      title: 'Projects',
      onRefresh: _load,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: () => _edit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Project'),
      ),
      header: ToolHeader(
        icon: Icons.workspaces_rounded,
        title: _loading ? 'Loading projects...' : '$team team projects',
        subtitle: 'Projects group workflows, credentials and members. '
            'Team projects need an n8n Pro or Enterprise licence.',
        color: const Color(0xFF7C6CFF),
      ),
      children: state.shows
          ? [state]
          : _items
              .map((p) => ToolCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: (p.isPersonal
                                  ? AppTheme.accentColor
                                  : const Color(0xFF7C6CFF))
                              .withValues(alpha: 0.18),
                          child: Icon(
                              p.isPersonal
                                  ? Icons.person_rounded
                                  : Icons.groups_rounded,
                              size: 20,
                              color: p.isPersonal
                                  ? AppTheme.accentColor
                                  : const Color(0xFF7C6CFF)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              ToolChip(p.isPersonal ? 'Personal' : 'Team',
                                  color: p.isPersonal
                                      ? AppTheme.accentColor
                                      : const Color(0xFF7C6CFF)),
                            ],
                          ),
                        ),
                        if (!p.isPersonal) ...[
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 19),
                            onPressed: () => _edit(p),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20, color: AppTheme.errorColor),
                            onPressed: () => _delete(p),
                          ),
                        ],
                      ],
                    ),
                  ))
              .toList(),
    );
  }
}
