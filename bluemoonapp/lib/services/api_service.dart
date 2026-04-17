import 'dart:convert';
import 'package:bluemoonapp/constants/api_constants.dart';
import 'package:bluemoonapp/services/secure_storage_service.dart';
import 'package:bluemoonapp/utils/api_host.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _client = http.Client();
  final _storage = SecureStorageService();

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};

    if (auth) {
      final token = await _storage.readToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Uri _uri(String path) {
    return Uri.parse('${getApiHost()}$path');
  }

  Future<http.Response> get(String path, {bool auth = false}) async {
    final res = await _client.get(
      _uri(path),
      headers: await _headers(auth: auth),
    );

    print('GET ${_uri(path)} => ${res.statusCode}');
    return res;
  }

  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    try {
      final res = await _client.post(
        _uri(path),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      );

      print('POST URL: ${_uri(path)}');
      print('STATUS: ${res.statusCode}');
      print('BODY: ${res.body}');

      return res;
    } catch (e) {
      print('POST ERROR: $e');
      rethrow;
    }
  }

  Future<http.Response> delete(String path, {bool auth = false}) async {
    final res = await _client.delete(
      _uri(path),
      headers: await _headers(auth: auth),
    );

    print('DELETE ${_uri(path)} => ${res.statusCode}');
    return res;
  }

  Future<http.Response> put(
  String path, {
  Map<String, dynamic>? body,
  bool auth = true,
}) async {
  final res = await _client.put(
    _uri(path), 
    headers: await _headers(auth: auth),
    body: jsonEncode(body),
  );

  print('PUT ${_uri(path)} => ${res.statusCode}');
  print('BODY: ${res.body}');

  return res;
}
}
