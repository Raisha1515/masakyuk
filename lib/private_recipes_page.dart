import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masakyuk/models/recipe_model.dart';
import 'package:masakyuk/recipe_detail_page.dart';

class PrivateRecipesPage extends StatefulWidget {
  final List<Recipe> recipes;
  final String username;
  final Function(Recipe) onRecipeUpdated;
  final Function(String) onRecipeDeleted;

  const PrivateRecipesPage({
    super.key, 
    required this.recipes, 
    required this.username,
    required this.onRecipeUpdated,
    required this.onRecipeDeleted,
  });

  @override
  State<PrivateRecipesPage> createState() => _PrivateRecipesPageState();
}

class _PrivateRecipesPageState extends State<PrivateRecipesPage> {
  late List<Recipe> localRecipes;

  @override
  void initState() {
    super.initState();
    localRecipes = widget.recipes;
  }

  ImageProvider getImageProvider(String imagePath) {
    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }
    if (imagePath.startsWith('http') || imagePath.startsWith('https') || imagePath.startsWith('blob:')) {
      return NetworkImage(imagePath);
    }
    if (kIsWeb) return NetworkImage(imagePath);
    return FileImage(File(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    // Mengecek resep privat milik user yang sedang aktif
    final myPrivate = localRecipes.where((r) => 
      (r.isPrivate == true || r.isPublic == false) && r.owner == widget.username
    ).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF0EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF0EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F3A38)), 
          onPressed: () => Navigator.pop(context)
        ),
        title: const Text('Resep Privat', style: TextStyle(color: Color(0xFF4F3A38), fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: myPrivate.isEmpty
                  ? const Center(child: Text('Belum ada resep privat.', style: TextStyle(color: Color(0xFF8E6F6A))))
                  : GridView.builder(
                      itemCount: myPrivate.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final r = myPrivate[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecipeDetailPage(
                                  recipe: r,
                                  userName: widget.username,
                                  onRecipeUpdated: (updated) {
                                    widget.onRecipeUpdated(updated);
                                    setState(() {
                                      int idx = localRecipes.indexWhere((element) => element.id == updated.id);
                                      if (idx != -1) localRecipes[idx] = updated;
                                    });
                                  },
                                ),
                              ),
                            );

                            if (result == "deleted") {
                              widget.onRecipeDeleted(r.id);
                              setState(() {
                                localRecipes.removeWhere((element) => element.id == r.id);
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), 
                                        child: r.imageUrl != null 
                                            ? Image(image: getImageProvider(r.imageUrl!), width: double.infinity, height: double.infinity, fit: BoxFit.cover) 
                                            : Container(color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey))
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(6), 
                                          decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle), 
                                          child: const Icon(Icons.lock, color: Colors.pink, size: 18)
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    r.name, 
                                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4F3A38)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}