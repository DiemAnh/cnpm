import 'dart:convert';

import 'package:bluemoonapp/models/auth_request.dart';
import 'package:bluemoonapp/services/api_service.dart';
import 'package:bluemoonapp/services/secure_storage_service.dart';
import '../models/auth_response.dart';
import '../utils/api_host.dart';
import '../constants/api_constants.dart';

class AuthService {
  final _api = ApiService();
  final _storage = SecureStorageService();

 Future<String> login({
  required String name,
  required String password,
}) async {
  final response = await _api.post(
    ApiConstants.login,
    body: {
      "name": name,
      "password": password,
    },
  );

  if (response.statusCode == 200) {
    final token = response.body.replaceAll('"', '');

    await _storage.saveToken(token);

    return token;
  }

  throw Exception('Login failed: ${response.statusCode} ${response.body}');
}

}