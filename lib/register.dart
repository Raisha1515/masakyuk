import 'package:flutter/material.dart';
import 'package:masakyuk/services/auth_service.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController =
  TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;
  String? errorMessage;

  // Theme colors
  static const Color primaryBrown = Color(0xFFD9ACA3);
  static const Color lightBrown = Color(0xFFF8E9DA);
  static const Color darkBrown = Color(0xFF4F3A38);
  static const Color mediumBrown = Color(0xFF8E6F6A);
  static const Color accentBrown = Color(0xFFE7D5D1);

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    setState(() => errorMessage = null);

    if (emailController.text.isEmpty) {
      setState(() => errorMessage = 'Email tidak boleh kosong');
      return false;
    }

    if (!emailController.text.contains('@')) {
      setState(() => errorMessage = 'Format email tidak valid');
      return false;
    }

    if (usernameController.text.isEmpty) {
      setState(() => errorMessage = 'Username tidak boleh kosong');
      return false;
    }

    if (usernameController.text.length < 3) {
      setState(() => errorMessage = 'Username minimal 3 karakter');
      return false;
    }

    if (passwordController.text.isEmpty) {
      setState(() => errorMessage = 'Password tidak boleh kosong');
      return false;
    }

    if (passwordController.text.length < 6) {
      setState(() => errorMessage = 'Password minimal 6 karakter');
      return false;
    }

    if (confirmPasswordController.text.isEmpty) {
      setState(() => errorMessage = 'Konfirmasi password tidak boleh kosong');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() => errorMessage = 'Password tidak cocok');
      return false;
    }

    return true;
  }

  Future<void> registerUser() async {
    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    try {
      final authService = AuthService();

      // Register user ke Supabase
      await authService.register(
        email: emailController.text.trim(),
        password: passwordController.text,
        username: usernameController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Registrasi Berhasil!"),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      setState(() => errorMessage = 'Error: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: primaryBrown,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 25),
                child: Column(
                  children: [
                    // Icon with background
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightBrown,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: darkBrown.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 44,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Greeting Text
                    const Text(
                      "Selamat Datang!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      "Buat akun baru untuk memulai",
                      style: TextStyle(
                        fontSize: 15,
                        color: mediumBrown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                decoration: const BoxDecoration(
                  color: lightBrown,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(45),
                    topRight: Radius.circular(45),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Message
                      if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          border: Border.all(color: Colors.red[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ================= PERBAIKAN INPUT EMAIL =================
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accentBrown,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryBrown.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, color: mediumBrown, size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: emailController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "contoh@gmail.com",
                                hintStyle: TextStyle(
                                  color: mediumBrown,
                                  fontSize: 14,
                                ),
                              ),
                              style: const TextStyle(
                                color: darkBrown,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                      // Username Field
                      const Text(
                        "Username",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentBrown,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBrown.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline,
                                color: mediumBrown, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: usernameController,
                                enabled: !isLoading,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Contoh: rayya123",
                                  hintStyle: TextStyle(
                                    color: mediumBrown,
                                    fontSize: 14,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: darkBrown,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Minimal 3 karakter, tanpa spasi",
                        style: TextStyle(
                          fontSize: 12,
                          color: mediumBrown,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Password Field
                      const Text(
                        "Kata Sandi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentBrown,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBrown.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline,
                                color: mediumBrown, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: passwordController,
                                enabled: !isLoading,
                                obscureText: obscurePassword,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Minimal 6 karakter",
                                  hintStyle: TextStyle(
                                    color: mediumBrown,
                                    fontSize: 14,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: darkBrown,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: mediumBrown,
                                size: 22,
                              ),
                              onPressed: !isLoading
                                  ? () {
                                      setState(() =>
                                          obscurePassword = !obscurePassword);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Gunakan kombinasi huruf, angka, dan simbol",
                        style: TextStyle(
                          fontSize: 12,
                          color: mediumBrown,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Confirm Password Field
                      const Text(
                        "Konfirmasi Kata Sandi",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 55,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: accentBrown,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBrown.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline,
                                color: mediumBrown, size: 22),
                            const SizedBox(width: 14),
                            Expanded(
                              child: TextField(
                                controller: confirmPasswordController,
                                enabled: !isLoading,
                                obscureText: obscureConfirmPassword,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Ulangi kata sandi",
                                  hintStyle: TextStyle(
                                    color: mediumBrown,
                                    fontSize: 14,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: darkBrown,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: mediumBrown,
                                size: 22,
                              ),
                              onPressed: !isLoading
                                  ? () {
                                      setState(() => obscureConfirmPassword =
                                          !obscureConfirmPassword);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register Button
                      Center(
                        child: Container(
                          width: 260,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [primaryBrown, Color(0xFFC89A91)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: primaryBrown.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: isLoading ? null : registerUser,
                              borderRadius: BorderRadius.circular(16),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        "Daftar",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sudah punya akun? ",
                              style: TextStyle(
                                color: darkBrown,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Masuk di sini",
                                  style: TextStyle(
                                    color: primaryBrown,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
