import 'package:dio/dio.dart';
import 'package:n8n_manager/tag/error_handler.dart';
import 'package:n8n_manager/tag/tag_model.dart';

class N8nTagService {
  final Dio _dio;

  N8nTagService(this._dio);

  /// GET /api/v1/tags
  Future<N8nTagList> getTags({int limit = 100, String? cursor}) async {
    try {
      final response = await _dio.get(
        '/api/v1/tags',
        queryParameters: {
          'limit': limit,
          if (cursor != null) 'cursor': cursor,
        },
      );
      return N8nTagList.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// GET /api/v1/tags/{id}
  Future<N8nTag> getTagById(String id) async {
    try {
      final response = await _dio.get('/api/v1/tags/$id');
      return N8nTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// POST /api/v1/tags
  Future<N8nTag> createTag(String name) async {
    try {
      final response = await _dio.post(
        '/api/v1/tags',
        data: {'name': name},
      );
      return N8nTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// PUT /api/v1/tags/{id}
  Future<N8nTag> updateTag(String id, String newName) async {
    try {
      final response = await _dio.put(
        '/api/v1/tags/$id',
        data: {'name': newName},
      );
      return N8nTag.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// DELETE /api/v1/tags/{id}
  Future<void> deleteTag(String id) async {
    try {
      await _dio.delete('/api/v1/tags/$id');
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  /// সব page auto-fetch করে সব tag নিয়ে আসে
  Future<List<N8nTag>> getAllTags() async {
    final allTags = <N8nTag>[];
    String? cursor;
    do {
      final result = await getTags(limit: 100, cursor: cursor);
      allTags.addAll(result.data);
      cursor = result.nextCursor;
    } while (cursor != null);
    return allTags;
  }
}
