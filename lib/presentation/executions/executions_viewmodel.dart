import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../core/providers.dart';
import 'execution_model.dart';
import 'execution_service.dart';

class ExecutionsViewModel
    extends StateNotifier<AsyncValue<List<ExecutionModel>>> {
  final Ref ref;
  late final ExecutionService _service;
  String? _nextCursor;
  final int _limit = 10;
  bool _hasMore = true;

  ExecutionsViewModel(this.ref) : super(const AsyncValue.data([])) {
    final auth = ref.read(authServiceProvider);
    _service = ExecutionService(auth.dio);
  }

  Future<void> refresh() async {
    _nextCursor = null;
    _hasMore = true;
    state = const AsyncValue.loading();
    await _loadPage();
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    await _loadPage();
  }

  Future<void> _loadPage() async {
    // print('Loading executions with cursor=$_nextCursor limit=$_limit');
    try {
      try {
        // print('Dio baseUrl: ${_service.dio.options.baseUrl}');
        // print('Dio headers: ${_service.dio.options.headers}');
      } catch (_) {}
      final resp = await _service.fetchExecutions(
        limit: _limit,
        cursor: _nextCursor,
      );
      // print(
      //   'Fetch executions response status=${resp.statusCode} data=${resp.data}',
      // );

      final items = <ExecutionModel>[];
      dynamic body = resp.data;
      List records = [];
      if (body is List) {
        records = body;
      } else if (body is Map && body['data'] is List) {
        records = body['data'] as List;
      }

      for (final e in records) {
        final id = e['id']?.toString() ?? '';
        final status = e['status']?.toString() ?? '';
        DateTime? started;
        DateTime? finished;
        try {
          started = DateTime.parse(e['startedAt']);
        } catch (_) {}
        try {
          if (e['finishedAt'] != null) {
            finished = DateTime.parse(e['finishedAt']);
          }
        } catch (_) {}
        
        // Extract workflow name from workflowData
        final workflowName = e['workflowData']?['name']?.toString() ?? 
                             e['workflowName']?.toString();
        
        items.add(
          ExecutionModel(
            id: id,
            status: status,
            startedAt: started ?? DateTime.now(),
            finishedAt: finished,
            workflowName: workflowName,
            data: e['data'],
          ),
        );
      }

      if (_nextCursor == null) {
        // first page or cursor not set
        final current = state.asData?.value ?? [];
        state = AsyncValue.data([...current, ...items]);
      } else {
        final current = state.asData?.value ?? [];
        state = AsyncValue.data([...current, ...items]);
      }

      // If API returns nextCursor in response, use it. Otherwise stop when fewer items returned.
      try {
        if (resp.data is Map && resp.data['nextCursor'] != null) {
          _nextCursor = resp.data['nextCursor']?.toString();
          _hasMore = _nextCursor != null && _nextCursor!.isNotEmpty;
        } else {
          _hasMore = items.length >= _limit;
        }
      } catch (_) {
        _hasMore = items.length >= _limit;
      }
    } on DioException catch (e) {
      final r = e.response;
      // print(
      //   'DioException fetching executions: ${e.message} status=${r?.statusCode} body=${r?.data}',
      // );
      state = AsyncValue.error(
        'Request failed: ${e.message} (status: ${r?.statusCode}) - ${r?.data}',
        e.stackTrace,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> retry(String id) async {
    await _service.retry(id);
    // Optionally refresh list or update item status
    await refresh();
  }
}

final executionsViewModelProvider =
    StateNotifierProvider<
      ExecutionsViewModel,
      AsyncValue<List<ExecutionModel>>
    >((ref) => ExecutionsViewModel(ref));
