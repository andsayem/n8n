import 'package:dio/dio.dart';
import 'package:n8n_manager/core/constants/app_constants.dart';
import 'package:n8n_manager/services/n8n_api_service.dart';
import '../models/n8n_folder_model.dart';

class N8nFolderService {
  final N8nApiService _api;
  N8nFolderService(this._api);

  Dio get _dio => _api.dio;

  String? _projectId;

  String get _projectFoldersBase =>
      '/api/v1/projects/$_projectId/folders';

  Future<String?> _resolveProjectId() async {
    if (_projectId != null) return _projectId;
    try {
      final res = await _dio.get(
        AppConstants.projectsEndpoint,
        queryParameters: {'limit': 50},
      );
      final list = _parseList(res.data);
      if (list.isEmpty) return null;
      _projectId = list.first['id']?.toString();
      return _projectId;
    } on DioException {
      return null;
    }
  }

  Future<List<N8nFolder>> getFolders() async {
    final projectId = await _resolveProjectId();

    if (projectId != null) {
      try {
        final res = await _dio.get(
          _projectFoldersBase,
          queryParameters: {'limit': 200},
        );
        final list = _parseList(res.data);
        return list.map(_fromJson).toList();
      } on DioException {
        // fall back to the flat endpoint below
      }
    }

    final res = await _dio.get(
      AppConstants.foldersEndpoint,
      queryParameters: {'limit': 200},
    );
    return _parseList(res.data).map(_fromJson).toList();
  }

  Future<N8nFolder> createFolder(String name, {String? parentFolderId}) async {
    final body = <String, dynamic>{'name': name};
    if (parentFolderId != null) body['parentFolderId'] = parentFolderId;

    final projectId = await _resolveProjectId();
    if (projectId != null) {
      final res = await _dio.post(_projectFoldersBase, data: body);
      return _fromJson(res.data as Map<String, dynamic>);
    }

    final res = await _dio.post(AppConstants.foldersEndpoint, data: body);
    return _fromJson(res.data as Map<String, dynamic>);
  }

  Future<N8nFolder> renameFolder(String id, String name) async {
    final projectId = await _resolveProjectId();
    if (projectId != null) {
      final res = await _dio.patch(
        '$_projectFoldersBase/$id',
        data: {'name': name},
      );
      return _fromJson(res.data as Map<String, dynamic>);
    }

    final res = await _dio.patch(
      '${AppConstants.foldersEndpoint}/$id',
      data: {'name': name},
    );
    return _fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteFolder(String id) async {
    final projectId = await _resolveProjectId();
    if (projectId != null) {
      await _dio.delete('$_projectFoldersBase/$id');
      return;
    }
    await _dio.delete('${AppConstants.foldersEndpoint}/$id');
  }

  N8nFolder _fromJson(Map<String, dynamic> json) {
    final folder = N8nFolder.fromJson(json);
    return N8nFolder(
      id: folder.id,
      name: folder.name,
      parentFolderId: folder.parentFolderId,
      projectId: folder.projectId ?? _projectId,
      createdAt: folder.createdAt,
      updatedAt: folder.updatedAt,
      workflowCount: folder.workflowCount,
      subFolderCount: folder.subFolderCount,
    );
  }

  List<Map<String, dynamic>> _parseList(dynamic data) {
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    if (data is List) return data.cast<Map<String, dynamic>>();
    return [];
  }
}