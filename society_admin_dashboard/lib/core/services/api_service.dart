import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use localhost for Web
  static const String baseUrl = 'http://localhost:5001/api/v1';

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'platform': 'WEB',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['payload'] != null) {
          final token = data['payload']['token'];
          if (token != null) {
            await saveToken(token);
            return true;
          }
        }
      }
      print('Login failed: ${response.body}');
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<List<dynamic>?> getActiveVisitors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/visitors/active'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['payload'] as List<dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching visitors: $e');
    }
    return null;
  }

  Future<List<dynamic>?> getVisitorHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/visitors/history'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['payload'] as List<dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching visitor history: $e');
    }
    return null;
  }

  Future<List<dynamic>?> getAllAttendance() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/all'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['payload'] as List<dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching attendance: $e');
    }
    return null;
  }

  Future<List<dynamic>?> getAllPatrols() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/patrols/all'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['payload'] as List<dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching patrols: $e');
    }
    return null;
  }

  Future<List<dynamic>?> getAllComplaints(int societyId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/complaints/all-complaint/$societyId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['payload'] as List<dynamic>;
        }
      }
    } catch (e) {
      print('Error fetching complaints: $e');
    }
    return null;
  }
}
