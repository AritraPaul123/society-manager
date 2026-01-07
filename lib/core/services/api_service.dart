import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:society_man/core/models/auth_models.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.29.93:5001/api/v1';
    }
    return 'http://localhost:5001/api/v1';
  }

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print(
      'DEBUG: Retrieved token: ${token != null ? "EXISTS (${token.substring(0, 20)}...)" : "NULL - NOT LOGGED IN!"}',
    );
    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('DEBUG: Saved token: ${token.substring(0, 20)}...');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('DEBUG: Headers being sent: ${headers.keys.toList()}');
    return headers;
  }

  Future<bool> login(String username, String password) async {
    try {
      print('=== LOGIN DEBUG ===');
      print('URL: $baseUrl/auth/authenticate');
      print('Username: $username');
      print('Password: ${password.substring(0, 2)}***');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/authenticate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'platform': 'mobile',
        }),
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded data: $data');
        print('Success field: ${data['success']}');

        if (data['success'] == true) {
          // The backend uses 'data' field for the payload
          final token = data['data']['token'];
          print('Token extracted: ${token.substring(0, 20)}...');
          await saveToken(token);
          print('Token saved successfully!');
          print('=== LOGIN SUCCESS ===');
          return true;
        } else {
          print('Login failed: success field is not true');
        }
      }
      print('Login failed: ${response.statusCode} ${response.body}');
      print('=== LOGIN FAILED ===');
      return false;
    } catch (e, stackTrace) {
      print('Login error: $e');
      print('Stack trace: $stackTrace');
      print('=== LOGIN ERROR ===');
      return false;
    }
  }

  // Attendance Endpoints
  Future<Map<String, dynamic>> checkIn(AttendanceRecord record) async {
    try {
      final headers = await _getHeaders();
      final requestBody = jsonEncode(record.toJson());

      print('=== CHECK-IN DEBUG ===');
      print('URL: $baseUrl/attendance/check-in');
      print('Headers: $headers');
      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-in'),
        headers: headers,
        body: requestBody,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('=== END DEBUG ===');

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Check-in successful'};
      } else {
        // Try to parse error message from response
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? errorData['error'] ?? 'Unknown error';
          return {
            'success': false,
            'message': 'Server error (${response.statusCode}): $errorMessage',
          };
        } catch (e) {
          return {
            'success': false,
            'message':
                'Server error (${response.statusCode}): ${response.body}',
          };
        }
      }
    } catch (e) {
      print('CheckIn error: $e');
      print('Error stack trace: ${StackTrace.current}');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<bool> checkOut(String guardId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/attendance/check-out?guardId=$guardId'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('CheckOut error: $e');
      return false;
    }
  }

  Future<AttendanceRecord?> getAttendanceStatus(String guardId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/attendance/status?guardId=$guardId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return AttendanceRecord.fromJson(data['data']);
        }
      }
      return null;
    } catch (e) {
      print('GetStatus error: $e');
      return null;
    }
  }

  // Visitor Endpoints
  Future<List<VisitorEntry>> getActiveVisitors() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/visitor/active'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List list = data['data'];
          return list.map((e) => VisitorEntry.fromMap(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('GetActiveVisitors error: $e');
      return [];
    }
  }

  Future<bool> createVisitorEntry(VisitorEntry entry) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/visitor/entry'),
        headers: headers,
        body: jsonEncode(entry.toMap()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('CreateVisitor error: $e');
      return false;
    }
  }

  Future<bool> updateVisitorExit(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/visitor/exit/$id'),
        headers: headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('UpdateExit error: $e');
      return false;
    }
  }

  Future<List<VisitorEntry>> getVisitorHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/visitor/history'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List list = data['data'];
          return list.map((e) => VisitorEntry.fromMap(e)).toList();
        }
      }
      return [];
    } catch (e) {
      print('GetHistory error: $e');
      return [];
    }
  }

  // Helpdesk Endpoints
  Future<bool> createHelpdeskTicket(Map<String, dynamic> ticketData) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/helpdesk/tickets'),
        headers: headers,
        body: jsonEncode(ticketData),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('CreateTicket error: $e');
      return false;
    }
  }
}
