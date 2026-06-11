import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class CommentService {
  final supabase = Supabase.instance.client;

  Future<List<Comment>> getRecipeComments(String recipeId) async {
    try {
      final data = await supabase
          .from('comments')
          .select('''
            id,
            text,
            user_id,
            created_at,
            user_profiles(username)
          ''')
          .eq('recipe_id', recipeId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) {
            final comment = item as Map<String, dynamic>;
            final userProfiles =
                comment['user_profiles'] as Map<String, dynamic>?;
            final username = userProfiles?['username'] as String? ?? 'Unknown';

            return Comment(
              id: comment['id'] as String,
              author: username,
              text: comment['text'] as String,
              timestamp: DateTime.parse(comment['created_at'] as String),
              userId: comment['user_id'] as String,
            );
          })
          .toList();
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<void> addComment({
    required String recipeId,
    required String userId,
    required String text,
  }) async {
    try {
      await supabase.from('comments').insert({
        'recipe_id': recipeId,
        'user_id': userId,
        'text': text,
      });
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await supabase.from('comments').delete().eq('id', commentId);
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  Stream<List<Comment>> subscribeToRecipeComments(String recipeId) async* {
    // Real-time subscription removed - use pull-to-refresh or periodic fetch instead
    // For now, yield data once
    yield await getRecipeComments(recipeId);
  }
}
