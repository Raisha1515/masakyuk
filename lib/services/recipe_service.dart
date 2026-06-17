import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';

class RecipeService {
  final supabase = Supabase.instance.client;

  Future<List<Recipe>> getPublicRecipes() async {
    try {
      final data = await supabase
          .from('recipes')
          .select('''
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
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => _parseRecipe(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching public recipes: $e');
      return [];
    }
  }

  Future<List<Recipe>> getUserRecipes(String userId) async {
    try {
      final data = await supabase
          .from('recipes')
          .select('''
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
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((item) => _parseRecipe(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching user recipes: $e');
      return [];
    }
  }

  Future<Recipe?> getRecipeById(String recipeId) async {
    try {
      final data = await supabase
          .from('recipes')
          .select('''
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
            user_profiles(username),
            comments(
              id,
              text,
              user_id,
              created_at,
              user_profiles(username)
            ),
            ratings(
              id,
              stars,
              user_id,
              created_at
            )
          ''')
          .eq('id', recipeId)
          .single();

      return _parseRecipeWithDetails(data as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching recipe by id: $e');
      return null;
    }
  }

  Future<String> createRecipe({
    required String userId,
    required String title,
    required String description,
    required String steps,
    required String category,
    String? imageUrl,
    bool isPublic = true,
    bool isPrivate = false,
  }) async {
    try {
      final response = await supabase
          .from('recipes')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'steps': steps,
            'category': category,
            'image_url': imageUrl,
            'is_public': isPublic,
            'is_private': isPrivate,
          })
          .select()
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error creating recipe: $e');
      rethrow;
    }
  }

  Future<void> updateRecipe({
    required String recipeId,
    String? title,
    String? description,
    String? steps,
    String? category,
    String? imageUrl,
    bool? isPublic,
    bool? isPrivate,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (steps != null) updateData['steps'] = steps;
      if (category != null) updateData['category'] = category;
      if (imageUrl != null) updateData['image_url'] = imageUrl;
      if (isPublic != null) updateData['is_public'] = isPublic;
      if (isPrivate != null) updateData['is_private'] = isPrivate;

      await supabase
          .from('recipes')
          .update(updateData)
          .eq('id', recipeId);
    } catch (e) {
      print('Error updating recipe: $e');
      rethrow;
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    try {
      await supabase.from('recipes').delete().eq('id', recipeId);
    } catch (e) {
      print('Error deleting recipe: $e');
      rethrow;
    }
  }

  Stream<List<Recipe>> subscribeToPublicRecipes() async* {
    yield await getPublicRecipes();
  }

  Stream<Recipe?> subscribeToRecipe(String recipeId) async* {
    yield await getRecipeById(recipeId);
  }

  Recipe _parseRecipe(Map<String, dynamic> json) {
    final userProfiles = json['user_profiles'] as Map<String, dynamic>?;
    final username = userProfiles?['username'] as String? ?? 'Unknown';

    return Recipe(
      id: json['id'] as String,
      name: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String,
      steps: json['steps'] as String,
      category: json['category'] as String? ?? '',
      owner: username,
      userId: json['user_id'] as String,
      isPublic: json['is_public'] as bool? ?? true,
      isPrivate: json['is_private'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Recipe _parseRecipeWithDetails(Map<String, dynamic> json) {
    final userProfiles = json['user_profiles'] as Map<String, dynamic>?;
    final username = userProfiles?['username'] as String? ?? 'Unknown';

    final comments = (json['comments'] as List?)
            ?.map((c) => _parseComment(c as Map<String, dynamic>))
            .toList() ??
        [];

    final ratings = (json['ratings'] as List?)
            ?.map((r) => _parseRating(r as Map<String, dynamic>))
            .toList() ??
        [];

    return Recipe(
      id: json['id'] as String,
      name: json['title'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String,
      steps: json['steps'] as String,
      category: json['category'] as String? ?? '',
      owner: username,
      userId: json['user_id'] as String,
      isPublic: json['is_public'] as bool? ?? true,
      isPrivate: json['is_private'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      comments: comments,
      ratings: ratings,
    );
  }

  Comment _parseComment(Map<String, dynamic> json) {
    final userProfiles = json['user_profiles'] as Map<String, dynamic>?;
    final username = userProfiles?['username'] as String? ?? 'Unknown';

    return Comment(
      id: json['id'] as String,
      author: username,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
    );
  }

  Rating _parseRating(Map<String, dynamic> json) {
    return Rating(
      id: json['id'] as String,
      stars: json['stars'] as int,
      timestamp: DateTime.parse(json['created_at'] as String),
      userId: json['user_id'] as String,
    );
  }
  
}
