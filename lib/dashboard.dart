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

  Future<void> _loadAllData() async {
    if (userId == null) {
      _logout();
      return;
    }

    setState(() => isLoading = true);

    // Semua bagian diload secara paralel & independen agar error di satu bagian
    // tidak menghentikan bagian lain (terutama trending)
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

  Future<void> _loadRecipesData() async {
    try {
      final recipes = await recipeService.getPublicRecipes();
      if (mounted) setState(() => recipeList = recipes);
    } catch (e) {
      print('Error loading recipes: $e');
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

  Future<void> _loadRecipes() async {
    try {
      // Mengambil seluruh resep (baik publik maupun privat) dari database
      final recipes = await recipeService.getPublicRecipes(); 
      if (mounted) {
        setState(() {
          recipeList = recipes;
        });
      }
    } catch (e) {
      print('Error loading recipes: $e');
    }
  }
  // void _showRecipeDetail(Recipe recipe) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => RecipeDetailPage(
  //         recipe: recipe,
  //         userName: userProfile?.username ?? 'User',
  //         onRecipeUpdated: (updatedRecipe) {
  //           setState(() {
  //             int idx = recipeList.indexWhere((r) => r.id == updatedRecipe.id);
  //             if (idx != -1) {
  //               recipeList[idx] = updatedRecipe;
  //             }
  //           });
  //         },
  //       ),
  //     ),
  //   );
  // }
  void _showRecipeDetail(Recipe recipe) async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RecipeDetailPage(
        recipe: recipe,
        userName: userProfile?.username ?? 'User',
        onRecipeUpdated: (updatedRecipe) {
          setState(() {
            int idx = recipeList.indexWhere((r) => r.id == updatedRecipe.id);
            if (idx != -1) {
              recipeList[idx] = updatedRecipe;
            }
          });
        },
      ),
    ),
  );

  // Jika result adalah "deleted", hapus dari list
  if (result == "deleted") {
    setState(() {
      recipeList.removeWhere((r) => r.id == recipe.id);
      favoriteRecipesList.removeWhere((r) => r.id == recipe.id);
    });
  }
}

  // @override
  // Widget build(BuildContext context) {
  //   Widget bodyContent;
  //   if (isLoading) {
  //     bodyContent = const Center(child: CircularProgressIndicator());
  //   } else if (_selectedIndex == 3) {
  //     bodyContent = buildProfilePage();
  //   } else if (_selectedIndex == 2) {
  //     bodyContent = buildFavoritePage();
  //   } else if (_selectedIndex == 1) {
  //     bodyContent = buildNotificationPage();
  //   } else {
  //     bodyContent = buildHomePage();
  //   }

  //   return Scaffold(
  //     backgroundColor: const Color(0xFFD9ACA3),
  //     body: SafeArea(child: bodyContent),
  //     bottomNavigationBar: buildBottomNavbar(),
  //   );
  // }
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
      
      // === KEMBALIKAN TOMBOL TAMBAH RESEP MENGGUNAKAN FLOATING ACTION BUTTON ===
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
                if (result != null && result is Recipe) {
                  result.userId = userId;
                  result.owner = userProfile?.username ?? 'User';
                  setState(() {
                    recipeList.add(result);
                  });
                }
              },
            ),
      // Posisi FAB diatur agar melayang pas di bagian tengah bawah, sedikit menjorok ke dalam navbar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomNavigationBar(
        // Sinkronisasi index visual navbar bawah
        currentIndex: _selectedIndex >= 4 ? 3 : (_selectedIndex == 3 ? 0 : _selectedIndex), 
        
        onTap: (index) {
          setState(() {
            if (index == 0) _selectedIndex = 0;
            if (index == 1) _selectedIndex = 1;
            if (index == 2) _selectedIndex = 2;
            if (index == 3) _selectedIndex = 4; // Menuju halaman profil asli (index 4)
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
          // Memberi space kosong (atau item dummy) di item navbar sebenarnya tidak perlu jika kita pakai layout standar,
          // tapi agar susunannya seimbang dengan tombol di tengah, kita pertahankan 4 item:
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

    // Warna rank badge: emas, perak, perunggu, sisanya pink
    final List<Color> rankColors = [
      const Color(0xFFFFC107), // #1 gold
      const Color(0xFF9E9E9E), // #2 silver
      const Color(0xFFCD7F32), // #3 bronze
    ];
    final Color rankColor =
        rank <= 3 ? rankColors[rank - 1] : const Color(0xFFD88A94);

    return Container(
      width: 175,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar + rank badge
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
                        height: 105,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: double.infinity,
                          height: 105,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: 105,
                        color: Colors.grey[200],
                        child: const Icon(Icons.fastfood, color: Colors.grey),
                      ),
              ),
              // Rank badge
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              // Kategori badge
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4081).withOpacity(0.88),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Info bawah
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF4F3A38),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.chat_bubble_outline, size: 13, color: Colors.blueGrey),
                    const SizedBox(width: 3),
                    Text(
                      '$commentCount',
                      style: const TextStyle(fontSize: 12),
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
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Lagi Trending',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TrendingPage()),
                  );
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: realtimeTrendingList.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada data trending.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: realtimeTrendingList.length > 5
                      ? 5
                      : realtimeTrendingList.length,
                  itemBuilder: (context, index) {
                    return trendingCard(index + 1, realtimeTrendingList[index]);
                  },
                ),
        ),
        const SizedBox(height: 20),
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

  Widget buildBottomNavbar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFFCEEE4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              _selectedIndex == 2 ? Icons.favorite : Icons.favorite_border,
              size: 30,
              color: _selectedIndex == 2 ? Colors.pink : const Color(0xFF4F3A38),
            ),
            onPressed: () => setState(() => _selectedIndex = 2),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 50, color: Color(0xFFFF4081)),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahResep()),
              );
              if (result != null && result is Recipe) {
                result.userId = userId;
                result.owner = userProfile?.username ?? 'User';
                setState(() {
                  recipeList.add(result);
                });
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.home_outlined,
              size: 30,
              color: _selectedIndex == 0 ? Colors.pink : const Color(0xFF4F3A38),
            ),
            onPressed: _backToHome,
          ),
        ],
      ),
    );
  }

  Widget resepCard(Recipe recipe, int index) {
    bool isFavorited = favoriteRecipesList.any((r) => r.id == recipe.id);

    return GestureDetector(
      onTap: () => _showRecipeDetail(recipe),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFCEEE4),
          borderRadius: BorderRadius.circular(20),
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
                      color: Colors.grey[300],
                    ),
                  ),
                  if (recipe.isPublic && recipe.category.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4081),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          recipe.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (recipe.ratings.isNotEmpty)
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 3),
                            Text(
                              recipe.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await favoriteService.toggleFavorite(
                              userId: userId!,
                              recipeId: recipe.id,
                            );
                            setState(() {
                              if (isFavorited) {
                                favoriteRecipesList.removeWhere((r) => r.id == recipe.id);
                              } else {
                                favoriteRecipesList.add(recipe);
                                notificationList.add("Resep ${recipe.name} ditambahkan ke favorit!");
                              }
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        },
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: Colors.pink,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton.icon(
                      onPressed: () => _showRecipeDetail(recipe),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Lihat Detail', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4081),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            )
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: _backToHome),
                const Text("Profil Saya", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          CircleAvatar(
            radius: 70,
            backgroundColor: const Color(0xFFFCEEE4),
            backgroundImage: userProfile?.avatarUrl != null
                ? NetworkImage(userProfile!.avatarUrl!)
                : null,
            child: userProfile?.avatarUrl == null
                ? const Icon(Icons.person, size: 80, color: Color(0xFFD9ACA3))
                : null,
          ),
          const SizedBox(height: 15),
          Text(
            userProfile?.username ?? 'User',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          buildEditField(
            "Edit Nama :",
            "Masukkan nama baru...",
            _nameEditController,
            Icons.edit_note,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivateRecipesPage(
                      recipes: recipeList,
                      username: userProfile?.username ?? 'User',
                      onRecipeUpdated: (updatedRecipe) {
                      // Ketika resep diperbarui di halaman detail, load ulang resep di dashboard
                    _loadRecipes(); 
                  },
                  onRecipeDeleted: (deletedId) {
                    // Ketika resep dihapus, load ulang resep di dashboard
                    _loadRecipes();
                  },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Resep Privat'),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              try {
                if (_nameEditController.text.isNotEmpty) {
                  await userService.updateUserProfile(
                    userId: userId!,
                    username: _nameEditController.text,
                  );
                  setState(() {
                    if (userProfile != null) {
                      userProfile = userProfile!.copyWith(
                        username: _nameEditController.text,
                      );
                    }
                  });
                }
                _nameEditController.clear();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profil disimpan!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F3A38),
              minimumSize: const Size(200, 45),
            ),
            child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(200, 45),
            ),
          ),
          const SizedBox(height: 30),
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
        childAspectRatio: 0.8,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        return resepCard(list[index], index);
      },
    );
  }

  Widget buildEditField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEEE4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF4F3A38)),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: hint, border: InputBorder.none),
          ),
        ],
      ),
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