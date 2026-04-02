import 'package:flutter/material.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isHovering = false;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();

    final savedUser = prefs.getString("username");
    final savedPass = prefs.getString("password");

    if (usernameController.text == savedUser &&
        passwordController.text == savedPass) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Dashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username atau Password salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),

            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                "assets/images/2.png",
                width: 280,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
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
                  const Text(
                    "Masuk",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F3A38),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Username",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4F3A38),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9ACA3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outlined,
                            color: Color(0xFF4F3A38)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "rararrara12",
                              hintStyle: TextStyle(
                                color: Color(0xFF8E6F6A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Kata Sandi",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4F3A38),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9ACA3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline,
                            color: Color(0xFF4F3A38)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "••••••",
                              hintStyle: TextStyle(
                                fontSize: 22,
                                color: Color(0xFF8E6F6A),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(
                          color: Color(0xFF4F3A38),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ TOMBOL LOGIN SUDAH AKTIF
                  Center(
                    child: Container(
                      width: 260,
                      height: 65,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9ACA3),
                        borderRadius: BorderRadius.circular(35),
                      ),
                      child: TextButton(
                        onPressed: login, // ← INI PENTING!
                        child: const Text(
                          "Selanjutnya",
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF4F3A38),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: MouseRegion(
                      onEnter: (_) => setState(() => isHovering = true),
                      onExit: (_) => setState(() => isHovering = false),
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Belum Punya Akun? ",
                            style: const TextStyle(
                              color: Color(0xFF4F3A38),
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: "Daftar",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isHovering ? Colors.red : Colors.black,
                                  decoration: isHovering
                                      ? TextDecoration.underline
                                      : TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
