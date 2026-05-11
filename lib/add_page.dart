import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import package ini
import '../models/recipe_model.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  File? _imageFile; // Menggunakan File untuk menampung gambar
  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  String _generateRecipeId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecond % 10000).toString().padLeft(4, '0');
    return 'recipe_${timestamp}_$random';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: "Nama Resep Makanan ....",
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const Divider(color: Colors.grey),
              const SizedBox(height: 40),

              // FITUR TAMBAH FOTO (Sesuai Desain Screenshot)
              GestureDetector(
                onTap: _pickImage,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4081), // Warna pink sesuai gambar
                        shape: BoxShape.circle,
                      ),
                      child: _imageFile != null
                          ? ClipOval(
                              child: Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.cloud_upload_outlined,
                              size: 70,
                              color: Colors.white,
                            ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Unggah Foto Makananmu",
                      style: TextStyle(
                        color: Color(0xFF8E6F6A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
              const Divider(color: Colors.grey),

              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Tambahkan Resep Makanan",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F3A38),
                  ),
                ),
              ),

              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  hintText: "Tulis bahan atau deskripsi di sini...",
                  border: InputBorder.none,
                ),
                maxLines: 5,
              ),

              const SizedBox(height: 40),

              // TOMBOL TAMBAHKAN
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty) return;

                    final recipeId = _generateRecipeId();
                    final newRecipe = Recipe(
                      id: recipeId,
                      name: _nameController.text,
                      imagePath: _imageFile?.path,
                      description: _descController.text,
                      steps: "-",
                      category: "Umum",
                      isPrivate: true,
                      owner: userName, // Gunakan username pengguna saat ini
                    );

                    Navigator.pop(context, newRecipe);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8E9DA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Tambahkan",
                    style: TextStyle(
                      color: Color(0xFF4F3A38),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}