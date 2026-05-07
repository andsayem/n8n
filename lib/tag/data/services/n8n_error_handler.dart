import 'package:dio/dio.dart';

Exception handleDioError(DioException e) {
  final statusCode = e.response?.statusCode;
  final message = _extractMessage(e.response?.data);

  switch (statusCode) {
    case 400:
      return Exception('Bad request: $message');
    case 401:
      return Exception('Unauthorized — API key invalid or missing');
    case 403:
      return Exception('Forbidden — insufficient permissions');
    case 404:
      return Exception('Not found: $message');
    case 422:
      return Exception('Validation error: $message');
    case 500:
      return Exception('n8n server error: $message');
    default:
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Exception('Connection timeout — check your server URL');
      }
      return Exception('Network error: ${e.message}');
  }
}

String _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message'] as String? ??
        data['error'] as String? ??
        data.toString();
  }
  return data?.toString() ?? 'Unknown error';
}
