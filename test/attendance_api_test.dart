import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test 1: Login
  print('=== TEST 1: Login ===');
  final loginResponse = await http.post(
    Uri.parse('http://10.0.2.2:5001/api/v1/auth/authenticate'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': 'guard@society.com',
      'password': '1234',
      'platform': 'mobile',
    }),
  );

  print('Login Status: ${loginResponse.statusCode}');
  print('Login Response: ${loginResponse.body}');

  if (loginResponse.statusCode == 200) {
    final loginData = jsonDecode(loginResponse.body);
    final token = loginData['data']['token'];
    print('Token: $token');

    // Test 2: Check-In
    print('\n=== TEST 2: Check-In ===');
    final checkInResponse = await http.post(
      Uri.parse('http://10.0.2.2:5001/api/v1/attendance/check-in'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'guardId': 'GUARD001',
        'staffId': 'guard@society.com',
        'guardName': 'Test Guard',
        'location': '25.276987, 55.296249',
        'checkInFaceImagePath': '/path/to/face.jpg',
      }),
    );

    print('Check-In Status: ${checkInResponse.statusCode}');
    print('Check-In Response: ${checkInResponse.body}');

    // Test 3: Get Status
    print('\n=== TEST 3: Get Status ===');
    final statusResponse = await http.get(
      Uri.parse(
        'http://10.0.2.2:5001/api/v1/attendance/status?guardId=GUARD001',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('Status Check: ${statusResponse.statusCode}');
    print('Status Response: ${statusResponse.body}');
  }
}
