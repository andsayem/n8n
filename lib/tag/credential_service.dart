// import 'package:dio/dio.dart';
// import '../models/n8n_credential_model.dart';
// import 'n8n_error_handler.dart';

// class N8nCredentialService {
//   final Dio _dio;

//   N8nCredentialService(this._dio);

//   /// GET /api/v1/credentials
//   Future<N8nCredentialList> getCredentials({
//     int limit = 100,
//     String? cursor,
//   }) async {
//     try {
//       final response = await _dio.get(
//         '/api/v1/credentials',
//         queryParameters: {
//           'limit': limit,
//           if (cursor != null) 'cursor': cursor,
//         },
//       );
//       return N8nCredentialList.fromJson(response.data as Map<String, dynamic>);
//     } on DioException catch (e) {
//       throw handleDioError(e);
//     }
//   }

//   /// সব page auto-fetch করে
//   Future<List<N8nCredential>> getAllCredentials() async {
//     final all = <N8nCredential>[];
//     String? cursor;
//     do {
//       final result = await getCredentials(limit: 100, cursor: cursor);
//       all.addAll(result.data);
//       cursor = result.nextCursor;
//     } while (cursor != null);
//     return all;
//   }

//   /// POST /api/v1/credentials
//   /// type examples: 'postgres', 'mysql', 'googleDriveOAuth2Api', 'slack'
//   Future<N8nCredential> createCredential({
//     required String name,
//     required String type,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       final response = await _dio.post(
//         '/api/v1/credentials',
//         data: CreateCredentialRequest(name: name, type: type, data: data)
//             .toJson(),
//       );
//       return N8nCredential.fromJson(response.data as Map<String, dynamic>);
//     } on DioException catch (e) {
//       throw handleDioError(e);
//     }
//   }

//   /// DELETE /api/v1/credentials/{id}
//   Future<void> deleteCredential(String id) async {
//     try {
//       await _dio.delete('/api/v1/credentials/$id');
//     } on DioException catch (e) {
//       throw handleDioError(e);
//     }
//   }

//   /// GET /api/v1/credentials/schema/{credentialTypeName}
//   /// কোনো credential type এর required fields জানতে
//   Future<Map<String, dynamic>> getCredentialSchema(
//       String credentialTypeName) async {
//     try {
//       final response =
//           await _dio.get('/api/v1/credentials/schema/$credentialTypeName');
//       return response.data as Map<String, dynamic>;
//     } on DioException catch (e) {
//       throw handleDioError(e);
//     }
//   }
// }
