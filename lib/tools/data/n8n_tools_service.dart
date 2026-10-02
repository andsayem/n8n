import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../services/n8n_api_service.dart';
import 'demo_tools_data.dart';
import 'tools_models.dart';

/// n8n Public API features beyond workflows/executions: variables, projects,
/// users, security audit, source control, health, workflow import/export,
/// execution retry/delete. Every call has a demo-mode branch so the demo
/// account works without a server.
class N8nToolsService extends GetxService {
  N8nApiService get _api => Get.find<N8nApiService>();
  Dio get _dio => _api.dio;
  bool get isDemo => _api.isMockMode;

  final DemoToolsData _demo = DemoToolsData();

  // ── Variables ─────────────────────────────────────────────────────────────

  Future<List<N8nVariable>> getVariables() async {
    if (isDemo) return _delay(List.of(_demo.variables));
    final res = await _call(
        () => _dio.get('/api/v1/variables', queryParameters: {'limit': 250}));
    return _list(res.data).map(N8nVariable.fromJson).toList();
  }

  Future<void> createVariable(String key, String value) async {
    if (isDemo) {
      _demo.variables.add(N8nVariable(
          id: 'v${DateTime.now().millisecondsSinceEpoch}',
          key: key,
          value: value));
      return _delay(null);
    }
    await _call(() =>
        _dio.post('/api/v1/variables', data: {'key': key, 'value': value}));
  }

  Future<void> updateVariable(String id, String key, String value) async {
    if (isDemo) {
      final i = _demo.variables.indexWhere((v) => v.id == id);
      if (i >= 0) {
        _demo.variables[i] = N8nVariable(id: id, key: key, value: value);
      }
      return _delay(null);
    }
    await _call(() =>
        _dio.put('/api/v1/variables/$id', data: {'key': key, 'value': value}));
  }

  Future<void> deleteVariable(String id) async {
    if (isDemo) {
      _demo.variables.removeWhere((v) => v.id == id);
      return _delay(null);
    }
    await _call(() => _dio.delete('/api/v1/variables/$id'));
  }

  // ── Projects ──────────────────────────────────────────────────────────────

  Future<List<N8nProject>> getProjects() async {
    if (isDemo) return _delay(List.of(_demo.projects));
    final res = await _call(
        () => _dio.get('/api/v1/projects', queryParameters: {'limit': 250}));
    return _list(res.data).map(N8nProject.fromJson).toList();
  }

  Future<void> createProject(String name) async {
    if (isDemo) {
      _demo.projects.add(N8nProject(
          id: 'p${DateTime.now().millisecondsSinceEpoch}',
          name: name,
          type: 'team'));
      return _delay(null);
    }
    await _call(() => _dio.post('/api/v1/projects', data: {'name': name}));
  }

  Future<void> renameProject(String id, String name) async {
    if (isDemo) {
      final i = _demo.projects.indexWhere((p) => p.id == id);
      if (i >= 0) {
        _demo.projects[i] =
            N8nProject(id: id, name: name, type: _demo.projects[i].type);
      }
      return _delay(null);
    }
    await _call(() => _dio.put('/api/v1/projects/$id', data: {'name': name}));
  }

  Future<void> deleteProject(String id) async {
    if (isDemo) {
      _demo.projects.removeWhere((p) => p.id == id);
      return _delay(null);
    }
    await _call(() => _dio.delete('/api/v1/projects/$id'));
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  Future<List<N8nUser>> getUsers() async {
    if (isDemo) return _delay(List.of(_demo.users));
    final res = await _call(() => _dio.get('/api/v1/users',
        queryParameters: {'limit': 250, 'includeRole': true}));
    return _list(res.data).map(N8nUser.fromJson).toList();
  }

  /// Invites a user. Returns the sign-up link when the server could not
  /// email it (no SMTP configured), so it can be shared manually.
  Future<String?> inviteUser(String email, String role) async {
    if (isDemo) {
      _demo.users.add(N8nUser(
          id: 'u${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          role: role,
          isPending: true));
      return _delay(null);
    }
    final res = await _call(() => _dio.post('/api/v1/users', data: [
          {'email': email, 'role': role}
        ]));
    final data = res.data;
    if (data is List && data.isNotEmpty && data.first is Map) {
      final first = data.first as Map;
      final error = first['error'];
      if (error != null && error.toString().isNotEmpty) {
        throw ToolsException(error.toString());
      }
      final user = first['user'];
      if (user is Map && user['emailSent'] != true) {
        return user['inviteAcceptUrl']?.toString();
      }
    }
    return null;
  }

  Future<void> changeUserRole(String id, String role) async {
    if (isDemo) {
      final i = _demo.users.indexWhere((u) => u.id == id);
      if (i >= 0) _demo.users[i] = _demo.users[i].copyWith(role: role);
      return _delay(null);
    }
    await _call(() =>
        _dio.patch('/api/v1/users/$id/role', data: {'newRoleName': role}));
  }

  Future<void> deleteUser(String id) async {
    if (isDemo) {
      _demo.users.removeWhere((u) => u.id == id);
      return _delay(null);
    }
    await _call(() => _dio.delete('/api/v1/users/$id'));
  }

  // ── Security audit ────────────────────────────────────────────────────────

  Future<List<AuditReport>> runSecurityAudit({
    int daysAbandonedWorkflow = 90,
  }) async {
    if (isDemo) {
      return _delay(_demo.auditReports(), const Duration(milliseconds: 1400));
    }
    final res = await _call(() => _dio.post('/api/v1/audit', data: {
          'additionalOptions': {
            'daysAbandonedWorkflow': daysAbandonedWorkflow,
          }
        }));
    final data = res.data;
    if (data is! Map) return [];
    return data.entries
        .where((e) => e.value is Map)
        .map((e) => AuditReport.fromJson(
            e.key.toString(), Map<String, dynamic>.from(e.value as Map)))
        .toList();
  }

  // ── Source control ────────────────────────────────────────────────────────

  Future<String> pullSourceControl({bool force = false}) async {
    if (isDemo) {
      return _delay('Pulled 3 workflows, 2 credentials stubs and 4 variables '
          'from branch "main" (demo).');
    }
    final res = await _call(
        () => _dio.post('/api/v1/source-control/pull', data: {'force': force}));
    final data = res.data;
    if (data is Map && data.isNotEmpty) {
      final parts = <String>[];
      data.forEach((k, v) {
        if (v is List) parts.add('${v.length} $k');
      });
      if (parts.isNotEmpty) return 'Pulled ${parts.join(', ')}.';
    }
    return 'Pull completed.';
  }

  // ── Server health ─────────────────────────────────────────────────────────

  Future<ServerHealth> checkHealth() async {
    if (isDemo) {
      return _delay(const ServerHealth(
        reachable: true,
        healthy: true,
        apiOk: true,
        latencyMs: 84,
        workflowCount: 5,
        message: 'Demo server is healthy',
      ));
    }
    final base = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final sw = Stopwatch()..start();
    bool reachable = false;
    bool healthy = false;
    bool apiOk = false;
    int? workflowCount;
    String message = '';
    try {
      final plain = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          validateStatus: (_) => true));
      final res = await plain.get('$base/healthz');
      reachable = true;
      healthy = res.statusCode == 200;
      if (!healthy) message = 'Health endpoint returned ${res.statusCode}';
    } catch (e) {
      message = 'Server not reachable';
    }
    final latency = sw.elapsedMilliseconds;
    if (reachable) {
      try {
        final res = await _dio
            .get('/api/v1/workflows', queryParameters: {'limit': 250});
        apiOk = true;
        workflowCount = _list(res.data).length;
      } on DioException catch (e) {
        message = e.response?.statusCode == 401
            ? 'API key rejected (401)'
            : 'API error: ${e.response?.statusCode ?? e.type.name}';
      }
    }
    if (message.isEmpty) message = 'All systems operational';
    return ServerHealth(
      reachable: reachable,
      healthy: healthy,
      apiOk: apiOk,
      latencyMs: latency,
      workflowCount: workflowCount,
      message: message,
    );
  }

  // ── Workflows ─────────────────────────────────────────────────────────────

  /// Full workflow JSON as stored on the server (for export / duplicate).
  Future<Map<String, dynamic>> getWorkflowJson(String id) async {
    if (isDemo) return _delay(_demo.workflowJson(id));
    final res = await _call(() => _dio.get('/api/v1/workflows/$id'));
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Creates a workflow from exported n8n JSON. Only the fields the public
  /// API accepts are sent. Returns the new workflow id.
  Future<String> createWorkflowFromJson(Map<String, dynamic> json,
      {String? nameOverride}) async {
    final payload = <String, dynamic>{
      'name': nameOverride ?? json['name'] ?? 'Imported workflow',
      'nodes': json['nodes'] ?? [],
      'connections': json['connections'] ?? <String, dynamic>{},
      'settings': _cleanSettings(json['settings']),
    };
    if (isDemo) return _delay('demo-${DateTime.now().millisecondsSinceEpoch}');
    final res =
        await _call(() => _dio.post('/api/v1/workflows', data: payload));
    return (res.data as Map)['id'].toString();
  }

  Future<String> duplicateWorkflow(String id, String newName) async {
    final json = await getWorkflowJson(id);
    return createWorkflowFromJson(json, nameOverride: newName);
  }

  Future<void> deleteWorkflow(String id) async {
    if (isDemo) return _delay(null);
    await _call(() => _dio.delete('/api/v1/workflows/$id'));
  }

  Future<void> setWorkflowTags(String id, List<String> tagIds) async {
    if (isDemo) return _delay(null);
    await _call(() => _dio.put('/api/v1/workflows/$id/tags',
        data: tagIds.map((t) => {'id': t}).toList()));
  }

  Future<void> transferWorkflow(String id, String projectId) async {
    if (isDemo) return _delay(null);
    await _call(() => _dio.put('/api/v1/workflows/$id/transfer',
        data: {'destinationProjectId': projectId}));
  }

  /// The public API has no "run" endpoint, so remote runs go through the
  /// workflow's production webhook. Returns a human readable result.
  Future<String> triggerViaWebhook(Map<String, dynamic> workflowJson) async {
    final nodes = (workflowJson['nodes'] as List?) ?? const [];
    final hook = nodes.cast<dynamic>().firstWhere(
          (n) => n is Map && n['type'] == 'n8n-nodes-base.webhook',
          orElse: () => null,
        );
    if (hook == null) {
      throw Exception('This workflow has no Webhook trigger. n8n\'s public '
          'API can only start workflows through a webhook.');
    }
    if (isDemo) return _delay('Webhook called - HTTP 200 (demo)');
    if (workflowJson['active'] != true) {
      throw Exception('Activate the workflow first - production webhooks '
          'only listen while the workflow is active.');
    }
    final params =
        Map<String, dynamic>.from((hook['parameters'] as Map?) ?? {});
    final path = (params['path'] ?? hook['webhookId'] ?? '').toString();
    final method = (params['httpMethod'] ?? 'GET').toString().toUpperCase();
    final base = _dio.options.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final plain = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (_) => true));
    final res = await plain.request('$base/webhook/$path',
        data: method == 'GET' ? null : {'source': 'n8n Manager app'},
        options: Options(method: method));
    if ((res.statusCode ?? 500) >= 400) {
      throw Exception('Webhook returned HTTP ${res.statusCode}');
    }
    return 'Webhook called - HTTP ${res.statusCode}';
  }

  // ── Executions ────────────────────────────────────────────────────────────

  Future<void> deleteExecution(String id) async {
    if (isDemo) return _delay(null);
    await _call(() => _dio.delete('/api/v1/executions/$id'));
  }

  /// Retries a failed execution. Returns the new execution id when known.
  Future<String?> retryExecution(String id) async {
    if (isDemo) return _delay('demo-retry-$id');
    final res = await _call(() => _dio
        .post('/api/v1/executions/$id/retry', data: {'loadWorkflow': true}));
    final data = res.data;
    return data is Map ? data['id']?.toString() : null;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Map<String, dynamic> _cleanSettings(dynamic settings) {
    const allowed = {
      'saveExecutionProgress',
      'saveManualExecutions',
      'saveDataErrorExecution',
      'saveDataSuccessExecution',
      'executionTimeout',
      'errorWorkflow',
      'timezone',
      'executionOrder',
    };
    if (settings is! Map) return {'executionOrder': 'v1'};
    return Map<String, dynamic>.fromEntries(settings.entries
        .where((e) => allowed.contains(e.key))
        .map((e) => MapEntry(e.key.toString(), e.value)));
  }

  static String prettyJson(Object json) =>
      const JsonEncoder.withIndent('  ').convert(json);

  List<Map<String, dynamic>> _list(dynamic data) {
    final raw = data is Map ? data['data'] : data;
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<T> _delay<T>(T value,
      [Duration d = const Duration(milliseconds: 450)]) async {
    await Future.delayed(d);
    return value;
  }

  Future<Response> _call(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ToolsException.fromDio(e);
    }
  }
}

/// Error with a friendly message, including n8n licence / version hints.
class ToolsException implements Exception {
  final String message;
  final bool needsLicense;
  const ToolsException(this.message, {this.needsLicense = false});

  factory ToolsException.fromDio(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMsg = body is Map ? (body['message'] ?? '').toString() : '';
    if (status == 403 && serverMsg.toLowerCase().contains('license')) {
      return ToolsException(
          'This feature needs an n8n Enterprise licence on your server.\n'
          '($serverMsg)',
          needsLicense: true);
    }
    switch (status) {
      case 400:
        return ToolsException(serverMsg.isNotEmpty
            ? serverMsg
            : 'The server rejected the request (400).');
      case 401:
        return const ToolsException(
            'Invalid API key. Create a new key in n8n > Settings > n8n API.');
      case 403:
        return ToolsException(serverMsg.isNotEmpty
            ? serverMsg
            : 'Your API key is not allowed to do this (403).');
      case 404:
        return ToolsException(serverMsg.isNotEmpty
            ? serverMsg
            : 'Not found. Your n8n version may not support this endpoint '
                '- update n8n to the latest release.');
      case 409:
        return ToolsException(
            serverMsg.isNotEmpty ? serverMsg : 'Already exists (409).');
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const ToolsException(
          'Cannot reach the server. Check the URL and your connection.');
    }
    return ToolsException(serverMsg.isNotEmpty
        ? serverMsg
        : 'Server error (${status ?? e.type.name}).');
  }

  @override
  String toString() => message;
}
