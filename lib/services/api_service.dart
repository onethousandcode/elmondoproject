import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://172.18.112.1:4000';
  static const String loginUrl = '$baseUrl/auth/login';

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // LOGIN: store access_token and refresh_token
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'password': password.trim(),
        }),
      );

      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'] ?? accessToken;

        if (accessToken == null) {
          print("No access_token found in response");
          return false;
        }

        await storage.write(key: 'access_token', value: accessToken);
        await storage.write(key: 'refresh_token', value: refreshToken);
        return true;
      } else {
        print("Login failed with status ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  // REFRESH using refresh token
  Future<bool> refreshToken() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': refreshToken}),
      );

      print("Refresh response status: ${response.statusCode}");
      print("Refresh response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        if (newAccessToken != null) {
          await storage.write(key: 'access_token', value: newAccessToken);
          print("Token successfully refreshed");
          return true;
        } else {
          print("No new access_token in refresh response");
        }
      } else {
        print("Refresh failed with status ${response.statusCode}");
      }
    } catch (e) {
      print("Refresh token error: $e");
    }
    return false;
  }

  // ACCESS TOKEN HELPERS
  Future<String?> getAccessToken() async => await storage.read(key: 'access_token');
  Future<String?> getRefreshToken() async => await storage.read(key: 'refresh_token');

  // LOGOUT
  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  // DECODE ACCESS TOKEN
  Future<Map<String, dynamic>?> decodeAccessToken() async {
    final token = await getAccessToken();
    if (token == null) return null;

    try {
      final payloadBase64 = token.split('.')[1];
      final normalized = base64Url.normalize(payloadBase64);
      final payloadString = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(payloadString) as Map<String, dynamic>;
    } catch (e) {
      print("Failed to decode access token: $e");
      return null;
    }
  }

  // Add this inside your ApiService class

// REGISTER / CREATE USER
Future<bool> register(String name, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password.trim(),
      }),
    );

    print("Register response status: ${response.statusCode}");
    print("Register response body: ${response.body}");

    // Consider 201 as success
    if (response.statusCode == 201) {
      return true;
    } else {
      print("Registration failed with status ${response.statusCode}");
      return false;
    }
  } catch (e) {
    print("Registration error: $e");
    return false;
  }
}


  // EXAMPLE API CALLS
  Future<List<dynamic>> fetchCourses() async {
    final token = await getAccessToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.get(
      Uri.parse('$baseUrl/courses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception(response.body);
  }

  Future<List<dynamic>> fetchLessons(String courseId) async {
    final token = await getAccessToken();
    if (token == null) throw Exception('No access token found');

    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId/lessons'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) return jsonDecode(response.body);
    throw Exception(response.body);
  }
}
