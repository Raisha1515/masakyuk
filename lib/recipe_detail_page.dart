import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:masakyuk/models/recipe_model.dart';
import 'package:masakyuk/services/comment_service.dart';
import 'package:masakyuk/services/rating_service.dart';
import 'package:masakyuk/services/recipe_service.dart';
import 'package:masakyuk/tambah_resep.dart'; 

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final String userName;
  final Function(Recipe) onRecipeUpdated;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    required this.userName,
    required this.onRecipeUpdated,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  late Recipe recipe;
  late TextEditingController commentController;
  int selectedRating = 0;
  bool isAddingComment = false;
  bool isAddingRating = false;

  final RecipeService _recipeService = RecipeService();
  late CommentService commentService;
  late RatingService ratingService;
  String? userId;

  List<Comment> comments = [];
  List<Rating> ratings = [];
  double averageRating = 0;

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    commentController = TextEditingController();
    commentService = CommentService();
    ratingService = RatingService();
    userId = Supabase.instance.client.auth.currentUser?.id;

    _loadCommentAndRatings();
  }

  bool get isOwner => userId != null && recipe.userId == userId;

  Future<void> _deleteRecipe() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Resep"),
        content: const Text("Apakah Anda yakin ingin menghapus resep ini secara permanen?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _recipeService.deleteRecipe(recipe.id);
        if (!mounted) return;
        Navigator.pop(context, "deleted");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resep berhasil dihapus")));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
      }
    }
  }

  Future<void> _loadCommentAndRatings() async {
    try {
      final loadedComments = await commentService.getRecipeComments(recipe.id);
      final loadedRatings = await ratingService.getRecipeRatings(recipe.id);
      final avgRating = await ratingService.getAverageRating(recipe.id);

      if (!mounted) return;
      setState(() {
        comments = loadedComments;
        ratings = loadedRatings;
        averageRating = avgRating;
      });
    } catch (e) {
      print('Error loading comments and ratings: $e');
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void _addRating(int stars) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda harus login terlebih dahulu')));
      return;
    }
    setState(() => isAddingRating = true);
    try {
      await ratingService.addOrUpdateRating(recipeId: recipe.id, userId: userId!, stars: stars);
      await _loadCommentAndRatings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating berhasil ditambahkan!')));
      setState(() => selectedRating = 0);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isAddingRating = false);
    }
  }

  void _addComment(String text) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anda harus login terlebih dahulu')));
      return;
    }
    if (text.trim().isEmpty) return;
    setState(() => isAddingComment = true);
    try {
      await commentService.addComment(recipeId: recipe.id, userId: userId!, text: text);
      await _loadCommentAndRatings();
      commentController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar berhasil ditambahkan!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isAddingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: isOwner ? [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () async {
              final updatedData = await Navigator.push<Recipe>(
                context, 
                MaterialPageRoute(builder: (_) => TambahResep(recipe: recipe))
              );
              
              if (updatedData != null) {
                setState(() {
                  recipe = updatedData;
                });
                widget.onRecipeUpdated(updatedData);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteRecipe,
          ),
        ] : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildRecipeInfo(),
              _buildRatingSection(),
              _buildCommentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        if (recipe.imageUrl != null)
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(recipe.imageUrl!), fit: BoxFit.cover),
            ),
          )
        else
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 80, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildRecipeInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFFCEEE4),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFFF4081), borderRadius: BorderRadius.circular(20)),
                          child: Text(recipe.category, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        if (recipe.isPublic == false || recipe.isPrivate == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              children: [
                                Icon(Icons.lock, color: Colors.white, size: 12),
                                SizedBox(width: 4),
                                Text('Privat', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (averageRating > 0)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 24)),
                      Text(averageRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4F3A38))),
                      Text('${ratings.length} rating', style: const TextStyle(fontSize: 10, color: Color(0xFF8E6F6A))),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoTile('👨‍🍳 Chef :', recipe.owner ?? 'Unknown'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          const Text('Deskripsi & Bahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(recipe.description, style: const TextStyle(height: 1.6, color: Color(0xFF4F3A38))),
          const SizedBox(height: 20),
          const Text('Langkah-Langkah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Text(recipe.steps, style: const TextStyle(height: 1.6, color: Color(0xFF4F3A38))),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE7D5D1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Berikan Rating', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) => GestureDetector(
              onTap: isAddingRating ? null : () => setState(() => selectedRating = index + 1),
              child: Icon(Icons.star, size: 32, color: selectedRating > index ? Colors.amber : Colors.grey[300]),
            )),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAddingRating || selectedRating == 0 ? null : () => _addRating(selectedRating),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4081)),
              child: isAddingRating ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Kirim Rating'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Komentar (${comments.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          TextField(
            controller: commentController,
            enabled: !isAddingComment,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Tulis komentar...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              suffixIcon: IconButton(
                icon: isAddingComment ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                onPressed: isAddingComment ? null : () => _addComment(commentController.text),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (comments.isEmpty)
            const Center(child: Text('Belum ada komentar', style: TextStyle(color: Color(0xFF8E6F6A))))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE7D5D1))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(comment.author, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F3A38))),
                          Text(_formatDate(comment.timestamp), style: const TextStyle(fontSize: 12, color: Color(0xFF8E6F6A))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(comment.text, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes} menit lalu';
    if (difference.inHours < 24) return '${difference.inHours} jam lalu';
    if (difference.inDays < 7) return '${difference.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }
}