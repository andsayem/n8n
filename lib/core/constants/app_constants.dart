class AppConstants {
  static const String appName = 'n8n Manager';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String instancesKey = 'n8n_instances';
  static const String activeInstanceKey = 'active_instance';
  static const String themeKey = 'app_theme';
  static const String apiKeyPrefix = 'api_key_';

  // API
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const String apiKeyHeader = 'X-N8N-API-KEY';

  // n8n API endpoints
  static const String workflowsEndpoint = '/api/v1/workflows';
  static const String executionsEndpoint = '/api/v1/executions';
  static const String activateEndpoint = '/activate';
  static const String deactivateEndpoint = '/deactivate';
  static const String runEndpoint = '/run';
  static const String credentialsEndpoint = '/api/v1/credentials';

  // Pagination
  static const int pageSize = 20;
}

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String addInstance = '/add-instance';
  static const String home = '/home';
  static const String workflowDetail = '/workflow-detail';
  static const String executionDetail = '/execution-detail';
  static const String settings = '/settings';
}
