import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/student_intent.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  const ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client;
  final String baseUrl;
  String? token;
  VoidCallback? onUnauthorized;

  ApiClient({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = (baseUrl ?? defaultBaseUrl()).replaceFirst(RegExp(r'/+$'), '');

  static String defaultBaseUrl() {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (kIsWeb) {
      return Uri.base.replace(port: 3000, path: '/api', query: '', fragment: '').toString();
    }
    // An APK may run on a real phone or an emulator. Neither loopback nor the
    // emulator's 10.0.2.2 is a valid universal backend address.
    return '';
  }

  Future<Map<String, dynamic>> send(String method, String path,
      {Map<String, dynamic>? body, bool authenticated = true}) async {
    if (baseUrl.isEmpty) {
      throw const ApiException('Chưa cấu hình API_BASE_URL. Hãy build APK với địa chỉ HTTPS hoặc IP LAN của backend.');
    }
    final uri = Uri.tryParse('$baseUrl$path');
    if (uri == null || !uri.hasAuthority || !['http', 'https'].contains(uri.scheme)) {
      throw const ApiException('API_BASE_URL không hợp lệ.');
    }
    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    final requestToken = token;
    if (authenticated) {
      if (token == null) throw const ApiException('Vui lòng đăng nhập.', 401);
      request.headers['Authorization'] = 'Bearer $token';
    }
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }
    late http.Response response;
    try {
      response = await (() async => http.Response.fromStream(await _client.send(request)))()
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const ApiException('Máy chủ phản hồi chậm. Vui lòng thử lại.');
    } on http.ClientException {
      throw const ApiException('Không kết nối được máy chủ. Kiểm tra mạng và API_BASE_URL.');
    }
    final status = response.statusCode;
    if (status == 401 && authenticated && token == requestToken) onUnauthorized?.call();
    final contentType = response.headers['content-type']?.split(';').first.trim().toLowerCase();
    if (contentType != 'application/json') {
      throw ApiException('Máy chủ trả về dữ liệu không phải JSON (HTTP $status). Kiểm tra địa chỉ API.', status);
    }
    late Map<String, dynamic> data;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      data = decoded;
    } on FormatException {
      throw ApiException('Phản hồi JSON từ máy chủ không hợp lệ (HTTP $status).', status);
    }
    if (status < 200 || status >= 300 || data['success'] == false) {
      throw ApiException(data['message'] as String? ?? 'Yêu cầu thất bại (HTTP $status).', status);
    }
    return data;
  }

  Future<String> login(String email, String password) async {
    final data = await send('POST', '/auth/login', authenticated: false,
        body: {'email': email, 'password': password});
    final value = data['token'];
    if (value is! String || value.isEmpty) throw const ApiException('Thiếu phiên đăng nhập từ máy chủ.');
    return value;
  }

  Future<Map<String, dynamic>> profile() async =>
      Map<String, dynamic>.from((await send('GET', '/auth/profile'))['user'] as Map);

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> fields) async {
    await send('PUT', '/auth/profile', body: fields);
    return profile(); // Read the committed database state after saving.
  }

  Future<List<StudentIntent>> requests({bool mine = false}) async {
    final data = await send('GET', mine ? '/requests/mine' : '/requests');
    return (data['requests'] as List)
        .map((item) => StudentIntent.fromJson(Map<String, dynamic>.from(item as Map))).toList();
  }

  Future<StudentIntent> publish(Map<String, dynamic> fields) async =>
      StudentIntent.fromJson(Map<String, dynamic>.from(
          (await send('POST', '/requests', body: fields))['request'] as Map));

  void close() => _client.close();
}

String newRequestId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
