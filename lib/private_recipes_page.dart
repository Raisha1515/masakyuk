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
    // Mengecek resep privat milik user yang sedang aktif dengan toleransi nama kosong lokal
    final myPrivate = localRecipes.where((r) {
      final statusPrivat = (r.isPrivate == true || r.isPublic == false);
      final statusPemilik = (r.owner == widget.username || r.owner == 'Unknown' || r.owner == 'User' || r.owner == '');
      return statusPrivat && statusPemilik;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF0EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF0EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4F3A38)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Resep Privat Saya",
          style: TextStyle(
            color: Color(0xFF4F3A38),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Total: ${myPrivate.length} Resep Terkunci",
              style: const TextStyle(
                color: Color(0xFF8E6F6A),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: myPrivate.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 70, color: const Color(0xFFD9ACA3).withOpacity(0.6)),
                        const SizedBox(height: 16),
                        const Text(
                          "Belum ada resep privat.",
                          style: TextStyle(
                            color: Color(0xFF4F3A38),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: myPrivate.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
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
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD9ACA3).withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bagian Gambar & Badge Pengunci
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                        image: r.imageUrl != null
                                            ? DecorationImage(
                                                image: getImageProvider(r.imageUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: const Color(0xFFF0E0DD),
                                      ),
                                      child: r.imageUrl == null
                                          ? const Center(
                                              child: Icon(Icons.fastfood_rounded, size: 40, color: Color(0xFFD9ACA3)),
                                            )
                                          : null,
                                    ),
                                    // Gradient overlay bawah gambar agar estetik
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.2),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // PERBAIKAN ICON GEMBOK: Bulat sempurna & Tengah Simetris
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.lock_rounded, 
                                            color: Color(0xFFFF4081), 
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Badge Kategori Tambahan biar makin premium
                                    if (r.category.isNotEmpty)
                                      Positioned(
                                        left: 10,
                                        top: 10,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4F3A38).withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            r.category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Bagian Informasi Judul Teks Resep privat
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF4F3A38),
                                        letterSpacing: 0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: const [
                                        Icon(Icons.visibility_off_outlined, size: 12, color: Color(0xFF8E6F6A)),
                                        SizedBox(width: 4),
                                        Text(
                                          "Hanya Anda",
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF8E6F6A),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
    );
  }
}