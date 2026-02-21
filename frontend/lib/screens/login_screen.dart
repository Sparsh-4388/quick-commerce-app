import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _message = '';
  bool _loading   = false;

  Future<void> _login() async {
    setState(() { _loading = true; _message = ''; });

    final res = await ApiService.login(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;

    if (res.containsKey('access_token')) {
      final token = res['access_token'] as String;
      final payload = JwtDecoder.decode(token);           // ← jwt_decoder
      final userId  = payload['sub'] as String? ?? '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: userId, token: token),
        ),
      );
    } else {
      setState(() {
        _message = res['detail'] ?? res['error'] ?? 'Login failed';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),

              // Logo / Brand
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C831F),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('blinkit',
                  style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w800,
                    color: Color(0xFF0C831F), letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('Grocery in minutes',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),

              const SizedBox(height: 48),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: _inputDeco('Password', Icons.lock_outline),
              ),
              const SizedBox(height: 8),

              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_message,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
                ),

              const SizedBox(height: 8),

              // Login button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C831F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _login,
                  child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                    : const Text('Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SignupScreen())),
                    child: const Text('Sign Up',
                      style: TextStyle(
                        color: Color(0xFF0C831F), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.grey),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0C831F), width: 2),
    ),
    filled: true,
    fillColor: Colors.grey.shade50,
  );
}