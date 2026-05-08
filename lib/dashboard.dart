import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:masakyuk/models/recipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masakyuk/tambah_resep.dart';
import 'package:masakyuk/login.dart';
import 'package:masakyuk/recipe_detail_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Recipe> recipeList = [];
  Set<int> favoritedIndices = {};
  List<String> notificationList = []; 
  int _selectedIndex = 0; // 0: Home, 1: Notification, 2: Favorite, 3: Profile
  // Letakkan di bawah list-list data kamu
  String selectedCategory = "Semua";

  String userName = "Raisha";
  String userPassword = "";

  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _passEditController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _saveAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", userName);
    await prefs.setString("password", userPassword);

    List<String> recipeJsonList = recipeList.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList("saved_recipes", recipeJsonList);
    await prefs.setStringList("saved_notifications", notificationList);

    List<String> favList = favoritedIndices.map((i) => i.toString()).toList();
    await prefs.setStringList("saved_favorites", favList);
  }

  Future<void> _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("username") ?? "Raisha";
      userPassword = prefs.getString("password") ?? "";
      notificationList = prefs.getStringList("saved_notifications") ?? [];

      List<String>? savedJsonRecipes = prefs.getStringList("saved_recipes");
      if (savedJsonRecipes != null) {
        recipeList = savedJsonRecipes.map((item) {
          Map<String, dynamic> map = jsonDecode(item);
          // Backward compatibility: generate ID for old recipes
          if (map['id'] == null || map['id'].isEmpty) {
            map['id'] = 'recipe_${map.hashCode}_${recipeList.length}';
          }
          return Recipe.fromJson(map);
        }).toList();
      }

      List<String>? savedFavs = prefs.getStringList("saved_favorites");
      if (savedFavs != null) {
        favoritedIndices = savedFavs.map((i) => int.parse(i)).toSet();
      }
    });
  }

  void _backToHome() {
    setState(() => _selectedIndex = 0);
  }

  // Helper method untuk display gambar yang support web dan mobile
  ImageProvider getImageProvider(String imagePath) {
    if (kIsWeb) {
      // Di web, imagePath adalah blob URL
      return NetworkImage(imagePath);
    } else {
      // Di mobile, imagePath adalah file path
      return FileImage(File(imagePath));
    }
  }

  void _showRecipeDetail(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(
          recipe: recipe,
          userName: userName, // Kirim nama pengguna ke halaman detail
          onRecipeUpdated: (updatedRecipe) {
            setState(() {
              int index = recipeList.indexWhere((r) => r.id == updatedRecipe.id);
              if (index != -1) {
                recipeList[index] = updatedRecipe;
              }
            });
            _saveAllData();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_selectedIndex == 3) {
      bodyContent = buildProfilePage();
    } else if (_selectedIndex == 2) {
      bodyContent = buildFavoritePage();
    } else if (_selectedIndex == 1) {
      bodyContent = buildNotificationPage();
    } else {
      bodyContent = buildHomePage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3),
      body: SafeArea(child: bodyContent),
      bottomNavigationBar: buildBottomNavbar(),
    );
  }

  // --- HALAMAN NOTIFIKASI ---
  Widget buildNotificationPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4F3A38)), onPressed: _backToHome),
              const Text("Notifikasi", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38))),
            ],
          ),
        ),
        Expanded(
          child: notificationList.isEmpty
              ? const Center(child: Text("Belum ada riwayat notifikasi."))
              : ListView.builder(
                  itemCount: notificationList.length,
                  itemBuilder: (context, index) {
                    final reverseIndex = notificationList.length - 1 - index;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: const Color(0xFFFCEEE4), borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink, size: 28),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              notificationList[reverseIndex],
                              style: const TextStyle(color: Color(0xFF4F3A38), fontWeight: FontWeight.w500, fontSize: 15),
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

  // --- HALAMAN HOME ---
  Widget buildHomePage() {
    List<Recipe> filteredRecipes = selectedCategory == "Semua"
      ? recipeList
      : recipeList.where((r) => r.category == selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Hi, $userName", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38))),
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, size: 30, color: Color(0xFF4F3A38)),
                        onPressed: () => setState(() => _selectedIndex = 1),
                      ),
                      if (notificationList.isNotEmpty)
                        Positioned(
                          right: 8, top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text('${notificationList.length}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 3),
                    child: Container(width: 45, height: 45, decoration: const BoxDecoration(color: Color(0xFFFCEEE4), shape: BoxShape.circle), child: const Icon(Icons.person, color: Color(0xFFD9ACA3))),
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
            decoration: BoxDecoration(color: const Color(0xFFFCEEE4), borderRadius: BorderRadius.circular(25)),
            child: const TextField(decoration: InputDecoration(hintText: "Cari resep...", border: InputBorder.none, icon: Icon(Icons.search))),
          ),
        ),
        const SizedBox(height: 15),
        
        // Baris Filter yang bisa digeser (Scrollable)
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
        const SizedBox(height: 20),
        Expanded(
          child: filteredRecipes.isEmpty
              ? const Center(
                  child: Text(
                    "Belum ada resep di kategori ini.",
                    style: TextStyle(color: Color(0xFF4F3A38)),
                  ),
                )
              : buildGrid(filteredRecipes, isFavoritePage: false),
        ),
      ],
    );
  }

  // --- BOTTOM NAVBAR (3 ICON) ---
  Widget buildBottomNavbar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFFFCEEE4), 
        borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(35))
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(_selectedIndex == 2 ? Icons.favorite : Icons.favorite_border, size: 30, color: _selectedIndex == 2 ? Colors.pink : const Color(0xFF4F3A38)), 
            onPressed: () => setState(() => _selectedIndex = 2)
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 50, color: Color(0xFFFF4081)), 
            onPressed: () async {
              final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const TambahResep()));
              if (result != null && result is Recipe) { 
                setState(() => recipeList.add(result)); 
                _saveAllData(); 
              }
            }
          ),
          IconButton(
            icon: Icon(Icons.home_outlined, size: 30, color: _selectedIndex == 0 ? Colors.pink : const Color(0xFF4F3A38)), 
            onPressed: _backToHome
          ),
        ],
      ),
    );
  }

  // --- CARD RESEP ---
  Widget resepCard(Recipe recipe, int index) {
    bool isFavorited = favoritedIndices.contains(index);
    return GestureDetector(
      onTap: () => _showRecipeDetail(recipe),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFFCEEE4), borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      image: recipe.imagePath != null
                          ? DecorationImage(
                              image: getImageProvider(recipe.imagePath!),
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
                  if (recipe.isPublic && recipe.ratings.isNotEmpty)
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
                        onTap: () {
                          setState(() {
                            if (isFavorited) {
                              favoritedIndices.remove(index);
                            } else {
                              favoritedIndices.add(index);
                              notificationList.add("Resep ${recipe.name} berhasil ditambahkan ke favorit!");
                            }
                          });
                          _saveAllData();
                        },
                        child: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, color: Colors.pink, size: 20),
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
    List<Recipe> favoriteRecipes = favoritedIndices.map((i) => recipeList[i]).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: _backToHome), const Text("Favoritku", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
        ),
        Expanded(child: favoriteRecipes.isEmpty ? const Center(child: Text("Belum ada favorit.")) : buildGrid(favoriteRecipes, isFavoritePage: true)),
      ],
    );
  }

  // --- HALAMAN PROFIL (DENGAN LOGOUT) ---
  Widget buildProfilePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: _backToHome), const Text("Profil Saya", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))]),
          ),
          const CircleAvatar(radius: 70, backgroundColor: Color(0xFFFCEEE4), child: Icon(Icons.person, size: 80, color: Color(0xFFD9ACA3))),
          const SizedBox(height: 15),
          Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          buildEditField("Edit Profil :", "Masukkan nama baru...", _nameEditController, Icons.edit_note),
          buildEditField("Ubah Kata Sandi :", "Masukkan sandi baru...", _passEditController, Icons.lock_outline),
          const SizedBox(height: 30),
          
          // TOMBOL SIMPAN
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (_nameEditController.text.isNotEmpty) userName = _nameEditController.text;
                if (_passEditController.text.isNotEmpty) userPassword = _passEditController.text;
              });
              _saveAllData();
              _nameEditController.clear();
              _passEditController.clear();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil disimpan!")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F3A38), minimumSize: const Size(200, 45)),
            child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
          ),

          const SizedBox(height: 15),

          // TOMBOL LOGOUT
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), minimumSize: const Size(200, 45)),
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8, crossAxisSpacing: 15, mainAxisSpacing: 15),
      itemBuilder: (context, index) {
        int originalIndex = isFavoritePage ? recipeList.indexOf(list[index]) : index;
        return resepCard(list[index], originalIndex);
      },
    );
  }

  Widget buildEditField(String label, String hint, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFFFCEEE4), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: const Color(0xFF4F3A38)), const SizedBox(width: 10), Text(label, style: const TextStyle(fontWeight: FontWeight.bold))]),
          TextField(controller: controller, decoration: InputDecoration(hintText: hint, border: InputBorder.none)),
        ],
      ),
    );
  }


  //Fitur Filter kategori
  Widget _filterItem(String name, String emoji) {
  bool isSelected = selectedCategory == name;
  return GestureDetector(
    onTap: () {
      setState(() {
        selectedCategory = name; // Update kategori saat diklik
      });
    },
    child: Container(
      margin: const EdgeInsets.only(right: 10), // Jarak antar tombol
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
}