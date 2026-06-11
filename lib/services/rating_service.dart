import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class RatingService {
  final supabase = Supabase.instance.client;

  Future<List<Rating>> getRecipeRatings(String recipeId) async {
    try {
      final data = await supabase
          .from('ratings')
          .select('''
            id,
            stars,
            user_id,
            created_at
          ''')
          .eq('recipe_id', recipeId);

      return (data as List)
          .map((item) {
            final rating = item as Map<String, dynamic>;
            return Rating(
              id: rating['id'] as String,
              stars: rating['stars'] as int,
              timestamp: DateTime.parse(rating['created_at'] as String),
              userId: rating['user_id'] as String,
            );
          })
          .toList();
    } catch (e) {
      print('Error fetching ratings: $e');
      return [];
    }
  }

  Future<double> getAverageRating(String recipeId) async {
    try {
      final data = await supabase
          .from('ratings')
          .select('stars')
          .eq('recipe_id', recipeId);

      if ((data as List).isEmpty) return 0;

      final avg = (data as List).fold<double>(0, (sum, item) {
        return sum + (item['stars'] as int);
      }) / data.length;

      return double.parse(avg.toStringAsFixed(1));
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0;
    }
  }

  Future<Rating?> getUserRating(String recipeId, String userId) async {
    try {
      final data = await supabase
          .from('ratings')
          .select()
          .eq('recipe_id', recipeId)
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;

      return Rating(
        id: data['id'] as String,
        stars: data['stars'] as int,
        timestamp: DateTime.parse(data['created_at'] as String),
        userId: data['user_id'] as String,
      );
    } catch (e) {
      print('Error fetching user rating: $e');
      return null;
    }
  }

  Future<void> addOrUpdateRating({
    required String recipeId,
    required String userId,
    required int stars,
  }) async {
    try {
      final existingRating = await getUserRating(recipeId, userId);

      if (existingRating != null) {
        // Update existing rating
        await supabase
            .from('ratings')
            .update({'stars': stars})
            .eq('recipe_id', recipeId)
            .eq('user_id', userId);
      } else {
        // Create new rating
        await supabase.from('ratings').insert({
          'recipe_id': recipeId,
          'user_id': userId,
          'stars': stars,
        });
      }
    } catch (e) {
      print('Error adding/updating rating: $e');
      rethrow;
    }
  }

  Future<void> deleteRating(String ratingId) async {
    try {
      await supabase.from('ratings').delete().eq('id', ratingId);
    } catch (e) {
      print('Error deleting rating: $e');
      rethrow;
    }
  }

  Stream<List<Rating>> subscribeToRecipeRatings(String recipeId) async* {
    // Real-time subscription removed - use pull-to-refresh or periodic fetch instead
    // For now, yield data once
    yield await getRecipeRatings(recipeId);
  }
}
