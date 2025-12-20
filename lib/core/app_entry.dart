import 'package:flutter/material.dart';

import '../core/utils/session_manager.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/home/screens/home_screen.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SessionManager.isSessionValid(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data!
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}
