import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../core/constants/app_constants.dart';
import '../../data/models/workflow_model.dart';
import '../../data/models/execution_model.dart';

class N8nApiService extends GetxService {
  late Dio _dio;
  String _baseUrl = '';
  String _apiKey = '';

  void configure(String baseUrl, String apiKey) {
    _baseUrl = baseUrl;
    _apiKey = apiKey;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        AppConstants.apiKeyHeader: _apiKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) {
        handler.next(e);
      },
    ));
  }

  Future<List<WorkflowModel>> getWorkflows({
    int? limit,
    int? cursor,
    bool? active,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (active != null) queryParams['active'] = active;

      final response = await _dio.get(
        AppConstants.workflowsEndpoint,
        queryParameters: queryParams,
      );

      final data = response.data;
      List<dynamic> list = [];

      if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is List) {
        list = data;
      }

      return list.map((e) => WorkflowModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkflowModel> getWorkflow(String id) async {
    try {
      final response = await _dio.get('${AppConstants.workflowsEndpoint}/$id');
      return WorkflowModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<ExecutionModel>> getExecutions({
    String? workflowId,
    String? status,
    int? limit,
    bool includeData = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'includeData': includeData,
      };
      if (workflowId != null) queryParams['workflowId'] = workflowId;
      if (status != null) queryParams['status'] = status;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get(
        AppConstants.executionsEndpoint,
        queryParameters: queryParams,
      );

      final data = response.data;
      List<dynamic> list = [];

      if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is List) {
        list = data;
      }

      return list.map((e) => ExecutionModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExecutionModel> getExecution(String id) async {
    try {
      final response = await _dio.get(
        '${AppConstants.executionsEndpoint}/$id',
        queryParameters: {'includeData': true},
      );
      return ExecutionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> activateWorkflow(String id) async {
    try {
      await _dio.post('${AppConstants.workflowsEndpoint}/$id${AppConstants.activateEndpoint}');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deactivateWorkflow(String id) async {
    try {
      await _dio.post('${AppConstants.workflowsEndpoint}/$id${AppConstants.deactivateEndpoint}');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> runWorkflow(String id, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(
        '${AppConstants.workflowsEndpoint}/$id${AppConstants.runEndpoint}',
        data: data ?? {},
      );
      return response.data as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> testConnection() async {
    try {
      await _dio.get(AppConstants.workflowsEndpoint, queryParameters: {'limit': 1});
      return true;
    } catch (_) {
      return false;
    }
  }

  Exception _handleError(DioException e) {
    String message;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Check your server URL.';
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot connect to server. Check URL and network.';
        break;
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401) {
          message = 'Invalid API key. Please check your credentials.';
        } else if (status == 403) {
          message = 'Access denied. Insufficient permissions.';
        } else if (status == 404) {
          message = 'Resource not found.';
        } else {
          message = 'Server error ($status): ${e.response?.statusMessage ?? 'Unknown'}';
        }
        break;
      default:
        message = e.message ?? 'An unexpected error occurred.';
    }
    return Exception(message);
  }
}
