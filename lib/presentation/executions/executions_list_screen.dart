import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n8n_manager/core/theme/app_theme.dart';
import 'package:n8n_manager/core/utils/app_utils.dart';
import 'package:n8n_manager/core/widgets/banner_ad_widget.dart';
import 'package:n8n_manager/presentation/widgets/common_widgets.dart';
import 'execution_model.dart';
import 'executions_viewmodel.dart';

class ExecutionsListScreen extends ConsumerStatefulWidget {
  const ExecutionsListScreen({super.key});

  @override
  ConsumerState<ExecutionsListScreen> createState() =>
      _ExecutionsListScreenState();
}

class _ExecutionsListScreenState extends ConsumerState<ExecutionsListScreen> {
  final _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all';
  String _search = '';
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Schedule the initial refresh after the first frame so any state updates
    // performed by the viewmodel don't occur during widget build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(executionsViewModelProvider.notifier).refresh();
    });
    _scrollController.addListener(() async {
      if (_isLoadingMore) return;
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        _isLoadingMore = true;
        try {
          await ref.read(executionsViewModelProvider.notifier).loadMore();
        } finally {
          // small delay to avoid immediate retriggering
          await Future.delayed(const Duration(milliseconds: 300));
          _isLoadingMore = false;
        }
      }
    });
    _searchController.addListener(() {
      final v = _searchController.text.trim();
      if (v != _search) {
        setState(() => _search = v);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _matches(ExecutionModel i) {
    final s = i.status.toLowerCase();

    if (_filter == 'success' && !s.contains('success')) return false;
    if (_filter == 'error' && !(s.contains('error') || s.contains('fail'))) {
      return false;
    }

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      if (!i.id.toLowerCase().contains(q) && !s.contains(q)) return false;
    }

    return true;
  }

  void _showDetails(BuildContext context, ExecutionModel item) {
    final resultData = item.data?['resultData'];
    final error = resultData?['error'];
    final message = error?['message'];
    final stack = error?['stack'];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).cardColor,
        title: Text('Execution ${item.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.workflowName != null) ...[
                Text(
                  'Workflow: ${item.workflowName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
              ],
              Text('Status: ${item.status}'),
              Text('Started: ${AppUtils.formatDate(item.startedAt.toIso8601String())}'),
              Text('Finished: ${item.finishedAt != null ? AppUtils.formatDate(item.finishedAt!.toIso8601String()) : '—'}'),
              if (item.finishedAt != null)
                Text(
                  'Duration: ${item.finishedAt!.difference(item.startedAt)}',
                ),
              const SizedBox(height: 12),
              if (item.data != null) ...[
                Text('Mode: ${item.data?['mode'] ?? 'N/A'}'),
                if (item.data?['retryOf'] != null)
                  Text('Retry of: ${item.data!['retryOf']}'),
                if (item.data?['waitTill'] != null)
                  Text('Wait till: ${item.data!['waitTill']}'),
              ],
              if (message != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Message:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(message.toString(), style: const TextStyle(fontSize: 12)),
              ],
              if (stack != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Stack:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    stack.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (item.status.toLowerCase().contains('fail'))
            TextButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(dialogContext);
                Navigator.of(dialogContext).pop();
                try {
                  await ref
                      .read(executionsViewModelProvider.notifier)
                      .retry(item.id);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Retry requested')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Retry error: $e')),
                  );
                }
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(executionsViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: const BannerAdWidget(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor,
            pinned: true,
            title: const Text('Executions'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(112),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  children: [
                    _SearchBar(controller: _searchController),
                    const SizedBox(height: 10),
                    _FilterTabs(
                      selected: _filter,
                      onChanged: (v) => setState(() => _filter = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: state.when(
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: CardSkeletonLoader(),
            ),
          ),
          error: (e, _) => ErrorRetryWidget(
            message: '$e',
            onRetry: () =>
                ref.read(executionsViewModelProvider.notifier).refresh(),
          ),
          data: (items) {
            final filtered = items.where(_matches).toList();

            if (filtered.isEmpty) {
              return EmptyStateWidget(
                title: _search.isNotEmpty ? 'No Results Found' : 'No Executions',
                subtitle: _search.isNotEmpty
                    ? 'Try a different search term.'
                    : 'No executions found yet.',
                icon: Icons.playlist_remove_rounded,
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(executionsViewModelProvider.notifier).refresh(),
              color: AppTheme.primaryColor,
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length + 1,
                itemBuilder: (context, idx) {
                  if (idx == filtered.length) {
                    final showLoader =
                        filtered.isNotEmpty && filtered.length % 25 == 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: showLoader
                            ? const CircularProgressIndicator()
                            : const SizedBox.shrink(),
                      ),
                    );
                  }

                  final it = filtered[idx];
                  return _ExecutionCard(
                    execution: it,
                    index: idx,
                    onTap: () => _showDetails(context, it),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search executions...',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        isDense: true,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppTheme.primaryColor),
        ),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () => controller.clear(),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const filters = [
      ('all', 'All'),
      ('success', 'Success'),
      ('error', 'Error'),
    ];

    return Container(
      height: 44,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: filters.map((f) {
          final isSelected = selected == f.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(f.$1),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    f.$2,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).textTheme.labelMedium?.color,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ExecutionCard extends StatelessWidget {
  final ExecutionModel execution;
  final int index;
  final VoidCallback onTap;

  const _ExecutionCard({
    required this.execution,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppUtils.statusColor(execution.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    AppUtils.statusIcon(execution.status),
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    execution.workflowName ?? 'Execution ${execution.id}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusBadge(status: execution.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.tag_rounded,
                    label: 'ID ${execution.id}',
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: _InfoChip(
                    icon: Icons.schedule_rounded,
                    label: _relativeTime(execution.startedAt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15, end: 0);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 13, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String _relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}
