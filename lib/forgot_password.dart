import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showOtpField = false;
  bool showPasswordField = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  String? generatedOtp;

  // Theme colors
  static const Color primaryBrown = Color(0xFFD9ACA3);
  static const Color lightBrown = Color(0xFFF8E9DA);
  static const Color darkBrown = Color(0xFF4F3A38);
  static const Color mediumBrown = Color(0xFF8E6F6A);
  static const Color accentBrown = Color(0xFFE7D5D1);

  @override
  void dispose() {
    usernameController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> verifyUsername() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      if (usernameController.text.isEmpty) {
        throw Exception('Username tidak boleh kosong');
      }

      final prefs = await SharedPreferences.getInstance();
      final savedUsername = prefs.getString("username");

      if (usernameController.text != savedUsername) {
        throw Exception('Username tidak ditemukan');
      }

      // Generate simple OTP (in real app, send via email)
      generatedOtp = _generateOtp();

      setState(() {
        showOtpField = true;
        successMessage = 'OTP telah dikirim: $generatedOtp (untuk demo)';
      });

      _showSuccessSnackBar('Username terverifikasi! OTP: $generatedOtp');
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (otpController.text.isEmpty) {
        throw Exception('OTP tidak boleh kosong');
      }

      if (otpController.text != generatedOtp) {
        throw Exception('OTP tidak sesuai');
      }

      setState(() {
        showPasswordField = true;
        successMessage = 'OTP terverifikasi! Masukkan password baru';
      });

      _showSuccessSnackBar('OTP terverifikasi!');
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      if (newPasswordController.text.isEmpty) {
        throw Exception('Password baru tidak boleh kosong');
      }

      if (newPasswordController.text.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      if (newPasswordController.text != confirmPasswordController.text) {
        throw Exception('Password tidak cocok');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("password", newPasswordController.text);

      if (!mounted) return;

      _showSuccessSnackBar('Password berhasil direset!');

      // Wait a moment then navigate back to login
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _generateOtp() {
    return (100000 + DateTime.now().millisecond % 900000).toString();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ),
    );
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
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 30),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightBrown,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: darkBrown,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: darkBrown,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
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
                      const SizedBox(height: 16),
                    ],

                    // Success Message
                    if (successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                successMessage!,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Step 1: Username Field
                    if (!showOtpField) ...[
                      const Text(
                        "Langkah 1: Verifikasi Username",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Masukkan username akun Anda",
                        style: TextStyle(
                          fontSize: 13,
                          color: mediumBrown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: usernameController,
                        label: "Username",
                        icon: Icons.person_outline,
                        hint: "Masukkan username Anda",
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        onPressed: verifyUsername,
                        text: "Verifikasi Username",
                        isLoading: isLoading,
                      ),
                    ],

                    // Step 2: OTP Field
                    if (showOtpField && !showPasswordField) ...[
                      const Text(
                        "Langkah 2: Verifikasi OTP",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Masukkan kode OTP yang telah dikirim",
                        style: TextStyle(
                          fontSize: 13,
                          color: mediumBrown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: otpController,
                        label: "Kode OTP",
                        icon: Icons.security,
                        hint: "Masukkan 6 digit OTP",
                        enabled: !isLoading,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        onPressed: verifyOtp,
                        text: "Verifikasi OTP",
                        isLoading: isLoading,
                      ),
                    ],

                    // Step 3: New Password Field
                    if (showPasswordField) ...[
                      const Text(
                        "Langkah 3: Password Baru",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: darkBrown,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Buat password baru yang kuat",
                        style: TextStyle(
                          fontSize: 13,
                          color: mediumBrown,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPasswordField(
                        controller: newPasswordController,
                        label: "Password Baru",
                        hint: "Minimal 6 karakter",
                        obscure: obscureNewPassword,
                        onToggle: () {
                          setState(() => obscureNewPassword = !obscureNewPassword);
                        },
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: confirmPasswordController,
                        label: "Konfirmasi Password",
                        hint: "Ulangi password",
                        obscure: obscureConfirmPassword,
                        onToggle: () {
                          setState(() =>
                              obscureConfirmPassword = !obscureConfirmPassword);
                        },
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 24),
                      _buildActionButton(
                        onPressed: resetPassword,
                        text: "Reset Password",
                        isLoading: isLoading,
                        isPrimary: true,
                      ),
                    ],

                    // Back to Login Button
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, color: darkBrown),
                        label: const Text(
                          "Kembali ke Login",
                          style: TextStyle(
                            color: darkBrown,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required bool enabled,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: accentBrown,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryBrown, width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: darkBrown, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: mediumBrown,
                      fontSize: 13,
                    ),
                  ),
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required bool enabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: accentBrown,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primaryBrown, width: 1),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: darkBrown, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: mediumBrown,
                      fontSize: 13,
                    ),
                  ),
                  style: const TextStyle(
                    color: darkBrown,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: mediumBrown,
                  size: 20,
                ),
                onPressed: enabled ? onToggle : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required bool isLoading,
    bool isPrimary = false,
  }) {
    return Center(
      child: Container(
        width: 260,
        height: 55,
        decoration: BoxDecoration(
          color: isPrimary ? primaryBrown : accentBrown,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryBrown,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBrown.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(darkBrown),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPrimary ? Colors.white : darkBrown,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
