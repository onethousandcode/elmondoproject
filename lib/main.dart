import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Attempt refresh only if a token exists
  Future<bool> _checkAndRefreshToken() async {
    final api = ApiService();
    final token = await api.getAccessToken();

    if (token == null) {
      // No token stored → user must login
      return false;
    }

    // Attempt refresh using stored token
    final refreshed = await api.refreshToken();
    print("App start token refresh: ${refreshed ? 'Success' : 'Failed'}");
    return refreshed;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: _checkAndRefreshToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If refresh succeeded and token valid, go to home
          if (snapshot.hasData && snapshot.data == true) {
            return HomeScreen();
          }

          // Otherwise, show login screen
          return LoginScreen();
        },
      ),
    );
  }
}
