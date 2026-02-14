import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService api = ApiService();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String responseText = '';
  String requestBody = '';
  bool loading = false;

  void _testLogin() async {
    setState(() {
      loading = true;
      responseText = '';
      requestBody = '';
    });

    final body = jsonEncode({
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    });

    setState(() {
      requestBody = "Request Body:\n$body";
    });

    try {
      final uri = Uri.parse(ApiService.loginUrl);

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      String formattedBody;

      // Try to pretty print JSON
      try {
        final decoded = jsonDecode(response.body);
        const encoder = JsonEncoder.withIndent('  ');
        formattedBody = encoder.convert(decoded);

        // Save token if exists
        if (response.statusCode == 200 && decoded['accessToken'] != null) {
          await storage.write(
              key: 'jwt', value: decoded['accessToken'].toString());
        }
      } catch (_) {
        // If not JSON, just show raw
        formattedBody = response.body;
      }

      final fullResponse = """
Status Code: ${response.statusCode}

Response Body:
$formattedBody
""";

      setState(() {
        responseText = fullResponse;
      });
    } catch (e) {
      setState(() {
        responseText = "Request error:\n$e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("API Test Screen")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: loading ? null : _testLogin,
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text("Test Login API"),
            ),
            SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  "${requestBody.isNotEmpty ? requestBody + "\n\n" : ""}$responseText",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
