import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  AuthService._(this.dio, this.secureStorage);

  factory AuthService({String? baseUrl}) {
    final dio = Dio(BaseOptions(baseUrl: baseUrl ?? ''));
    final storage = const FlutterSecureStorage();
    return AuthService._(dio, storage);
  }

  void updateBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  Future<void> saveCredentials(
    String instanceUrl,
    String apiKey, {
    bool isDemo = false,
  }) async {
    // Normalize instance URL for storage keys (strip trailing slash)

    final norm = _normalizeInstanceUrl(instanceUrl);
    // Store per-instance API key and also keep the legacy single-instance keys
    await secureStorage.write(key: 'apiKey:$norm', value: apiKey);
    await secureStorage.write(key: 'instanceUrl', value: norm);
    await secureStorage.write(key: 'apiKey', value: apiKey);
    await secureStorage.write(key: 'isDemo', value: isDemo ? 'true' : 'false');
    dio.options.baseUrl = instanceUrl;
    dio.options.headers['X-N8N-API-KEY'] = '$apiKey';
  }

  Future<String?> readApiKeyFor(String instanceUrl) async {
    final norm = _normalizeInstanceUrl(instanceUrl);
    return await secureStorage.read(key: 'apiKey:$norm');
  }

  Future<void> deleteCredentialsFor(String instanceUrl) async {
    final norm = _normalizeInstanceUrl(instanceUrl);
    await secureStorage.delete(key: 'apiKey:$norm');
    // If the legacy keys point to this instance, remove them as well
    final currentInstance = await secureStorage.read(key: 'instanceUrl');
    if (currentInstance == norm) {
      await secureStorage.delete(key: 'instanceUrl');
      await secureStorage.delete(key: 'apiKey');
      dio.options.baseUrl = '';
      dio.options.headers.remove('X-N8N-API-KEY');
    }
  }

  /// Apply stored credentials for a given instance URL to the Dio client.
  /// Throws if no credentials found for the instance.
  Future<void> applySavedCredentials(String instanceUrl) async {
    final norm = _normalizeInstanceUrl(instanceUrl);
    final apiKey = await readApiKeyFor(norm);
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('No saved API key for $instanceUrl');
    }
    dio.options.baseUrl = instanceUrl;
    dio.options.headers['X-N8N-API-KEY'] = apiKey;
    // Also write legacy keys for compatibility (store normalized)
    await secureStorage.write(key: 'instanceUrl', value: norm);
    await secureStorage.write(key: 'apiKey', value: apiKey);
  }

  String _normalizeInstanceUrl(String url) {
    if (url.endsWith('/')) return url.substring(0, url.length - 1);
    return url;
  }

  Future<void> clearCredentials() async {
    await secureStorage.delete(key: 'instanceUrl');
    await secureStorage.delete(key: 'apiKey');
    await secureStorage.delete(key: 'isDemo');
    dio.options.baseUrl = '';
    dio.options.headers.remove('X-N8N-API-KEY');
  }

  Future<bool> isDemoAccount() async {
    final flag = await secureStorage.read(key: 'isDemo');
    return flag == 'true';
  }

  /// Load saved credentials from secure storage and apply them to Dio options.
  Future<void> loadSavedCredentials() async {
    final instanceUrl = await secureStorage.read(key: 'instanceUrl');
    final apiKey = await secureStorage.read(key: 'apiKey');
    if (instanceUrl != null && instanceUrl.isNotEmpty) {
      dio.options.baseUrl = instanceUrl;
    }
    if (apiKey != null && apiKey.isNotEmpty) {
      dio.options.headers['X-N8N-API-KEY'] = apiKey;
    }
  }

  Future<Response> testAuth() async {
    // print('Testing authentication... ${dio.options.headers['X-N8N-API-KEY']} ${dio.options.baseUrl}');
    return dio.get('/api/v1/workflows?active=true');
  }
}
