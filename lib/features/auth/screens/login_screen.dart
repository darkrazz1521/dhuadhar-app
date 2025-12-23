import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  // 🔐 REAL LOGIN (BACKEND CONNECTED)
  void _login() async {
  setState(() => _loading = true);

  // 🔥 FORCE CLEAR OLD SESSION
  await AuthService.logout();

  final success = await AuthService.login(
    _usernameController.text.trim(),
    _passwordController.text.trim(),
  );

  setState(() => _loading = false);

  if (!mounted) return;

  if (success) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (_) => false,
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid login'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/logos/icon/dhuadhar_icon.png',
                width: 90,
              ),

              const SizedBox(height: 20),

              Text(
                'Welcome to Dhuadhar',
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 30),

              // Username / Mobile
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Mobile / Username',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
