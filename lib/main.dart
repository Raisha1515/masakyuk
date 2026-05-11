import 'package:flutter/material.dart';
import 'halaman_utama.dart';
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HalamanUtama(),
    );
  }
}
