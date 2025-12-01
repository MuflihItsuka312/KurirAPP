// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // emulator Android -> backend di host: 10.0.2.2:3000
  static const String baseUrl = 'https://serverr.shidou.cloud';

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

  // Register Courier
  static Future<Map<String, dynamic>> registerCourier({
    required String name,
    required String company,
    required String plate,
    required String password,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/courier/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'company': company,
        'plate': plate,
        'password': password,
        if (phone != null) 'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  }

  // Login Courier - Use NAME + password
  static Future<Map<String, dynamic>> loginCourier({
    required String name,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/courier/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  // Get Courier Profile
  static Future<Map<String, dynamic>> getCourierProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/courier/profile'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // Update Profile
  static Future<void> updateCourierProfile({
    required String token,
    String? name,
    String? phone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/courier/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  // Change Password
  static Future<void> changeCourierPassword({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/courier/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to change password');
    }
  }
}
