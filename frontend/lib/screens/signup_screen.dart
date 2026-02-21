import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _message = '';
  bool _loading   = false;

  Future<void> _signup() async {
    setState(() { _loading = true; _message = ''; });

    // Step 1: Register
    final res = await ApiService.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    // Success check: backend returns {name, email, created_at}
    if (!res.containsKey('name')) {
      setState(() {
        _message = res['detail'] ?? res['error'] ?? 'Signup failed';
        _loading = false;
      });
      return;
    }

    // Step 2: Auto-login
    final loginRes = await ApiService.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (!loginRes.containsKey('access_token')) {
      setState(() {
        _message = loginRes['detail'] ?? loginRes['error'] ?? 'Login after signup failed';
        _loading = false;
      });
      return;
    }

    final token   = loginRes['access_token'] as String;
    final payload = JwtDecoder.decode(token);   // ← decode JWT properly
    final userId  = payload['sub'] as String? ?? '';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(userId: userId, token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C42),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Create Account',
                  style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800,
                    color: Color(0xFFFFE0B2)),
                ),
              ),
              const SizedBox(height: 4),
              const Center(
                child: Text('Sign up to get started',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),

              const SizedBox(height: 36),

              TextField(
                controller: _nameCtrl,
                decoration: _inputDeco('Full Name', Icons.person_outline),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDeco('Email', Icons.email_outlined),
              ),
              const SizedBox(height: 16),

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

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFfb542b),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _signup,
                  child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                    : const Text('Sign Up',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF9F1C))),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen())),
                    child: const Text('Login',
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