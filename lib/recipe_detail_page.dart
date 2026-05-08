import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:masakyuk/models/recipe_model.dart';
import 'package:masakyuk/tambah_resep.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final String userName; // Tambahkan ini
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
    final ratingId = 'rating_${DateTime.now().millisecondsSinceEpoch}';
    final newRating = Rating(
      id: ratingId,
      stars: stars,
      timestamp: DateTime.now(),
    );
    setState(() {
      recipe.ratings.add(newRating);
    });
    widget.onRecipeUpdated(recipe);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating berhasil ditambahkan!')));
  }

  void _addComment(String text) {
    final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';
    final newComment = Comment(
      id: commentId,
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
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d lalu';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4F3A38)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Detail Resep',
          style: TextStyle(color: Color(0xFF4F3A38), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF4F3A38)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahResep(recipe: recipe),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[300],
                  ),
                  child: const Icon(Icons.image_not_supported, size: 60),
                ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38)),
                        ),
                        const SizedBox(height: 8),
                        if (recipe.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4081),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              recipe.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              const Text(
                'Bahan-Bahan:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEE4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recipe.description,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                'Langkah-Langkah:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38)),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEE4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recipe.steps,
                  style: const TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
              const SizedBox(height: 30),

              if (recipe.isPublic) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2D8D0),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review & Komentar',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A2C2A)),
                      ),
                      const SizedBox(height: 20),

                      Center(
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: recipe.averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A2C2A),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' / 5.0',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFF4A2C2A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Icon(
                                  index < recipe.averageRating.floor()
                                      ? Icons.star
                                      : (index < recipe.averageRating ? Icons.star_half : Icons.star_border),
                                  color: Colors.orangeAccent,
                                  size: 30,
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Berdasarkan ${recipe.ratings.length} ulasan',
                              style: TextStyle(color: Colors.grey[700], fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      if (recipe.comments.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Komentar Pengguna:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A2C2A)),
                            ),
                            const SizedBox(height: 15),
                            ...recipe.comments.map((comment) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Color(0xFFD9ACA3),
                                      child: Icon(Icons.person, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                comment.author,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                  color: Color(0xFF4A2C2A),
                                                ),
                                              ),
                                              Text(
                                                _formatTime(comment.timestamp),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            comment.text,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF2D2D2D)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            const Divider(height: 30, thickness: 1),
                          ],
                        ),

                      const SizedBox(height: 15),
                      const Text(
                        'Tulis Review Anda',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A2C2A)),
                      ),
                      const SizedBox(height: 12),

                      const Text(
                        'Berikan Rating:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () => setState(() => selectedRating = index + 1),
                            child: Icon(
                              selectedRating > index ? Icons.star : Icons.star_border,
                              color: Colors.orangeAccent,
                              size: 40,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: commentController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar Anda di sini...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (commentController.text.isNotEmpty && selectedRating > 0) {
                              _addComment(commentController.text);
                              _addRating(selectedRating);
                              commentController.clear();
                              setState(() => selectedRating = 0);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Review berhasil ditambahkan!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Silakan isi rating dan komentar')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A1C1C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Kirim Review',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
