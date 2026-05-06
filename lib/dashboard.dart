import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:masakyuk/models/recipe_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masakyuk/tambah_resep.dart';
import 'package:masakyuk/login.dart';

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

  void _addRating(Recipe recipe, int stars) {
    final ratingId = 'rating_${DateTime.now().millisecondsSinceEpoch}';
    final newRating = Rating(
      id: ratingId,
      stars: stars,
      timestamp: DateTime.now(),
    );
    recipe.ratings.add(newRating);
    _saveAllData();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rating berhasil ditambahkan!')));
  }

  void _addComment(Recipe recipe, String text) {
    final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';
    final newComment = Comment(
      id: commentId,
      author: userName,
      text: text,
      timestamp: DateTime.now(),
    );
    recipe.comments.add(newComment);
    _saveAllData();
    setState(() {});
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
    final TextEditingController commentController = TextEditingController();
    int selectedRating = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => SingleChildScrollView(
            controller: scrollController,
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
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5),
                            if (recipe.category.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF4081).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  recipe.category,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFFFF4081), fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Bahan-Bahan:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      recipe.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Langkah-Langkah:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      recipe.steps,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (recipe.isPublic) ...[
                    const Text(
                      'Rating & Ulasan:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (recipe.ratings.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '⭐ ${recipe.averageRating.toStringAsFixed(1)}',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '(${recipe.ratings.length} rating)',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Belum ada rating'),
                      ),

                    const SizedBox(height: 15),
                    const Text('Berikan Rating Anda:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedRating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              selectedRating > index ? '⭐' : '☆',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        );
                      }),
                    ),
                    if (selectedRating > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _addRating(recipe, selectedRating);
                              setModalState(() => selectedRating = 0);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF4081),
                            ),
                            child: const Text('Kirim Rating', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),

                    const SizedBox(height: 25),
                    const Text(
                      'Komentar:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    if (recipe.comments.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: recipe.comments.map((comment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.author,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        _formatTime(comment.timestamp),
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(comment.text, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Belum ada komentar'),
                      ),

                    const SizedBox(height: 15),
                    TextField(
                      controller: commentController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan komentar...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (commentController.text.isNotEmpty) {
                            _addComment(recipe, commentController.text);
                            commentController.clear();
                            setModalState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4081),
                        ),
                        child: const Text('Kirim Komentar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TambahResep(recipe: recipe),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Resep'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F3A38),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
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
        const SizedBox(height: 20),
        Expanded(
          child: recipeList.isEmpty
              ? const Center(child: Text("Belum ada resep."))
              : buildGrid(recipeList, isFavoritePage: false),
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
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFFCEEE4), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showRecipeDetail(recipe),
                  child: Container(
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
                        color: Colors.amber.withOpacity(0.9),
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
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
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
                  child: Icon(isFavorited ? Icons.favorite : Icons.favorite_border, color: Colors.pink, size: 22),
                )
              ],
            ),
          )
        ],
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
}