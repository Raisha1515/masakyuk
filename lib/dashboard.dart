import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:masakyuk/models/recipe_model.dart';
import 'package:masakyuk/services/recipe_service.dart';
import 'package:masakyuk/services/favorite_service.dart';
import 'package:masakyuk/services/auth_service.dart';
import 'package:masakyuk/services/user_service.dart';
import 'package:masakyuk/models/user_model.dart';
import 'package:masakyuk/tambah_resep.dart';
import 'package:masakyuk/login.dart';
import 'package:masakyuk/private_recipes_page.dart';
import 'trending_page.dart';
import 'package:masakyuk/recipe_detail_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late AuthService authService;
  late RecipeService recipeService;
  late FavoriteService favoriteService;
  late UserService userService;

  List<Recipe> recipeList = [];
  List<Recipe> favoriteRecipesList = [];
  List<String> notificationList = [];
  List<Map<String, dynamic>> realtimeTrendingList = [];
  int _selectedIndex = 0;
  String selectedCategory = "Semua";

  UserProfile? userProfile;
  String? userId;
  bool isLoading = true;

  final TextEditingController _nameEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authService = AuthService();
    recipeService = RecipeService();
    favoriteService = FavoriteService();
    userService = UserService();

    userId = authService.getCurrentUserId();
    _loadAllData();
  }

  // Menarik seluruh data master agar terhubung realtime ke database
  Future<void> _loadAllData() async {
    if (userId == null) {
      _logout();
      return;
    }

    setState(() => isLoading = true);

    await Future.wait([
      _loadUserProfile(),
      _loadRecipesData(),
      _loadFavoritesData(),
      _loadTrendingData(),
    ]);

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await userService.getCurrentUser();
      if (mounted) setState(() => userProfile = profile);
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // REALTIME FIX: Mengambil data resep publik lengkap beserta relasi rating & comment langsung dari database
  Future<void> _loadRecipesData() async {
    try {
      final data = await Supabase.instance.client
          .from('recipes')
          .select('''
            id, title, description, steps, category, image_url, is_public, is_private, user_id, created_at, updated_at,
            user_profiles(username),
            comments(id, text, created_at, user_id, user_profiles(username)),
            ratings(id, stars, created_at, user_id)
          ''')
          .eq('is_public', true)
          .order('created_at', ascending: false);

      final List<Recipe> recipes = (data as List).map((item) {
        // Mapping komentar relasi database
        final rawComments = item['comments'] as List? ?? [];
        final List<Comment> comments = rawComments.map((c) {
          final up = c['user_profiles'] as Map<String, dynamic>?;
          return Comment(
            id: c['id'] as String,
            author: up?['username'] as String? ?? 'Unknown',
            text: c['text'] as String? ?? '',
            timestamp: DateTime.parse(c['created_at'] as String),
            userId: c['user_id'] as String?,
          );
        }).toList();

        // Mapping rating relasi database
        final rawRatings = item['ratings'] as List? ?? [];
        final List<Rating> ratings = rawRatings.map((r) {
          return Rating(
            id: r['id'] as String,
            stars: (r['stars'] as num? ?? 0).toInt(),
            timestamp: DateTime.parse(r['created_at'] as String),
            userId: r['user_id'] as String?,
          );
        }).toList();

        return Recipe(
          id: item['id'] as String,
          name: item['title'] as String? ?? 'Tanpa Judul',
          imageUrl: item['image_url'] as String?,
          description: item['description'] as String? ?? '',
          steps: item['steps'] as String? ?? '',
          category: item['category'] as String? ?? '',
          owner: item['user_profiles']?['username'] as String? ?? 'User',
          userId: item['user_id'] as String?,
          isPublic: item['is_public'] as bool? ?? true,
          isPrivate: item['is_private'] as bool? ?? false,
          comments: comments,
          ratings: ratings,
        );
      }).toList();

      if (mounted) setState(() => recipeList = recipes);
    } catch (e) {
      print('Error loading comprehensive recipes: $e');
    }
  }

  Future<void> _loadFavoritesData() async {
    try {
      final favorites = await favoriteService.getUserFavorites(userId!);
      if (mounted) setState(() => favoriteRecipesList = favorites);
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _loadTrendingData() async {
    try {
      final data = await recipeService.getTrendingRecipes();
      if (mounted) setState(() => realtimeTrendingList = data);
    } catch (e) {
      print('Error loading trending: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await authService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout error: $e')),
      );
    }
  }

  void _backToHome() {
    setState(() => _selectedIndex = 0);
  }

  ImageProvider getImageProvider(String imagePath) {
    if (kIsWeb) {
      return NetworkImage(imagePath);
    } else {
      return FileImage(File(imagePath));
    }
  }

  // Refresher Beranda pemicu reload realtime data relasi
  Future<void> _loadRecipes() async {
    await _loadRecipesData();
  }

  void _showRecipeDetail(Recipe recipe) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailPage(
          recipe: recipe,
          userName: userProfile?.username ?? 'User',
          onRecipeUpdated: (updatedRecipe) {
            _loadRecipesData(); // Auto reload dari DB jika ada update/comment baru di page detail
          },
        ),
      ),
    );

    if (result == "deleted" || result != null) {
      _loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;
    if (_selectedIndex == 0) {
      currentBody = buildHomePage();
    } else if (_selectedIndex == 1) {
      currentBody = const TrendingPage(); 
    } else if (_selectedIndex == 2) {
      currentBody = buildFavoritePage(); 
    } else if (_selectedIndex == 3) {
      currentBody = buildNotificationPage();
    } else {
      currentBody = buildProfilePage(); 
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF0EF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pink))
          : currentBody, 
      
      floatingActionButton: isLoading 
          ? null 
          : FloatingActionButton(
              backgroundColor: const Color(0xFFFF4081),
              shape: const CircleBorder(),
              elevation: 4,
              child: const Icon(Icons.add, size: 32, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahResep()),
                );
                if (result != null) {
                  _loadAllData();
                }
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex >= 4 ? 3 : (_selectedIndex == 3 ? 0 : _selectedIndex), 
        onTap: (index) {
          setState(() {
            if (index == 0) _selectedIndex = 0;
            if (index == 1) _selectedIndex = 1;
            if (index == 2) _selectedIndex = 2;
            if (index == 3) _selectedIndex = 4; 
          });
          
          if (index == 0) _loadRecipes();
          if (index == 2) _loadAllData();
          if (index == 3) _loadAllData(); 
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFF4081),
        unselectedItemColor: const Color(0xFF8E6F6A),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Trending'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Tersimpan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'), 
        ],
      ),
    );
  }

  Widget buildNotificationPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4F3A38)),
                onPressed: _backToHome,
              ),
              const Text("Notifikasi", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38))),
            ],
          ),
        ),
        Expanded(
          child: notificationList.isEmpty
              ? const Center(child: Text("Belum ada notifikasi."))
              : ListView.builder(
                  itemCount: notificationList.length,
                  itemBuilder: (context, index) {
                    final reverseIndex = notificationList.length - 1 - index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCEEE4),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink, size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              notificationList[reverseIndex],
                              style: const TextStyle(
                                color: Color(0xFF4F3A38),
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget trendingCard(int rank, Map<String, dynamic> item) {
    final String title = item['title'] ?? 'Tanpa Judul';
    final String? imageUrl = item['image_url'] as String?;
    final double rating = (item['avg_rating'] as num? ?? 0).toDouble();
    final int commentCount = (item['comment_count'] as num? ?? 0).toInt();
    final String category = item['category'] ?? 'Umum';

    final List<Color> rankColors = [
      const Color(0xFFFFC107), 
      const Color(0xFF9E9E9E), 
      const Color(0xFFCD7F32), 
    ];
    final Color rankColor =
        rank <= 3 ? rankColors[rank - 1] : const Color(0xFFD88A94);

    return Container(
      width: 165,
      margin: const EdgeInsets.only(right: 12, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD9ACA3).withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 85,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: double.infinity,
                          height: 85,
                          color: const Color(0xFFF0E0DD),
                          child: const Icon(Icons.broken_image, color: Colors.grey, size: 20),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 85,
                        color: const Color(0xFFF0E0DD),
                        child: const Icon(Icons.fastfood, color: Color(0xFFD9ACA3), size: 20),
                      ),
              ),
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4081).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF4F3A38),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38)),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: Color(0xFF8E6F6A)),
                    const SizedBox(width: 3),
                    Text(
                      '$commentCount',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF8E6F6A)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomePage() {
    List<Recipe> visibleRecipes = recipeList
        .where((r) => !r.isPrivate || r.userId == userId)
        .toList();

    List<Recipe> filteredRecipes = selectedCategory == "Semua"
        ? visibleRecipes
        : visibleRecipes.where((r) => r.category == selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hi, ${userProfile?.username ?? 'User'}",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F3A38),
                ),
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: 30, color: Color(0xFF4F3A38)),
                        onPressed: () => setState(() => _selectedIndex = 3),
                      ),
                      if (notificationList.isNotEmpty)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '${notificationList.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 4),
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFCEEE4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Color(0xFFD9ACA3)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFFCEEE4),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Cari resep...",
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _filterItem("Semua", "🍽️"),
              _filterItem("Sarapan", "🍳"),
              _filterItem("Makan Siang", "🍲"),
              _filterItem("Makan Malam", "🍱"),
              _filterItem("Diet", "🥬"),
              _filterItem("Dessert", "🍰"),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Lagi Trending',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4F3A38)),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrendingPage()),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: const [
                      Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 13, 
                          color: Color(0xFFFF4081)
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFFF4081)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: realtimeTrendingList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data trending.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: realtimeTrendingList.length > 5
                      ? 5
                      : realtimeTrendingList.length,
                  itemBuilder: (context, index) {
                    return trendingCard(index + 1, realtimeTrendingList[index]);
                  },
                ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: filteredRecipes.isEmpty
              ? const Center(
                  child: Text("Belum ada resep di kategori ini.", style: TextStyle(color: Color(0xFF4F3A38))),
                )
              : buildGrid(filteredRecipes, isFavoritePage: false),
        ),
      ],
    );
  }

  // HUBUNGAN REALTIME: Data stars, komen, & love terintergrasi penuh sesuai Supabase
  Widget resepCard(Recipe recipe, int index) {
    bool isFavorited = favoriteRecipesList.any((r) => r.id == recipe.id);
    final bool isOwner = recipe.userId == userId;
    
    // Logic pembacaan data dinamis sesuai database
    final double avgRating = recipe.ratings != null && recipe.ratings.isNotEmpty 
        ? recipe.ratings.map((r) => r.stars).reduce((a, b) => a + b) / recipe.ratings.length 
        : 0.0;
    final int commentCount = recipe.comments?.length ?? 0;

    return GestureDetector(
      onTap: () => _showRecipeDetail(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD9ACA3).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      image: recipe.imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(recipe.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: const Color(0xFFF0E0DD),
                    ),
                    child: recipe.imageUrl == null
                        ? const Center(
                            child: Icon(Icons.fastfood_rounded, size: 40, color: Color(0xFFD9ACA3)),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.45),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (recipe.category.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4081),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          recipe.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isOwner)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: recipe.isPrivate
                              ? const Color(0xFF6D4C41).withOpacity(0.85)
                              : const Color(0xFF43A047).withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              recipe.isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              recipe.isPrivate ? 'Privat' : 'Publik',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Badge Rating Atas Realtime
                  Positioned(
                    bottom: 7,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: avgRating >= 1
                            ? Colors.amber.withOpacity(0.92)
                            : Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            avgRating >= 1
                                ? avgRating.toStringAsFixed(1)
                                : 'Baru',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Badge Komen Atas Realtime
                  Positioned(
                    bottom: 7,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            '$commentCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF3E2723),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Love / Favorit Toggle dengan update database
                      GestureDetector(
                        onTap: () async {
                          try {
                            await favoriteService.toggleFavorite(
                              userId: userId!,
                              recipeId: recipe.id,
                            );
                            // Auto Sinkron state lokal setelah toggle favorit
                            _loadFavoritesData();
                            if (!isFavorited) {
                              setState(() {
                                notificationList.add("Resep ${recipe.name} ditambahkan ke favorit!");
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error Favorite: $e')),
                            );
                          }
                        },
                        child: Icon(
                          isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorited ? Colors.pink : const Color(0xFFBCAAA4),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Row Bintang Indikator Bawah Realtime
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < avgRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 13,
                          color: avgRating >= 1 ? Colors.amber : const Color(0xFFBCAAA4),
                        );
                      }),
                      const SizedBox(width: 5),
                      Text(
                        avgRating >= 1 ? avgRating.toStringAsFixed(1) : '-',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF8D6E63),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chat_bubble_outline_rounded, size: 12, color: Color(0xFF8D6E63)),
                      const SizedBox(width: 3),
                      Text(
                        '$commentCount',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF8D6E63)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRecipeDetail(recipe),
                      icon: const Icon(Icons.visibility_rounded, size: 14),
                      label: const Text('Lihat Detail', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4081),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFavoritePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: _backToHome,
              ),
              const Text("Favoritku", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: favoriteRecipesList.isEmpty
              ? const Center(child: Text("Belum ada favorit."))
              : buildGrid(favoriteRecipesList, isFavoritePage: true),
        ),
      ],
    );
  }

  Widget buildProfilePage() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 25),
            child: Text(
              "Profil Saya",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F3A38),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD9ACA3).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFFCEEE4),
                backgroundImage: userProfile?.avatarUrl != null
                    ? NetworkImage(userProfile!.avatarUrl!)
                    : null,
                child: userProfile?.avatarUrl == null
                    ? const Icon(Icons.person, size: 65, color: Color(0xFFD9ACA3))
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            userProfile?.username ?? 'User Pemanggang',
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF4F3A38),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            authService.getCurrentUserEmail() ?? 'Email tidak tersedia',
            style: const TextStyle(
              fontSize: 13, 
              color: Color(0xFF8E6F6A),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: const Text(
                "Nama Pengguna", 
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F3A38), fontSize: 14),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEFE5E3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD9ACA3).withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: TextField(
              controller: _nameEditController,
              style: const TextStyle(color: Color(0xFF4F3A38), fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                hintText: "Masukkan nama baru...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.badge_outlined, color: Color(0xFF8E6F6A), size: 22),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.lock_person_outlined, size: 18),
                    label: const Text('Resep Privat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F3A38),
                      side: const BorderSide(color: Color(0xFF4F3A38), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (userId == null) return;

                      try {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4081)),
                            ),
                          ),
                        );

                        final updatedList = await recipeService.getUserRecipes(userId!);

                        if (!mounted) return;
                        Navigator.pop(context);

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PrivateRecipesPage(
                              recipes: updatedList,
                              username: userProfile?.username ?? 'User',
                              onRecipeUpdated: (updatedRecipe) {
                                _loadRecipesData();
                              },
                              onRecipeDeleted: (deletedId) {
                                _loadAllData();
                              },
                            ),
                          ),
                        );
                      } catch (e) {
                        if (mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal mengambil resep privat: $e')),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: const Text("Simpan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4081),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      try {
                        if (_nameEditController.text.isNotEmpty) {
                          await userService.updateUserProfile(
                            userId: userId!,
                            username: _nameEditController.text,
                          );
                          _loadUserProfile();
                        }
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profil berhasil disimpan!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 60),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            label: const Text(
              "Keluar Akun", 
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildGrid(List<Recipe> list, {required bool isFavoritePage}) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return resepCard(list[index], index);
      },
    );
  }

  Widget _filterItem(String name, String emoji) {
    bool isSelected = selectedCategory == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = name;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4081) : const Color(0xFFFCEEE4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 5),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF4F3A38),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameEditController.dispose();
    super.dispose();
  }
}