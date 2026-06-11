import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final supabase = Supabase.instance.client;

  Future<UserProfile?> getCurrentUser() async {
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
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<void> createUserProfile({
    required String userId,
    required String username,
    required String email,
  }) async {
    try {
      await supabase.from('user_profiles').insert({
        'id': userId,
        'username': username,
        'email': email,
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;

      await supabase
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }
}
