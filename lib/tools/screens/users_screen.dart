import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../data/n8n_tools_service.dart';
import '../data/tools_models.dart';
import '../widgets/tool_widgets.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final _svc = Get.find<N8nToolsService>();
  List<N8nUser> _items = [];
  bool _loading = true;
  String? _error;

  static const _roles = {
    'global:admin': 'Admin',
    'global:member': 'Member',
  };

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
      final items = await _svc.getUsers();
      if (mounted) setState(() => _items = items);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _pickRole(String current) {
    return Get.bottomSheet<String>(
      Container(
        padding: EdgeInsets.only(
            top: 16, bottom: 16 + MediaQuery.of(context).viewPadding.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose role',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ..._roles.entries.map((r) => ListTile(
                  leading: Icon(
                      r.key == 'global:admin'
                          ? Icons.admin_panel_settings_rounded
                          : Icons.person_rounded,
                      color: AppTheme.primaryColor),
                  title: Text(r.value),
                  subtitle: Text(r.key == 'global:admin'
                      ? 'Manage users and all workflows'
                      : 'Work on own and shared workflows'),
                  trailing: r.key == current
                      ? const Icon(Icons.check_rounded,
                          color: AppTheme.successColor)
                      : null,
                  onTap: () => Get.back(result: r.key),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _invite() async {
    final values = await showFormSheet(
      title: 'Invite user',
      fields: const [FormFieldSpec('Email', hint: 'name@company.com')],
      submit: 'Next',
    );
    if (values == null) return;
    if (!GetUtils.isEmail(values[0])) {
      toolToast('Enter a valid email address', error: true);
      return;
    }
    final role = await _pickRole('global:member');
    if (role == null) return;
    var failed = true;
    final link = await runWithProgress(() async {
      final url = await _svc.inviteUser(values[0], role);
      failed = false;
      return url;
    });
    if (failed) return;
    _load();
    if (link == null) {
      toolToast('Invitation sent to ${values[0]}');
      return;
    }
    // No SMTP on the server: let the admin share the sign-up link.
    Get.dialog(AlertDialog(
      title: const Text('Invite link'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Email is not configured on this server. '
              'Send this sign-up link to the user:'),
          CodeBlock(link),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Close')),
      ],
    ));
  }

  Future<void> _changeRole(N8nUser u) async {
    final role = await _pickRole(u.role);
    if (role == null || role == u.role) return;
    final ok = await runAction(() => _svc.changeUserRole(u.id, role),
        success: 'Role updated');
    if (ok) _load();
  }

  Future<void> _delete(N8nUser u) async {
    if (!await confirmDialog('Remove user', 'Remove ${u.email}?',
        confirm: 'Remove')) {
      return;
    }
    final ok =
        await runAction(() => _svc.deleteUser(u.id), success: 'User removed');
    if (ok) _load();
  }

  Color _roleColor(N8nUser u) => u.isOwner
      ? AppTheme.warningColor
      : u.role == 'global:admin'
          ? AppTheme.primaryColor
          : AppTheme.accentColor;

  @override
  Widget build(BuildContext context) {
    final pending = _items.where((u) => u.isPending).length;
    final state = ToolState(
      loading: _loading,
      error: _error,
      empty: _items.isEmpty,
      emptyTitle: 'No users',
      emptySubtitle: 'Invite teammates to collaborate on workflows.',
      emptyIcon: Icons.group_rounded,
      onRetry: _load,
    );
    return ToolPage(
      title: 'Users',
      onRefresh: _load,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        onPressed: _invite,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Invite'),
      ),
      header: ToolHeader(
        icon: Icons.group_rounded,
        title: _loading
            ? 'Loading members...'
            : '${_items.length} members'
            '${pending > 0 ? ' · $pending pending' : ''}',
        subtitle: 'Invite people, change roles or remove access. '
            'Requires an owner or admin API key.',
        color: AppTheme.warningColor,
      ),
      children: state.shows
          ? [state]
          : _items
              .map((u) => ToolCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor:
                              _roleColor(u).withValues(alpha: 0.18),
                          child: Text(
                              u.displayName.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                  color: _roleColor(u),
                                  fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              if (u.displayName != u.email)
                                Text(u.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: mutedText(context))),
                              const SizedBox(height: 5),
                              Row(children: [
                                ToolChip(u.roleLabel, color: _roleColor(u)),
                                if (u.isPending) ...[
                                  const SizedBox(width: 6),
                                  const ToolChip('Pending',
                                      color: AppTheme.darkTextSecondary),
                                ],
                              ]),
                            ],
                          ),
                        ),
                        if (!u.isOwner)
                          PopupMenuButton<String>(
                            onSelected: (v) =>
                                v == 'role' ? _changeRole(u) : _delete(u),
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                  value: 'role', child: Text('Change role')),
                              PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Remove user',
                                      style: TextStyle(
                                          color: AppTheme.errorColor))),
                            ],
                          ),
                      ],
                    ),
                  ))
              .toList(),
    );
  }
}
