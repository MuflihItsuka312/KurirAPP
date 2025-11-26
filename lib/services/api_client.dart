// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // emulator Android -> backend di host: 10.0.2.2:3000
  static const String baseUrl = 'http://10.87.40.24:3000';

  static Future<http.Response> post(String path, Map<String, dynamic> body) {
    final uri = Uri.parse('$baseUrl$path');
    return http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String path,
      {Map<String, dynamic>? query}) {
    var uri = Uri.parse('$baseUrl$path');
    if (query != null) {
      uri = uri.replace(queryParameters: query);
    }
    return http.get(uri);
  }
}
