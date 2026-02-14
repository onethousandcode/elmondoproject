import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService api = ApiService();
  String? email;

  Timer? _logoutTimer;
  Timer? _warningTimer;
  Timer? _countdownTimer;

  int? _secondsLeft;
  DateTime? _lastRefreshed;

  // Debug info
  String? lastRequestBody;
  String? lastRequestUrl;
  String? lastResponse;

  static const int nearExpiryThreshold = 30; // seconds before expiry to allow refresh

  @override
  void initState() {
    super.initState();
    _initTokenState();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  void _cancelTimers() {
    _logoutTimer?.cancel();
    _warningTimer?.cancel();
    _countdownTimer?.cancel();
  }

  /// Initialize token info and setup timers
  Future<void> _initTokenState() async {
    final payload = await api.decodeAccessToken();
    if (payload == null) return _logout();

    if (!mounted) return;
    setState(() => email = payload['email']);

    final expSeconds = payload['exp'] as int;
    final currentSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int secondsUntilExpiry = expSeconds - currentSeconds;

    if (secondsUntilExpiry <= 0) return _logout();

    _setupTimers(secondsUntilExpiry);
  }

  void _setupTimers(int secondsUntilExpiry) {
    _cancelTimers();
    setState(() => _secondsLeft = secondsUntilExpiry);

    // Countdown timer
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft != null) {
          _secondsLeft = _secondsLeft! - 1;
          if (_secondsLeft! <= 0) timer.cancel();
        }
      });
    });

    // Logout timer
    _logoutTimer = Timer(Duration(seconds: secondsUntilExpiry), _logout);

    // Warning timer
    if (secondsUntilExpiry > nearExpiryThreshold) {
      _warningTimer =
          Timer(Duration(seconds: secondsUntilExpiry - nearExpiryThreshold), () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Your session will expire in $nearExpiryThreshold seconds."),
            duration: Duration(seconds: 5),
          ),
        );
      });
    }
  }

  /// Refresh token manually (user action only)
  Future<void> _manualRefresh() async {
    final token = await api.getAccessToken();
    if (token == null) return _logout();

    // Debug
    setState(() {
      lastRequestUrl = '${ApiService.baseUrl}/auth/refresh';
      lastRequestBody = jsonEncode({'token': token});
    });

    final refreshed = await api.refreshToken();

    setState(() {
      lastResponse = refreshed ? '200 OK: Token refreshed' : '401 Unauthorized';
    });

    if (refreshed) {
      if (!mounted) return;
      setState(() => _lastRefreshed = DateTime.now());
      await _initTokenState();
    } else {
      _logout();
    }
  }

  void _logout() async {
    await api.logout();
    if (!mounted) return;

    _cancelTimers();
    ScaffoldMessenger.of(context).clearSnackBars();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Only trigger refresh manually if user clicks
      onTap: () {
        _manualRefreshIfNearExpiry();
      },
      onPanDown: (_) {
        _manualRefreshIfNearExpiry();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: _logout,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              email != null
                  ? Text("Welcome, $email!", style: TextStyle(fontSize: 18))
                  : CircularProgressIndicator(),
              SizedBox(height: 24),
              _secondsLeft != null
                  ? Text("Token expires in: $_secondsLeft seconds",
                      style: TextStyle(fontSize: 16, color: Colors.red))
                  : SizedBox.shrink(),
              SizedBox(height: 12),
              _lastRefreshed != null
                  ? Text(
                      "Token last refreshed: ${_lastRefreshed!.toLocal().toIso8601String()}",
                      style: TextStyle(fontSize: 14, color: Colors.green))
                  : Text("Token not refreshed yet",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 16),
              Divider(height: 32),
              Text("DEBUG INFO:", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Request URL: ${lastRequestUrl ?? 'N/A'}",
                  style: TextStyle(fontSize: 12)),
              Text("Request Body: ${lastRequestBody ?? 'N/A'}",
                  style: TextStyle(fontSize: 12)),
              Text("Response: ${lastResponse ?? 'N/A'}",
                  style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  /// Refresh token if near expiry (user activity)
  void _manualRefreshIfNearExpiry() {
    if (_secondsLeft != null && _secondsLeft! <= nearExpiryThreshold) {
      _manualRefresh();
    }
  }
}
