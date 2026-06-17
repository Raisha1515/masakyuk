// // import 'package:flutter/material.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'login.dart';

// // class ForgotPasswordPage extends StatefulWidget {
// //   const ForgotPasswordPage({super.key});

// //   @override
// //   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// // }

// // class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
// //   final TextEditingController usernameController = TextEditingController();
// //   final TextEditingController otpController = TextEditingController();
// //   final TextEditingController newPasswordController = TextEditingController();
// //   final TextEditingController confirmPasswordController = TextEditingController();

// //   bool showOtpField = false;
// //   bool showPasswordField = false;
// //   bool isLoading = false;
// //   String? errorMessage;
// //   String? successMessage;
// //   bool obscureNewPassword = true;
// //   bool obscureConfirmPassword = true;
// //   String? generatedOtp;

// //   // Theme colors
// //   static const Color primaryBrown = Color(0xFFD9ACA3);
// //   static const Color lightBrown = Color(0xFFF8E9DA);
// //   static const Color darkBrown = Color(0xFF4F3A38);
// //   static const Color mediumBrown = Color(0xFF8E6F6A);
// //   static const Color accentBrown = Color(0xFFE7D5D1);

// //   @override
// //   void dispose() {
// //     usernameController.dispose();
// //     otpController.dispose();
// //     newPasswordController.dispose();
// //     confirmPasswordController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> verifyUsername() async {
// //     setState(() {
// //       isLoading = true;
// //       errorMessage = null;
// //       successMessage = null;
// //     });

// //     try {
// //       if (usernameController.text.isEmpty) {
// //         throw Exception('Username tidak boleh kosong');
// //       }

// //       final prefs = await SharedPreferences.getInstance();
// //       final savedUsername = prefs.getString("username");

// //       if (usernameController.text != savedUsername) {
// //         throw Exception('Username tidak ditemukan');
// //       }

// //       // Generate simple OTP (in real app, send via email)
// //       generatedOtp = _generateOtp();

// //       setState(() {
// //         showOtpField = true;
// //         successMessage = 'OTP telah dikirim: $generatedOtp (untuk demo)';
// //       });

// //       _showSuccessSnackBar('Username terverifikasi! OTP: $generatedOtp');
// //     } catch (e) {
// //       setState(() {
// //         errorMessage = e.toString().replaceAll('Exception: ', '');
// //       });
// //       _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   Future<void> verifyOtp() async {
// //     setState(() {
// //       isLoading = true;
// //       errorMessage = null;
// //     });

// //     try {
// //       if (otpController.text.isEmpty) {
// //         throw Exception('OTP tidak boleh kosong');
// //       }

// //       if (otpController.text != generatedOtp) {
// //         throw Exception('OTP tidak sesuai');
// //       }

// //       setState(() {
// //         showPasswordField = true;
// //         successMessage = 'OTP terverifikasi! Masukkan password baru';
// //       });

// //       _showSuccessSnackBar('OTP terverifikasi!');
// //     } catch (e) {
// //       setState(() {
// //         errorMessage = e.toString().replaceAll('Exception: ', '');
// //       });
// //       _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   Future<void> resetPassword() async {
// //     setState(() {
// //       isLoading = true;
// //       errorMessage = null;
// //     });

// //     try {
// //       if (newPasswordController.text.isEmpty) {
// //         throw Exception('Password baru tidak boleh kosong');
// //       }

// //       if (newPasswordController.text.length < 6) {
// //         throw Exception('Password minimal 6 karakter');
// //       }

// //       if (newPasswordController.text != confirmPasswordController.text) {
// //         throw Exception('Password tidak cocok');
// //       }

// //       final prefs = await SharedPreferences.getInstance();
// //       await prefs.setString("password", newPasswordController.text);

// //       if (!mounted) return;

// //       _showSuccessSnackBar('Password berhasil direset!');

// //       // Wait a moment then navigate back to login
// //       await Future.delayed(const Duration(seconds: 2));

// //       if (!mounted) return;
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (_) => const LoginPage()),
// //       );
// //     } catch (e) {
// //       setState(() {
// //         errorMessage = e.toString().replaceAll('Exception: ', '');
// //       });
// //       _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
// //     } finally {
// //       setState(() => isLoading = false);
// //     }
// //   }

// //   String _generateOtp() {
// //     return (100000 + DateTime.now().millisecond % 900000).toString();
// //   }

// //   void _showErrorSnackBar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red[700],
// //         duration: const Duration(seconds: 3),
// //       ),
// //     );
// //   }

// //   void _showSuccessSnackBar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.green[700],
// //         duration: const Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: () async => true,
// //       child: Scaffold(
// //         backgroundColor: primaryBrown,
// //         body: SingleChildScrollView(
// //           child: Column(
// //             children: [
// //               // Header
// //               Padding(
// //                 padding: const EdgeInsets.only(top: 40, bottom: 30),
// //                 child: Column(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: lightBrown,
// //                         shape: BoxShape.circle,
// //                       ),
// //                       child: const Icon(
// //                         Icons.lock_reset,
// //                         size: 40,
// //                         color: darkBrown,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 16),
// //                     const Text(
// //                       "Reset Password",
// //                       style: TextStyle(
// //                         fontSize: 28,
// //                         fontWeight: FontWeight.w700,
// //                         color: darkBrown,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // Main Content
// //               Container(
// //                 width: double.infinity,
// //                 padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
// //                 decoration: const BoxDecoration(
// //                   color: lightBrown,
// //                   borderRadius: BorderRadius.only(
// //                     topLeft: Radius.circular(45),
// //                     topRight: Radius.circular(45),
// //                   ),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // Error Message
// //                     if (errorMessage != null) ...[
// //                       Container(
// //                         padding: const EdgeInsets.all(12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.red[50],
// //                           border: Border.all(color: Colors.red[300]!),
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             Icon(Icons.error_outline, color: Colors.red[700]),
// //                             const SizedBox(width: 12),
// //                             Expanded(
// //                               child: Text(
// //                                 errorMessage!,
// //                                 style: TextStyle(
// //                                   color: Colors.red[700],
// //                                   fontSize: 13,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),
// //                     ],

// //                     // Success Message
// //                     if (successMessage != null) ...[
// //                       Container(
// //                         padding: const EdgeInsets.all(12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.green[50],
// //                           border: Border.all(color: Colors.green[300]!),
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             Icon(Icons.check_circle_outline, color: Colors.green[700]),
// //                             const SizedBox(width: 12),
// //                             Expanded(
// //                               child: Text(
// //                                 successMessage!,
// //                                 style: TextStyle(
// //                                   color: Colors.green[700],
// //                                   fontSize: 13,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),
// //                     ],

// //                     // Step 1: Username Field
// //                     if (!showOtpField) ...[
// //                       const Text(
// //                         "Langkah 1: Verifikasi Username",
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w600,
// //                           color: darkBrown,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),
// //                       const Text(
// //                         "Masukkan username akun Anda",
// //                         style: TextStyle(
// //                           fontSize: 13,
// //                           color: mediumBrown,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 12),
// //                       _buildInputField(
// //                         controller: usernameController,
// //                         label: "Username",
// //                         icon: Icons.person_outline,
// //                         hint: "Masukkan username Anda",
// //                         enabled: !isLoading,
// //                       ),
// //                       const SizedBox(height: 24),
// //                       _buildActionButton(
// //                         onPressed: verifyUsername,
// //                         text: "Verifikasi Username",
// //                         isLoading: isLoading,
// //                       ),
// //                     ],

// //                     // Step 2: OTP Field
// //                     if (showOtpField && !showPasswordField) ...[
// //                       const Text(
// //                         "Langkah 2: Verifikasi OTP",
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w600,
// //                           color: darkBrown,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),
// //                       const Text(
// //                         "Masukkan kode OTP yang telah dikirim",
// //                         style: TextStyle(
// //                           fontSize: 13,
// //                           color: mediumBrown,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 12),
// //                       _buildInputField(
// //                         controller: otpController,
// //                         label: "Kode OTP",
// //                         icon: Icons.security,
// //                         hint: "Masukkan 6 digit OTP",
// //                         enabled: !isLoading,
// //                         keyboardType: TextInputType.number,
// //                       ),
// //                       const SizedBox(height: 24),
// //                       _buildActionButton(
// //                         onPressed: verifyOtp,
// //                         text: "Verifikasi OTP",
// //                         isLoading: isLoading,
// //                       ),
// //                     ],

// //                     // Step 3: New Password Field
// //                     if (showPasswordField) ...[
// //                       const Text(
// //                         "Langkah 3: Password Baru",
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w600,
// //                           color: darkBrown,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 16),
// //                       const Text(
// //                         "Buat password baru yang kuat",
// //                         style: TextStyle(
// //                           fontSize: 13,
// //                           color: mediumBrown,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 12),
// //                       _buildPasswordField(
// //                         controller: newPasswordController,
// //                         label: "Password Baru",
// //                         hint: "Minimal 6 karakter",
// //                         obscure: obscureNewPassword,
// //                         onToggle: () {
// //                           setState(() => obscureNewPassword = !obscureNewPassword);
// //                         },
// //                         enabled: !isLoading,
// //                       ),
// //                       const SizedBox(height: 16),
// //                       _buildPasswordField(
// //                         controller: confirmPasswordController,
// //                         label: "Konfirmasi Password",
// //                         hint: "Ulangi password",
// //                         obscure: obscureConfirmPassword,
// //                         onToggle: () {
// //                           setState(() =>
// //                               obscureConfirmPassword = !obscureConfirmPassword);
// //                         },
// //                         enabled: !isLoading,
// //                       ),
// //                       const SizedBox(height: 24),
// //                       _buildActionButton(
// //                         onPressed: resetPassword,
// //                         text: "Reset Password",
// //                         isLoading: isLoading,
// //                         isPrimary: true,
// //                       ),
// //                     ],

// //                     // Back to Login Button
// //                     const SizedBox(height: 20),
// //                     Center(
// //                       child: TextButton.icon(
// //                         onPressed: () {
// //                           Navigator.pushReplacement(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (_) => const LoginPage(),
// //                             ),
// //                           );
// //                         },
// //                         icon: const Icon(Icons.arrow_back, color: darkBrown),
// //                         label: const Text(
// //                           "Kembali ke Login",
// //                           style: TextStyle(
// //                             color: darkBrown,
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildInputField({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     required String hint,
// //     required bool enabled,
// //     TextInputType keyboardType = TextInputType.text,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             fontSize: 13,
// //             fontWeight: FontWeight.w600,
// //             color: darkBrown,
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Container(
// //           height: 50,
// //           padding: const EdgeInsets.symmetric(horizontal: 14),
// //           decoration: BoxDecoration(
// //             color: accentBrown,
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: primaryBrown, width: 1),
// //           ),
// //           child: Row(
// //             children: [
// //               Icon(icon, color: darkBrown, size: 20),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: TextField(
// //                   controller: controller,
// //                   enabled: enabled,
// //                   keyboardType: keyboardType,
// //                   decoration: InputDecoration(
// //                     border: InputBorder.none,
// //                     hintText: hint,
// //                     hintStyle: const TextStyle(
// //                       color: mediumBrown,
// //                       fontSize: 13,
// //                     ),
// //                   ),
// //                   style: const TextStyle(
// //                     color: darkBrown,
// //                     fontSize: 14,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPasswordField({
// //     required TextEditingController controller,
// //     required String label,
// //     required String hint,
// //     required bool obscure,
// //     required VoidCallback onToggle,
// //     required bool enabled,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             fontSize: 13,
// //             fontWeight: FontWeight.w600,
// //             color: darkBrown,
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Container(
// //           height: 50,
// //           padding: const EdgeInsets.symmetric(horizontal: 14),
// //           decoration: BoxDecoration(
// //             color: accentBrown,
// //             borderRadius: BorderRadius.circular(12),
// //             border: Border.all(color: primaryBrown, width: 1),
// //           ),
// //           child: Row(
// //             children: [
// //               const Icon(Icons.lock_outline, color: darkBrown, size: 20),
// //               const SizedBox(width: 12),
// //               Expanded(
// //                 child: TextField(
// //                   controller: controller,
// //                   enabled: enabled,
// //                   obscureText: obscure,
// //                   decoration: InputDecoration(
// //                     border: InputBorder.none,
// //                     hintText: hint,
// //                     hintStyle: const TextStyle(
// //                       color: mediumBrown,
// //                       fontSize: 13,
// //                     ),
// //                   ),
// //                   style: const TextStyle(
// //                     color: darkBrown,
// //                     fontSize: 14,
// //                   ),
// //                 ),
// //               ),
// //               IconButton(
// //                 icon: Icon(
// //                   obscure ? Icons.visibility_off : Icons.visibility,
// //                   color: mediumBrown,
// //                   size: 20,
// //                 ),
// //                 onPressed: enabled ? onToggle : null,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildActionButton({
// //     required VoidCallback onPressed,
// //     required String text,
// //     required bool isLoading,
// //     bool isPrimary = false,
// //   }) {
// //     return Center(
// //       child: Container(
// //         width: 260,
// //         height: 55,
// //         decoration: BoxDecoration(
// //           color: isPrimary ? primaryBrown : accentBrown,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             color: primaryBrown,
// //             width: 1.5,
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: primaryBrown.withOpacity(0.3),
// //               blurRadius: 8,
// //               offset: const Offset(0, 4),
// //             ),
// //           ],
// //         ),
// //         child: Material(
// //           color: Colors.transparent,
// //           child: InkWell(
// //             onTap: isLoading ? null : onPressed,
// //             borderRadius: BorderRadius.circular(12),
// //             child: Center(
// //               child: isLoading
// //                   ? const SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(
// //                         valueColor: AlwaysStoppedAnimation<Color>(darkBrown),
// //                         strokeWidth: 2,
// //                       ),
// //                     )
// //                   : Text(
// //                       text,
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.w600,
// //                         color: isPrimary ? Colors.white : darkBrown,
// //                       ),
// //                     ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:masakyuk/services/auth_service.dart'; // Pastikan path import ini sesuai
// import 'login.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Pastikan diimport untuk penanganan session

// class ForgotPasswordPage extends StatefulWidget {
//   const ForgotPasswordPage({super.key});

//   @override
//   State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
//   // Mengubah nama controller agar lebih mencerminkan fungsi Email
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController otpController = TextEditingController();
//   final TextEditingController newPasswordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();

//   final AuthService _authService = AuthService();

//   bool showOtpField = false;
//   bool showPasswordField = false;
//   bool isLoading = false;
//   String? errorMessage;
//   String? successMessage;
//   bool obscureNewPassword = true;
//   bool obscureConfirmPassword = true;

//   // Theme colors
//   static const Color primaryBrown = Color(0xFFD9ACA3);
//   static const Color lightBrown = Color(0xFFF8E9DA);
//   static const Color darkBrown = Color(0xFF4F3A38);
//   static const Color mediumBrown = Color(0xFF8E6F6A);
//   static const Color accentBrown = Color(0xFFE7D5D1);

//   @override
//   void dispose() {
//     emailController.dispose();
//     otpController.dispose();
//     newPasswordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   // LANGKAH 1: Mengirim OTP Real lewat Supabase Auth
//   Future<void> verifyEmailAndSendOtp() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       successMessage = null;
//     });

//     try {
//       final email = emailController.text.trim();
//       if (email.isEmpty) {
//         throw Exception('Email tidak boleh kosong');
//       }
//       if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
//         throw Exception('Format email tidak valid');
//       }

//       // Memanggil Supabase untuk kirim OTP kustom khusus pemulihan password
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email.toLowerCase(),
//       );

//       setState(() {
//         showOtpField = true;
//         successMessage = 'Kode OTP berhasil dikirim ke email Anda.';
//       });

//       _showSuccessSnackBar('OTP Terkirim! Periksa kotak masuk/spam email Anda.');
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
//       });
//       _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // LANGKAH 2: Validasi Token OTP Langsung ke Server Supabase
//   Future<void> verifyOtp() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       successMessage = null;
//     });

//     try {
//       final token = otpController.text.trim();
//       final email = emailController.text.trim().toLowerCase();

//       if (token.isEmpty) {
//         throw Exception('OTP tidak boleh kosong');
//       }

//       // Verifikasi token OTP langsung ke server Supabase menggunakan tipe recovery
//       await Supabase.instance.client.auth.verifyOTP(
//         email: email,
//         token: token,
//         type: OtpType.recovery,
//       );

//       // Jika lolos verifikasi, Supabase akan memberikan hak akses sesi sementara untuk ganti password
//       setState(() {
//         showPasswordField = true;
//         successMessage = 'OTP valid. Silakan buat password baru Anda.';
//       });

//       _showSuccessSnackBar('Silakan isi password baru.');
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
//       });
//       _showErrorSnackBar(errorMessage ?? 'Kode OTP salah atau kedaluwarsa');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   // LANGKAH 3: Eksekusi Update Password Baru ke Supabase
//   Future<void> resetPassword() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//       successMessage = null;
//     });

//     try {
//       if (newPasswordController.text.isEmpty) {
//         throw Exception('Password baru tidak boleh kosong');
//       }
//       if (newPasswordController.text.length < 6) {
//         throw Exception('Password minimal 6 karakter');
//       }
//       if (newPasswordController.text != confirmPasswordController.text) {
//         throw Exception('Konfirmasi password tidak cocok');
//       }

//       // Karena token sudah diverifikasi di langkah 2, kita tinggal memperbarui user data password saat ini
//       await Supabase.instance.client.auth.updateUser(
//         UserAttributes(
//           password: newPasswordController.text,
//         ),
//       );

//       // Opsional: Lakukan sign out setelah ganti password agar user terpaksa login ulang dengan kredensial baru
//       await Supabase.instance.client.auth.signOut();

//       if (!mounted) return;

//       _showSuccessSnackBar('Password berhasil diperbarui!');

//       await Future.delayed(const Duration(seconds: 2));

//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     } catch (e) {
//       setState(() {
//         errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
//       });
//       _showErrorSnackBar(errorMessage ?? 'Gagal memperbarui password, silakan coba lagi.');
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red[700],
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green[700],
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       child: Scaffold(
//         backgroundColor: primaryBrown,
//         body: CentralizeView(),
//       ),
//     );
//   }

//   Widget CentralizeView() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // Header
//           Padding(
//             padding: const EdgeInsets.only(top: 40, bottom: 30),
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: const BoxDecoration(
//                     color: lightBrown,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.lock_reset,
//                     size: 40,
//                     color: darkBrown,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Reset Password",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.w700,
//                     color: darkBrown,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Main Content
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
//             decoration: const BoxDecoration(
//               color: lightBrown,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(45),
//                 topRight: Radius.circular(45),
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Info Messages
//                 if (errorMessage != null) ...[
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red[50],
//                       border: Border.all(color: Colors.red[300]!),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.error_outline, color: Colors.red[700]),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             errorMessage!,
//                             style: TextStyle(color: Colors.red[700], fontSize: 13, fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 if (successMessage != null) ...[
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.green[50],
//                       border: Border.all(color: Colors.green[300]!),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle_outline, color: Colors.green[700]),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             successMessage!,
//                             style: TextStyle(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.w500),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 // Step 1: Email Field
//                 if (!showOtpField) ...[
//                   const Text(
//                     "Langkah 1: Verifikasi Alamat Email",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkBrown),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "Masukkan email terdaftar yang terhubung dengan akun Anda",
//                     style: TextStyle(fontSize: 13, color: mediumBrown),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInputField(
//                     controller: emailController,
//                     label: "Email Terdaftar",
//                     icon: Icons.email_outlined,
//                     hint: "contoh@email.com",
//                     enabled: !isLoading,
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   const SizedBox(height: 24),
//                   _buildActionButton(
//                     onPressed: verifyEmailAndSendOtp,
//                     text: "Kirim Kode OTP",
//                     isLoading: isLoading,
//                   ),
//                 ],

//                 // Step 2: OTP Field
//                 if (showOtpField && !showPasswordField) ...[
//                   const Text(
//                     "Langkah 2: Verifikasi OTP",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkBrown),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     "Masukkan 6 digit token pengaman yang dikirim ke email",
//                     style: TextStyle(fontSize: 13, color: mediumBrown),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInputField(
//                     controller: otpController,
//                     label: "Kode OTP",
//                     icon: Icons.security,
//                     hint: "Masukkan 6 digit OTP",
//                     enabled: !isLoading,
//                     keyboardType: TextInputType.number,
//                   ),
//                   const SizedBox(height: 24),
//                   _buildActionButton(
//                     onPressed: verifyOtp,
//                     text: "Verifikasi OTP",
//                     isLoading: isLoading,
//                   ),
//                 ],

//                 // Step 3: New Password Field
//                 if (showPasswordField) ...[
//                   const Text(
//                     "Langkah 3: Atur Password Baru",
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkBrown),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildPasswordField(
//                     controller: newPasswordController,
//                     label: "Password Baru",
//                     hint: "Minimal 6 karakter",
//                     obscure: obscureNewPassword,
//                     onToggle: () => setState(() => obscureNewPassword = !obscureNewPassword),
//                     enabled: !isLoading,
//                   ),
//                   const SizedBox(height: 16),
//                   _buildPasswordField(
//                     controller: confirmPasswordController,
//                     label: "Konfirmasi Password",
//                     hint: "Ulangi password baru",
//                     obscure: obscureConfirmPassword,
//                     onToggle: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
//                     enabled: !isLoading,
//                   ),
//                   const SizedBox(height: 24),
//                   _buildActionButton(
//                     onPressed: resetPassword,
//                     text: "Simpan Password Baru",
//                     isLoading: isLoading,
//                     isPrimary: true,
//                   ),
//                 ],

//                 // Back to Login Button
//                 const SizedBox(height: 20),
//                 Center(
//                   child: TextButton.icon(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const LoginPage()),
//                       );
//                     },
//                     icon: const Icon(Icons.arrow_back, color: darkBrown),
//                     label: const Text(
//                       "Kembali ke Login",
//                       style: TextStyle(color: darkBrown, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String hint,
//     required bool enabled,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkBrown)),
//         const SizedBox(height: 8),
//         Container(
//           height: 50,
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           decoration: BoxDecoration(
//             color: accentBrown,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: primaryBrown, width: 1),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: darkBrown, size: 20),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   enabled: enabled,
//                   keyboardType: keyboardType,
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: hint,
//                     hintStyle: const TextStyle(color: mediumBrown, fontSize: 13),
//                   ),
//                   style: const TextStyle(color: darkBrown, fontSize: 14),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPasswordField({
//     required TextEditingController controller,
//     required String label,
//     required String hint,
//     required bool obscure,
//     required VoidCallback onToggle,
//     required bool enabled,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkBrown)),
//         const SizedBox(height: 8),
//         Container(
//           height: 50,
//           padding: const EdgeInsets.symmetric(horizontal: 14),
//           decoration: BoxDecoration(
//             color: accentBrown,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: primaryBrown, width: 1),
//           ),
//           child: Row(
//             children: [
//               const Icon(Icons.lock_outline, color: darkBrown, size: 20),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextField(
//                   controller: controller,
//                   enabled: enabled,
//                   obscureText: obscure,
//                   decoration: InputDecoration(
//                     border: InputBorder.none,
//                     hintText: hint,
//                     hintStyle: const TextStyle(color: mediumBrown, fontSize: 13),
//                   ),
//                   style: const TextStyle(color: darkBrown, fontSize: 14),
//                 ),
//               ),
//               IconButton(
//                 icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: mediumBrown, size: 20),
//                 onPressed: enabled ? onToggle : null,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButton({
//     required VoidCallback onPressed,
//     required String text,
//     required bool isLoading,
//     bool isPrimary = false,
//   }) {
//     return Center(
//       child: Container(
//         width: 260,
//         height: 55,
//         decoration: BoxDecoration(
//           color: isPrimary ? primaryBrown : accentBrown,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: primaryBrown, width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: primaryBrown.withOpacity(0.3),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: isLoading ? null : onPressed,
//             borderRadius: BorderRadius.circular(12),
//             child: Center(
//               child: isLoading
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(darkBrown),
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : Text(
//                       text,
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: isPrimary ? Colors.white : darkBrown,
//                       ),
//                     ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:masakyuk/services/auth_service.dart'; // Pastikan path import ini sesuai
import 'login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool showOtpField = false;
  bool showPasswordField = false;
  bool isLoading = false;
  String? errorMessage;
  String? successMessage;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;

  // Theme colors
  static const Color primaryBrown = Color(0xFFD9ACA3);
  static const Color lightBrown = Color(0xFFF8E9DA);
  static const Color darkBrown = Color(0xFF4F3A38);
  static const Color mediumBrown = Color(0xFF8E6F6A);
  static const Color accentBrown = Color(0xFFE7D5D1);

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // TRIK CERDAS LANGKAH 1: Mengirim 6 Digit Angka Otomatis Menggunakan OTP Sign-In
  Future<void> verifyEmailAndSendOtp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final email = emailController.text.trim();
      if (email.isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }

      // Cek terlebih dahulu apakah email ini benar-benar terdaftar di user_profiles Anda
      final userCheck = await _authService.supabase
          .from('user_profiles')
          .select('email')
          .eq('email', email.toLowerCase())
          .maybeSingle();

      if (userCheck == null) {
        throw Exception('Email tidak terdaftar di sistem MasakYuk.');
      }

      // Memicu pengiriman 6 digit OTP angka bawaan Supabase ke email asli
      await _authService.supabase.auth.signInWithOtp(
        email: email.toLowerCase(),
        shouldCreateUser: false, // Menghindari pembuatan akun baru jika email salah
      );

      setState(() {
        showOtpField = true;
        successMessage = '6 Digit Kode OTP telah dikirimkan ke email Anda.';
      });

      _showSuccessSnackBar('OTP Terkirim! Periksa kotak masuk atau folder spam email Anda.');
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      });
      _showErrorSnackBar(errorMessage ?? 'Terjadi kesalahan');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // TRIK CERDAS LANGKAH 2: Verifikasi 6 Digit Angka OTP dari User
  Future<void> verifyOtp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      final token = otpController.text.trim();
      final email = emailController.text.trim().toLowerCase();

      if (token.isEmpty) {
        throw Exception('OTP tidak boleh kosong');
      }

      // Memvalidasi token angka menggunakan tipe OtpType.email atau OtpType.magiclink
      await _authService.supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email, // Menggunakan tipe email auth token
      );

      setState(() {
        showPasswordField = true;
        successMessage = 'OTP Valid! Silakan tentukan kata sandi baru Anda.';
      });

      _showSuccessSnackBar('Verifikasi sukses. Masukkan password baru.');
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      });
      _showErrorSnackBar(errorMessage ?? 'Kode OTP salah atau kedaluwarsa');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // TRIK CERDAS LANGKAH 3: Memperbarui Password Baru ke Supabase Auth
  Future<void> resetPassword() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      successMessage = null;
    });

    try {
      if (newPasswordController.text.isEmpty) {
        throw Exception('Password baru tidak boleh kosong');
      }
      if (newPasswordController.text.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }
      if (newPasswordController.text != confirmPasswordController.text) {
        throw Exception('Konfirmasi password tidak cocok');
      }

      // Karena OTP sukses, user saat ini otomatis masuk dalam session aktif sementara,
      // sehingga kita bisa langsung mengeksekusi updateUser password.
      await _authService.supabase.auth.updateUser(
        UserAttributes(
          password: newPasswordController.text,
        ),
      );

      // Keluarkan sesi untuk keamanan agar user dipaksa login ulang dengan password baru
      await _authService.supabase.auth.signOut();

      if (!mounted) return;

      _showSuccessSnackBar('Kata sandi berhasil diperbarui!');

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
      });
      _showErrorSnackBar(errorMessage ?? 'Gagal memperbarui password.');
    } finally {
      setState(() => isLoading = false);
    }
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
    return Scaffold(
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
                    decoration: const BoxDecoration(
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
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: darkBrown),
                  ),
                ],
              ),
            ),

            // Main Box Card
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
                  // Alert Messages
                  if (errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(errorMessage!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(successMessage!, style: TextStyle(color: Colors.green[700], fontSize: 13)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ALUR FIELD BERDASARKAN STEP STATUS
                  if (!showOtpField) ...[
                    const Text("Langkah 1: Masukkan Email Anda", style: TextStyle(fontWeight: FontWeight.w600, color: darkBrown)),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: emailController,
                      label: "Email Aktif",
                      icon: Icons.email_outlined,
                      hint: "Masukkan email asli Anda",
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    _buildActionButton(onPressed: verifyEmailAndSendOtp, text: "Kirim 6 Digit OTP", isLoading: isLoading),
                  ] else if (showOtpField && !showPasswordField) ...[
                    const Text("Langkah 2: Verifikasi 6 Digit OTP", style: TextStyle(fontWeight: FontWeight.w600, color: darkBrown)),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: otpController,
                      label: "Kode OTP Angka",
                      icon: Icons.pin_drop,
                      hint: "Masukkan 6 angka dari email",
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _buildActionButton(onPressed: verifyOtp, text: "Verifikasi Kode", isLoading: isLoading),
                  ] else if (showPasswordField) ...[
                    const Text("Langkah 3: Atur Ulang Kata Sandi", style: TextStyle(fontWeight: FontWeight.w600, color: darkBrown)),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      controller: newPasswordController,
                      label: "Kata Sandi Baru",
                      hint: "Minimal 6 Karakter",
                      obscure: obscureNewPassword,
                      onToggle: () => setState(() => obscureNewPassword = !obscureNewPassword),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      label: "Ulangi Kata Sandi Baru",
                      hint: "Konfirmasi kata sandi",
                      obscure: obscureConfirmPassword,
                      onToggle: () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 24),
                    _buildActionButton(onPressed: resetPassword, text: "Simpan Sandi Baru", isLoading: isLoading, isPrimary: true),
                  ],

                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                      },
                      child: const Text("Kembali ke Login", style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkBrown)),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: accentBrown, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              Icon(icon, color: darkBrown, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: mediumBrown, fontSize: 13)),
                  style: const TextStyle(color: darkBrown, fontSize: 14),
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
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: darkBrown)),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: accentBrown, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: darkBrown, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscure,
                  decoration: InputDecoration(border: InputBorder.none, hintText: hint, hintStyle: const TextStyle(color: mediumBrown, fontSize: 13)),
                  style: const TextStyle(color: darkBrown, fontSize: 14),
                ),
              ),
              IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: mediumBrown, size: 20),
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
      child: SizedBox(
        width: 260,
        height: 50,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary ? darkBrown : primaryBrown,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isPrimary ? Colors.white : darkBrown)),
        ),
      ),
    );
  }
}