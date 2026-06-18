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
    // Menyaring resep berdasarkan kategori yang dipilih dari ChoiceChip
    final categories = ['Semua', 'Sarapan', 'Makan Siang', 'Makan Malam'];
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
          'Sedang Trending🔥',
          style: TextStyle(color: Color(0xFF4F3A38), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Bagian Filter Kategori (ChoiceChips)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(categories.length, (idx) {
                return _buildChip(idx, categories[idx]);
              }),
            ),
          ),
          const SizedBox(height: 10),
          
          // Bagian List Resep Trending
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.pink))
                : filteredRecipes.isEmpty
                    ? const Center(child: Text('Tidak ada resep trending saat ini'))
                    : RefreshIndicator(
                        onRefresh: _loadTrendingData,
                        child: ListView.builder(
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final it = filteredRecipes[index];
                            final double rating = (it['avg_rating'] as num).toDouble();
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: it['image_url'] != null
                                      ? Image.network(
                                          it['image_url'],
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 70, height: 70, color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        )
                                      : Container(
                                          width: 70, height: 70, color: Colors.grey[300],
                                          child: const Icon(Icons.fastfood),
                                        ),
                                ),
                                title: Text(
                                  it['title'] ?? 'Tanpa Judul',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${rating.toStringAsFixed(1)} Rating'),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.comment, color: Colors.blue, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${it['comment_count']} Komentar'),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Kategori: ${it['category'] ?? 'Umum'}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFCEEE4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '#${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  // Navigasi ke halaman detail jika diperlukan, contoh:
                                  /*
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecipeDetailPage(
                                        recipe: Recipe.fromJson(it), // Konversi map ke model jika sudah siap
                                        userName: widget.username,
                                        onRecipeUpdated: (_) => _loadTrendingData(),
                                      ),
                                    ),
                                  );
                                  */
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(int idx, String label) {
    final selected = selectedChip == idx;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black)),
      selected: selected,
      onSelected: (_) => setState(() => selectedChip = idx),
      selectedColor: const Color(0xFFD88A94),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}