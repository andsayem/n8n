import 'package:dio/dio.dart';

class ExecutionService {
  final Dio dio;

  ExecutionService(this.dio);

  /// Fetch executions. Use cursor-based pagination when available.
  /// If [cursor] is provided it will be added as the `cursor` query parameter.
  /// Includes full execution data with workflow information.
  Future<Response> fetchExecutions({int limit = 50, String? cursor}) async {
    final qp = <String, dynamic>{
      'limit': limit,
      'includeData': 'true',
    };
    if (cursor != null && cursor.isNotEmpty) qp['cursor'] = cursor;
    return dio.get('/api/v1/executions', queryParameters: qp, options: Options(validateStatus: (_) => true));
  }

  Future<Response> retry(String id) async {
    return dio.post('/api/v1/executions/$id/retry');
  }
}
