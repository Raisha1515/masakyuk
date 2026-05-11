import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:masakyuk/models/recipe_model.dart';
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

  @override
  void initState() {
    super.initState();
    recipe = widget.recipe;
    commentController = TextEditingController();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  ImageProvider getImageProvider(String imagePath) {
    if (kIsWeb) {
      return NetworkImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  void _addRating(int stars) {
    final newRating = Rating(
      id: 'rating_${DateTime.now().millisecondsSinceEpoch}',
      stars: stars,
      timestamp: DateTime.now(),
    );

    setState(() {
      recipe.ratings.add(newRating);
    });

    widget.onRecipeUpdated(recipe);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rating berhasil ditambahkan!')),
    );
  }

  void _addComment(String text) {
    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      author: widget.userName,
      text: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      recipe.comments.add(newComment);
    });

    widget.onRecipeUpdated(recipe);
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) return 'Baru saja';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m lalu';
    if (difference.inHours < 24) return '${difference.inHours}h lalu';
    if (difference.inDays < 7) return '${difference.inDays}d lalu';

    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _editRecipe() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahResep(recipe: recipe),
      ),
    );

    if (result != null && result is Recipe) {
      result.owner = recipe.owner;
      result.isPrivate = recipe.isPrivate;
      result.isPublic = recipe.isPublic;

      setState(() {
        recipe = result;
      });

      widget.onRecipeUpdated(recipe);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resep berhasil diperbarui')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF4F3A38)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Detail Resep',
          style: TextStyle(
            color: Color(0xFF4F3A38),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (recipe.owner == widget.userName)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF4F3A38)),
              onPressed: _editRecipe,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imagePath != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: getImageProvider(recipe.imagePath!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.image_not_supported, size: 60),
              ),

            const SizedBox(height: 20),

            Text(
              recipe.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F3A38),
              ),
            ),

            const SizedBox(height: 10),

            if (recipe.category.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4081),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recipe.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            if (recipe.owner == widget.userName)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEE4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline),
                    const SizedBox(width: 8),
                    const Text('Privatkan resep ini'),
                    const Spacer(),
                    Switch(
                      value: recipe.isPrivate,
                      onChanged: (value) {
                        setState(() {
                          recipe.isPrivate = value;
                          recipe.isPublic = !value;
                        });

                        widget.onRecipeUpdated(recipe);
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),

            const Text(
              'Bahan-Bahan:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEEE4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(recipe.description),
            ),

            const SizedBox(height: 20),

            const Text(
              'Langkah-Langkah:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEEE4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(recipe.steps),
            ),

            const SizedBox(height: 30),

            if (recipe.isPublic) ...[
              Text(
                '⭐ ${recipe.averageRating.toStringAsFixed(1)} / 5.0',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text('Berdasarkan ${recipe.ratings.length} ulasan'),

              const SizedBox(height: 20),

              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedRating = index + 1),
                    child: Icon(
                      selectedRating > index
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.orange,
                      size: 35,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (commentController.text.isNotEmpty &&
                        selectedRating > 0) {
                      _addComment(commentController.text);
                      _addRating(selectedRating);

                      commentController.clear();

                      setState(() {
                        selectedRating = 0;
                      });
                    }
                  },
                  child: const Text('Kirim Review'),
                ),
              ),

              const SizedBox(height: 20),

              ...recipe.comments.map(
                (comment) => ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(comment.author),
                  subtitle: Text(comment.text),
                  trailing: Text(
                    _formatTime(comment.timestamp),
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}