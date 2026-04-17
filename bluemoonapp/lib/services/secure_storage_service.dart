import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _key = 'jwt_token';
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _key, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _key);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _key);
  }
}