import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n8n_manager/core/utils/app_colors.dart';
import 'package:n8n_manager/core/utils/custom_textformfield.dart';
import 'package:n8n_manager/core/utils/customtext.dart';
import 'package:n8n_manager/core/widgets/banner_ad_widget.dart'; 
import 'executions_viewmodel.dart';

class ExecutionsListScreen extends ConsumerStatefulWidget {
  const ExecutionsListScreen({super.key});

  @override
  ConsumerState<ExecutionsListScreen> createState() =>
      _ExecutionsListScreenState();
}

class _ExecutionsListScreenState extends ConsumerState<ExecutionsListScreen> {
  final _scrollController = ScrollController();
  String _filter = 'all';
  bool _isLoadingMore = false;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

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

  void _showDetails(BuildContext context, item) {
    final resultData = item.data?['resultData'];
    final error = resultData?['error'];
    final message = error?['message'];
    final stack = error?['stack'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
              Text('Started: ${item.startedAt}'),
              Text('Finished: ${item.finishedAt ?? '—'}'),
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
                Text(
                  'Message:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(message.toString(), style: const TextStyle(fontSize: 12)),
              ],
              if (stack != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Stack:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
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
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
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
            onPressed: () => Navigator.of(context).pop(),
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
      appBar: AppBar(
        title: CustomText(
          text: 'Executions',
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.backgroundLight,
      ),
      backgroundColor: AppColors.backgroundLight,
      bottomNavigationBar: const BannerAdWidget(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                CustomInputField(
                  hintText: "Search executions by id or status",
                  prefixIcon: Icons.search,
                  textController: _searchController,
                ),
                SizedBox(width: 16.0),

                Row(
                  children: [
                    CustomText(text: 'Filter:'),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _filter == 'all',
                      onSelected: (v) {
                        setState(() {
                          _filter = 'all';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Success'),
                      selected: _filter == 'success',
                      onSelected: (v) {
                        setState(() {
                          _filter = 'success';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Error'),
                      selected: _filter == 'error',
                      onSelected: (v) {
                        setState(() {
                          _filter = 'error';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: state.when(
              data: (items) {
                final filtered = items.where((i) {
                  // chip filter
                  if (_filter == 'success' &&
                      !i.status.toLowerCase().contains('success')) {
                    return false;
                  }
                  if (_filter == 'error' &&
                      !i.status.toLowerCase().contains('error')) {
                    return false;
                  }

                  // search filter (id or status)
                  if (_search.isNotEmpty) {
                    final s = _search.toLowerCase();
                    final id = i.id.toLowerCase();
                    final status = i.status.toLowerCase();
                    if (!id.contains(s) && !status.contains(s)) return false;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No executions'));
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(executionsViewModelProvider.notifier).refresh(),
                  child: ListView.separated(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filtered.length + 1, // extra for loader
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      if (idx == filtered.length) {
                        // bottom loader
                        // show only when we suspect more items exist (simple heuristic)
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

                      // status color
                      Color statusColor = Colors.grey;
                      final s = it.status.toLowerCase();
                      if (s.contains('success')) {
                        statusColor = Colors.green;
                      } else if (s.contains('error') ||
                          s.contains('failed') ||
                          s.contains('fail'))
                        // ignore: curly_braces_in_flow_control_structures
                        statusColor = Colors.red;
                      else if (s.contains('running'))
                        // ignore: curly_braces_in_flow_control_structures
                        statusColor = Colors.orange;

                      String subtitleText() {
                        final started = it.startedAt;
                        final startedStr = TimeOfDay.fromDateTime(
                          started,
                        ).format(context);
                        final ago = _relativeTime(started);
                        return '${it.status} • $startedStr $ago';
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          radius: 6,
                          backgroundColor: statusColor,
                        ),
                        title: Text(
                          it.workflowName ?? 'Execution ${it.id}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          'ID: ${it.id} • ${subtitleText()}',
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () => _showDetails(context, it),
                        ),
                        onTap: () => _showDetails(context, it),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return '(now)';
    if (diff.inMinutes < 60) return '(${diff.inMinutes}m ago)';
    if (diff.inHours < 24) return '(${diff.inHours}h ago)';
    return '(${diff.inDays}d ago)';
  }
}
