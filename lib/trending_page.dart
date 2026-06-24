import 'package:flutter/material.dart';
import 'package:masakyuk/services/recipe_service.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  int selectedChip = 0;
  final RecipeService _recipeService = RecipeService();
  
  List<Map<String, dynamic>> trendingRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrendingData();
  }

  Future<void> _loadTrendingData() async {
    setState(() => _isLoading = true);
    final data = await _recipeService.getTrendingRecipes();
    if (mounted) {
      setState(() {
        trendingRecipes = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Semua', 'Sarapan', 'Makan Siang', 'Makan Malam', 'Diet', 'Dessert'];
    final currentCategory = categories[selectedChip];

    final filteredRecipes = trendingRecipes.where((recipe) {
      if (currentCategory == 'Semua') return true;
      return recipe['category'] == currentCategory;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF0EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF0EF),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Menu Terpopuler",
          style: TextStyle(
            color: Color(0xFF4F3A38),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PERBAIKAN ERROR OVERFLOW: Menggunakan scroll horizontal agar filter aman tidak patah
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(categories.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildChip(index, categories[index]),
                  );
                }),
              ),
            ),
          ),
          
          // Konten Utama List Resep Trending
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4081)),
                    ),
                  )
                : filteredRecipes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_fire_department_outlined, size: 60, color: const Color(0xFFD9ACA3).withOpacity(0.6)),
                            const SizedBox(height: 12),
                            const Text(
                              "Belum ada resep trending di kategori ini.",
                              style: TextStyle(color: Color(0xFF8E6F6A), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final item = filteredRecipes[index];
                          final rank = index + 1;
                          
                          final title = item['title'] ?? 'Tanpa Judul';
                          final imageUrl = item['image_url'] as String?;
                          final rating = (item['avg_rating'] as num? ?? 0).toDouble();
                          final commentCount = (item['comment_count'] as num? ?? 0).toInt();
                          final category = item['category'] ?? 'Umum';

                          // Warna Badge Berdasarkan Rank Terpopuler (Emas, Perak, Perunggu)
                          Color rankColor = const Color(0xFFD88A94);
                          if (rank == 1) rankColor = const Color(0xFFFFD700);
                          if (rank == 2) rankColor = const Color(0xFFC0C0C0);
                          if (rank == 3) rankColor = const Color(0xFFCD7F32);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD9ACA3).withOpacity(0.15),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bagian Gambar Banner Atas Card
                                  Stack(
                                    children: [
                                      imageUrl != null
                                          ? Image.network(
                                              imageUrl,
                                              width: double.infinity,
                                              height: 160,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) => Container(
                                                width: double.infinity,
                                                height: 160,
                                                color: const Color(0xFFF0E0DD),
                                                child: const Icon(Icons.broken_image, color: Colors.grey),
                                              ),
                                            )
                                          : Container(
                                              width: double.infinity,
                                              height: 160,
                                              color: const Color(0xFFF0E0DD),
                                              child: const Icon(Icons.fastfood, size: 40, color: Color(0xFFD9ACA3)),
                                            ),
                                      // Soft gradient overlay di atas gambar
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withOpacity(0.3),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Badge Nomor Urut Rank Modern
                                      Positioned(
                                        left: 12,
                                        top: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: rankColor,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.15),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ]
                                          ),
                                          child: Text(
                                            'Trending #$rank',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Kategori Badge di Pojok Kanan Atas
                                      Positioned(
                                        right: 12,
                                        top: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4F3A38).withOpacity(0.85),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            category,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Detail Informasi bawah gambar resep
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xFF4F3A38),
                                            letterSpacing: 0.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              rating.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 13, 
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF4F3A38),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Color(0xFF8E6F6A)),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$commentCount komentar',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF8E6F6A),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            const Text(
                                              'Lihat Detail',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF4081),
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFFF4081)),
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

  Widget _buildChip(int idx, String label) {
    final selected = selectedChip == idx;
    return ChoiceChip(
      label: Text(
        label, 
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF4F3A38),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      selected: selected,
      onSelected: (_) => setState(() => selectedChip = idx),
      selectedColor: const Color(0xFFFF4081),
      backgroundColor: Colors.white,
      shadowColor: const Color(0xFFD9ACA3).withOpacity(0.2),
      elevation: selected ? 2 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.transparent : const Color(0xFFEFE5E3),
          width: 1,
        ),
      ),
    );
  }
}