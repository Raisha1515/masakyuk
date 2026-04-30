import 'package:flutter/material.dart';
import 'login.dart';


class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3), // warna BACKGROUND yang sama
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // Buat sudut layar melengkung seperti desain
        decoration: BoxDecoration(
          color: const Color(0xFFD9ACA3),
          borderRadius: BorderRadius.circular(40),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            // TEKS WELCOME TO
            const Text(
              "Welcome to",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F3A38), // warna teks coklat gelap
              ),
            ),

            const SizedBox(height: 5),

            // TEKS MASAK YUK!
            const Text(
              "Masak YUK!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4F3A38),
              ),
            ),

            const SizedBox(height: 35),

            // GAMBAR ILUSTRASI MAKANAN
            SizedBox(
              width: 270,
              height: 270,
              child: Image.asset(
                "assets/images/1.png",
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 15),

            // SUBTITLE "Buat Harimu Kenyang…"
            const Text(
              "Buat Harimu Kenyang Setiap Hari !!",
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4F3A38),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 35),

            // DOT INDICATOR
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // DOT ACTIVE
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF7E8D9), // dot warna krem muda
                  ),
                ),
                const SizedBox(width: 12),

                // DOT NON ACTIVE
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.brown.shade300,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 45),

            // BUTTON MULAI
            Container(
              width: 260,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFF9EADA),
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  "AYO MASAK!",
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFF4F3A38),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
