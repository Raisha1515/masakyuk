import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'trending_page.dart';
import 'dashboard.dart';
import 'login.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFFBF0EF);
    final cardBg = const Color(0xFFF9EADA);

    Widget trendingCard(int index, String title, String image, String likes, String comments, String status) {
      return Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                  child: Image.asset(
                    image,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.orange,
                    child: Text('${index}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite, size: 14, color: Colors.red),
                      const SizedBox(width: 6),
                      Text(likes, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(comments, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(status == 'Naik' ? Icons.arrow_upward : Icons.remove, size: 14, color: status == 'Naik' ? Colors.green : Colors.grey),
                      const SizedBox(width: 6),
                      Text(status, style: const TextStyle(fontSize: 12)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
    }

    Widget recipeCard(String title, String image) {
      return GestureDetector(
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Buka $title'))),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0,4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Image.asset(image, height: 100, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: Row(
                  children: const [
                    Icon(Icons.favorite, color: Colors.red, size: 14),
                    SizedBox(width: 6),
                    Text('2.4rb', style: TextStyle(fontSize: 12)),
                    SizedBox(width: 12),
                    Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text('318', style: TextStyle(fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tambah Resep'))),
        backgroundColor: const Color(0xFFF9EADA),
        child: const Icon(Icons.add, color: Color(0xFF4F3A38)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifikasi'))),
                icon: const Icon(Icons.notifications_outlined),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favorit'))),
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Hi, Pengguna 👋', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final savedUser = prefs.getString('username');
                        final savedPass = prefs.getString('password');

                        if (savedUser != null && savedPass != null && savedUser.isNotEmpty && savedPass.isNotEmpty) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Dashboard()));
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                        }
                      },
                      child: ClipOval(
                        child: Image.asset('assets/images/2.png', width: 44, height: 44, fit: BoxFit.cover),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),

                // Search bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: const [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(child: Text('search', style: TextStyle(color: Colors.grey))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter'))), icon: const Icon(Icons.tune)),
                    )
                  ],
                ),

                const SizedBox(height: 18),

                // Trending header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.local_fire_department, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Lagi Trending', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TrendingPage()),
                        );
                      },
                      child: const Text('Lihat Semua'),
                    )
                  ],
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 170,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      trendingCard(1, 'Resep Rendang', 'assets/images/1.png', '2.4rb', '318', 'Naik'),
                      trendingCard(2, 'Nasi Goreng', 'assets/images/2.png', '1.8rb', '241', 'Naik'),
                      trendingCard(3, 'Opor Ayam', 'assets/images/1.png', '1.2rb', '190', 'Stabil'),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Semua Resep header & chips
                const Text('Semua Resep', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ChoiceChip(label: const Text('Semua'), selected: true, onSelected: (_){}),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('Minggu Ini'), selected: false, onSelected: (_){ }),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('Bulan Ini'), selected: false, onSelected: (_){ }),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('Terpopuler'), selected: false, onSelected: (_){ }),
                    ].map((w) => Padding(padding: const EdgeInsets.only(right: 8.0), child: w)).toList(),
                  ),
                ),

                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    recipeCard('Resep Nasi Goreng', 'assets/images/2.png'),
                    recipeCard('Resep Rendang', 'assets/images/1.png'),
                    recipeCard('Resep Gule Kambing', 'assets/images/1.png'),
                    recipeCard('Resep Opor Ayam', 'assets/images/2.png'),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
