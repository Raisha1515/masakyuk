import 'package:flutter/material.dart';
import 'home_page.dart';
import 'auth_gate.dart';
import 'login.dart';
import 'register.dart';
import 'forgot_password.dart';
import 'dashboard.dart';
import 'trending_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/forgot': (_) => const ForgotPasswordPage(),
        '/dashboard': (_) => const Dashboard(),
        '/trending': (_) => const TrendingPage(),
      },
    );
  }
}
