import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();

  // Login controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Signup controllers
  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();

  bool loading = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Refresh to update IndexedStack
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupNameController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    super.dispose();
  }

  // --- Login ---
  void _login() async {
    setState(() => loading = true);
    try {
      bool success = await api.login(
        loginEmailController.text.trim(),
        loginPasswordController.text.trim(),
      );
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Login successful!")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Invalid credentials")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  // --- Signup ---
  void _signup() async {
    setState(() => loading = true);
    try {
      bool success = await api.register(
        signupNameController.text.trim(),
        signupEmailController.text.trim(),
        signupPasswordController.text.trim(),
      );
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Signup successful!")));
        _tabController.index = 0; // Switch back to login
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Signup failed")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Signup error: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  Widget loginForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: loginEmailController,
          decoration: InputDecoration(labelText: "Email"),
        ),
        SizedBox(height: 12),
        TextField(
          controller: loginPasswordController,
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
        ),
        SizedBox(height: 24),
        ElevatedButton(onPressed: _login, child: Text("Login")),
      ],
    );
  }

  Widget signupForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: signupNameController,
          decoration: InputDecoration(labelText: "Name"),
        ),
        SizedBox(height: 12),
        TextField(
          controller: signupEmailController,
          decoration: InputDecoration(labelText: "Email"),
        ),
        SizedBox(height: 12),
        TextField(
          controller: signupPasswordController,
          decoration: InputDecoration(labelText: "Password"),
          obscureText: true,
        ),
        SizedBox(height: 24),
        ElevatedButton(onPressed: _signup, child: Text("Sign Up")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left branding/details panel with logo
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blueGrey.shade50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / image
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Image.asset(
                      'assets/logo.png', // <-- replace with your logo path
                      width: 150,
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Welcome to Elmondo Incorporated",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey.shade800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Jumpstart your learning journey with us!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade600),
                  ),
                ],
              ),
            ),
          ),

          // Right login/signup panel
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: loading
                    ? CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tabs
                          TabBar(
                            controller: _tabController,
                            tabs: [
                              Tab(text: "Login"),
                              Tab(text: "Sign Up"),
                            ],
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          // Forms
                          IndexedStack(
                            index: _tabController.index,
                            children: [
                              loginForm(),
                              signupForm(),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
