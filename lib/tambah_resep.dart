import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import '../models/recipe_model.dart';

class TambahResep extends StatefulWidget {
  final Recipe? recipe; 
  const TambahResep({super.key, this.recipe});

  @override
  State<TambahResep> createState() => _TambahResepState();
}

class _TambahResepState extends State<TambahResep> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _stepsController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _descController.text = widget.recipe!.description;
      _stepsController.text = widget.recipe!.steps;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // WARNA BACKROUND UTAMA
      backgroundColor: const Color(0xFFD9ACA3), 
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparan agar warna pink muncul
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4F3A38)),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38)),
          decoration: const InputDecoration(
            hintText: "Nama Resep Makanan ....",
            hintStyle: TextStyle(color: Color(0xFF8E6F6A)),
            border: InputBorder.none,
          ),
        ),
      ),
      // Gunakan Container transparan di body untuk memastikan tidak ada warna putih
      body: Container(
        color: Colors.transparent, 
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const Divider(color: Color(0xFF8E6F6A), thickness: 1),
                const SizedBox(height: 30),

                // Area Unggah Foto
                GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    children: [
                      Container(
                        width: 130, height: 130,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4081), 
                          shape: BoxShape.circle,
                        ),
                        child: _imageFile != null
                            ? ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover))
                            : (widget.recipe?.imagePath != null 
                                ? ClipOval(child: Image.file(File(widget.recipe!.imagePath!), fit: BoxFit.cover))
                                : const Icon(Icons.cloud_upload_outlined, size: 70, color: Colors.white)),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Unggah Foto Makananmu", 
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F3A38))
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                const Divider(color: Color(0xFF8E6F6A), thickness: 1),
                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Tambahkan Resep Makanan", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38))
                  ),
                ),

                // Input Bahan (Tanpa background putih)
                TextField(
                  controller: _descController,
                  maxLines: 4,
                  style: const TextStyle(color: Color(0xFF4F3A38)),
                  decoration: const InputDecoration(
                    hintText: "Tulis bahan-bahan...", 
                    hintStyle: TextStyle(color: Color(0xFF8E6F6A)),
                    border: InputBorder.none,
                  ),
                ),
                
                const Divider(color: Color(0xFF8E6F6A)),

                // Input Langkah (Tanpa background putih)
                TextField(
                  controller: _stepsController,
                  maxLines: 4,
                  style: const TextStyle(color: Color(0xFF4F3A38)),
                  decoration: const InputDecoration(
                    hintText: "Tulis langkah memasak...", 
                    hintStyle: TextStyle(color: Color(0xFF8E6F6A)),
                    border: InputBorder.none,
                  ),
                ),

                const SizedBox(height: 40),

                // Tombol Tambahkan
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty) return;
                      final newRecipe = Recipe(
                        name: _nameController.text,
                        imagePath: _imageFile?.path ?? widget.recipe?.imagePath,
                        description: _descController.text,
                        steps: _stepsController.text,
                      );
                      Navigator.pop(context, newRecipe);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF8E9DA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Tambahkan", 
                      style: TextStyle(color: Color(0xFF4F3A38), fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}