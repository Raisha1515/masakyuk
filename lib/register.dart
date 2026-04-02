import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("username", usernameController.text);
    await prefs.setString("password", passwordController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registrasi Berhasil!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3),
      body: Column(
        children: [
          const SizedBox(height: 100),

          const Text(
            "HELLO!",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F3A38),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Selamat Datang",
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF4F3A38),
            ),
          ),

          const SizedBox(height: 60),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              decoration: const BoxDecoration(
                color: Color(0xFFF8E9DA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // FIELD NAMA
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7D5D1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: Color(0xFF4F3A38)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Nama :",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // FIELD PASSWORD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7D5D1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Color(0xFF4F3A38)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: "Kata Sandi:",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 45),

                  // TOMBOL DAFTAR
                  Center(
                    child: Container(
                      width: 240,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8E9DA),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(
                          color: const Color(0xFF4F3A38),
                          width: 2,
                        ),
                      ),
                      child: TextButton(
                        onPressed: registerUser,
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F3A38),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
