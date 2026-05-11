import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masakyuk/models/recipe_model.dart';

class PrivateRecipesPage extends StatelessWidget {
  final List<Recipe> recipes;
  final String username;
  const PrivateRecipesPage({super.key, required this.recipes, required this.username});

  ImageProvider getImageProvider(String imagePath) {
    // Asset path
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
    final myPrivate = recipes.where((r) => r.isPrivate == true && r.owner == username).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF0EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF0EF),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF4F3A38)), onPressed: () => Navigator.pop(context)),
        title: const Text('Resep Privat', style: TextStyle(color: Color(0xFF4F3A38), fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              height: 46,
              decoration: BoxDecoration(color: const Color(0xFFF9EADA), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(children: const [Icon(Icons.search, color: Colors.grey), SizedBox(width: 8), Expanded(child: Text('search', style: TextStyle(color: Colors.grey)))],),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: myPrivate.isEmpty
                  ? const Center(child: Text('Belum ada resep privat'))
                  : GridView.builder(
                      itemCount: myPrivate.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemBuilder: (context, index) {
                        final r = myPrivate[index];
                        return Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: r.imagePath != null ? Image(image: getImageProvider(r.imagePath!), width: double.infinity, fit: BoxFit.cover) : Container(color: Colors.grey[300])),
                                    Positioned(
                                      right: 8,
                                      top: 8,
                                      child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle), child: const Icon(Icons.lock, color: Colors.pink)),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ),
                            ],
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
