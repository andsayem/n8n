import 'package:dio/dio.dart';

class UsersService {
  final Dio dio;

  UsersService(this.dio);

  Future<Response> fetchUsers() async {
    return dio.get('/api/v1/users', options: Options(validateStatus: (_) => true));
  }

  Future<Response> getUserById(String idOrEmail) async {
    return dio.get('/api/v1/users/$idOrEmail', options: Options(validateStatus: (_) => true));
  }

  Future<Response> createUsers(List<Map<String, dynamic>> users) async {
    return dio.post('/api/v1/users', data: users, options: Options(validateStatus: (_) => true));
  }

  Future<Response> deleteUser(String id) async {
    return dio.delete('/api/v1/users/$id', options: Options(validateStatus: (_) => true));
  }

  Future<Response> updateUserRole(String id, String role) async {
    return dio.patch('/api/v1/users/$id/role', data: {'role': role}, options: Options(validateStatus: (_) => true));
  }
}
