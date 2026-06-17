import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<void> register({
  required String email,
  required String password,
  required String username,
}) async {
  try {
    // 1. Sign up user dengan auth
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Sign up failed: User object is null');

    // 2. Create user profile di database public.user_profiles
    // Gunakan id dari objek user yang baru dibuat
    await supabase.from('user_profiles').insert({
      'id': user.id,
      'username': username,
      'email': email,
    });

    print('User registered successfully: ${user.id}');
  } on AuthException catch (authError) {
    // Menangkap error spesifik dari Supabase Auth (misal: Invalid email, password too short)
    print('Supabase Auth Error: ${authError.message}');
    throw Exception(authError.message);
  } catch (e) {
    print('General Registration error: $e');
    rethrow;
  }
}

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print('Login successful');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await supabase.auth.signOut();
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  bool isLoggedIn() {
    return supabase.auth.currentUser != null;
  }

  String? getCurrentUserId() {
    return supabase.auth.currentUser?.id;
  }

  String? getCurrentUserEmail() {
    return supabase.auth.currentUser?.email;
  }

  // 1. Mengirimkan kode OTP real ke email user
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        // Alur ini otomatis mengirimkan email berisi kode OTP 6-digit default dari Supabase
      );
      print('OTP reset password berhasil dikirim ke $email');
    } catch (e) {
      print('Error sending reset OTP: $e');
      rethrow;
    }
  }

  // 2. Memverifikasi OTP dan memperbarui password baru
  Future<void> verifyOtpAndResetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      // Verifikasi token/OTP yang dimasukkan user
      await supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );

      // Jika OTP valid, session otomatis terbuka sementara untuk memperbarui password
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      print('Password berhasil diubah');
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
}

