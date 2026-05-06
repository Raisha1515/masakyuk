import 'package:flutter/material.dart';

class TrendingPage extends StatefulWidget {
  const TrendingPage({super.key});

  @override
  State<TrendingPage> createState() => _TrendingPageState();
}

class _TrendingPageState extends State<TrendingPage> {
  int selectedChip = 0;

  final List<Map<String, dynamic>> items = [
    {'idx': 1, 'title': 'Resep Rendang', 'image': 'assets/images/1.png', 'likes': '10.2K', 'comments': '5.7K', 'status': 'Naik', 'trend': 'up'},
    {'idx': 2, 'title': 'Resep Nasi Goreng', 'image': 'assets/images/2.png', 'likes': '9.8K', 'comments': '4.3K', 'status': 'Naik', 'trend': 'up'},
    {'idx': 3, 'title': 'Resep Opor Ayam', 'image': 'assets/images/1.png', 'likes': '7.5K', 'comments': '3.2K', 'status': 'Stabil', 'trend': 'stable'},
    {'idx': 4, 'title': 'Resep Gule Kambing', 'image': 'assets/images/1.png', 'likes': '6.7K', 'comments': '3.8K', 'status': 'Naik', 'trend': 'up'},
    {'idx': 5, 'title': 'Bakwan Mendon', 'image': 'assets/images/2.png', 'likes': '5.2K', 'comments': '2.7K', 'status': 'Naik', 'trend': 'up'},
    {'idx': 6, 'title': 'Resep Ayam Bakar', 'image': 'assets/images/2.png', 'likes': '4.8K', 'comments': '2.5K', 'status': 'Stabil', 'trend': 'stable'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF0EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF0EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F3A38)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Trending', style: TextStyle(color: Color(0xFF4F3A38), fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildChip(0, 'Semua'),
                  const SizedBox(width: 8),
                  _buildChip(1, 'Minggu Ini'),
                  const SizedBox(width: 8),
                  _buildChip(2, 'Bulan Ini'),
                  const SizedBox(width: 8),
                  _buildChip(3, 'Terpopuler'),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final it = items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(it['image'], width: 72, height: 72, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.orange,
                            child: Text('${it['idx']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(it['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pink, size: 16),
                          const SizedBox(width: 6),
                          Text(it['likes'], style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 12),
                          const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 16),
                          const SizedBox(width: 6),
                          Text(it['comments'], style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 12),
                          if (it['trend'] == 'up') Icon(Icons.show_chart, color: Colors.green.shade700, size: 16) else Icon(Icons.remove, color: Colors.amber, size: 16),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(it['status'] == 'Naik' ? Icons.arrow_upward : Icons.circle, color: it['status'] == 'Naik' ? Colors.pink : Colors.amber, size: 12),
                          const SizedBox(width: 6),
                          Text(it['status'], style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Buka ${it['title']}'))),
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
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black)),
      selected: selected,
      onSelected: (_) => setState(() => selectedChip = idx),
      selectedColor: const Color(0xFFD88A94),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
