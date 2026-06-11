import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class FavoriteService {
  final supabase = Supabase.instance.client;

  Future<List<Recipe>> getUserFavorites(String userId) async {
    try {
      final data = await supabase
          .from('favorites')
          .select('''
            recipes(
              id,
              title,
              description,
              steps,
              category,
              image_url,
              is_public,
              is_private,
              user_id,
              created_at,
              updated_at,
              user_profiles(username)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      List<Recipe> recipes = [];
      for (var item in data as List) {
        final recipe = item['recipes'] as Map<String, dynamic>?;
        if (recipe != null) {
          final userProfiles = recipe['user_profiles'] as Map<String, dynamic>?;
          final username = userProfiles?['username'] as String? ?? 'Unknown';

          recipes.add(Recipe(
            id: recipe['id'] as String,
            name: recipe['title'] as String,
            imageUrl: recipe['image_url'] as String?,
            description: recipe['description'] as String,
            steps: recipe['steps'] as String,
            category: recipe['category'] as String? ?? '',
            owner: username,
            userId: recipe['user_id'] as String,
            isPublic: recipe['is_public'] as bool? ?? true,
            isPrivate: recipe['is_private'] as bool? ?? false,
            createdAt: recipe['created_at'] != null
                ? DateTime.parse(recipe['created_at'] as String)
                : null,
            updatedAt: recipe['updated_at'] != null
                ? DateTime.parse(recipe['updated_at'] as String)
                : null,
          ));
        }
      }
      return recipes;
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorited(String userId, String recipeId) async {
    try {
      final data = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId)
          .maybeSingle();

      return data != null;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  Future<void> addFavorite({
    required String userId,
    required String recipeId,
  }) async {
    try {
      await supabase.from('favorites').insert({
        'user_id': userId,
        'recipe_id': recipeId,
      });
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite({
    required String userId,
    required String recipeId,
  }) async {
    try {
      await supabase
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('recipe_id', recipeId);
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  Future<void> toggleFavorite({
    required String userId,
    required String recipeId,
  }) async {
    try {
      final favorited = await isFavorited(userId, recipeId);
      if (favorited) {
        await removeFavorite(userId: userId, recipeId: recipeId);
      } else {
        await addFavorite(userId: userId, recipeId: recipeId);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }

  Stream<List<Recipe>> subscribeToUserFavorites(String userId) async* {
    // Real-time subscription removed - use pull-to-refresh or periodic fetch instead
    // For now, yield data once
    yield await getUserFavorites(userId);
  }
}
