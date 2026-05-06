import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  // --- Fitur Baru: State Kategori & Publikasi ---
  String? _selectedCategory;
  bool _isPublic = true; // Default ke Public
  final List<String> _categories = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Diet',
    'Dessert'
  ];

  XFile? _pickedImage;
  bool _isPickingImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _descController.text = widget.recipe!.description;
      _stepsController.text = widget.recipe!.steps;
      // Inisialisasi jika model Recipe kamu sudah punya field kategori/status
      // _selectedCategory = widget.recipe!.category;
      // _isPublic = widget.recipe!.isPublic;
    }
  }

  // ... (Fungsi _pickImage dan _showErrorSnackBar tetap sama)
  Future<void> _pickImage() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          _showErrorSnackBar('Izin akses galeri ditolak');
          return;
        }
      }
      setState(() => _isPickingImage = true);
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() => _pickedImage = pickedFile);
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar: $e');
    } finally {
      setState(() => _isPickingImage = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9ACA3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF4F3A38), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Resep Baru',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4F3A38)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Section (Tetap sama)
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isPickingImage ? null : _pickImage,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4081),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: _isPickingImage
                            ? const Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white)))
                            : _pickedImage != null
                                ? ClipOval(
                                    child: kIsWeb
                                        ? Image.network(_pickedImage!.path,
                                            fit: BoxFit.cover)
                                        : Image.file(File(_pickedImage!.path),
                                            fit: BoxFit.cover),
                                  )
                                : (widget.recipe?.imagePath != null
                                    ? ClipOval(
                                        child: Image.file(
                                            File(widget.recipe!.imagePath!),
                                            fit: BoxFit.cover))
                                    : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo,
                                              size: 60, color: Colors.white),
                                          SizedBox(height: 5),
                                          Text('Tap Upload',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      )),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Unggah Foto Makananmu',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F3A38),
                            fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // 2. Form Nama Resep (Tetap sama)
              _buildFormCard(
                label: 'Nama Resep',
                child: TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration(
                      'Masukkan nama resep...', Icons.restaurant),
                ),
              ),
              const SizedBox(height: 20),

              // --- FITUR BARU: DROPDOWN KATEGORI ---
              _buildFormCard(
                label: 'Pilih Kategori',
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  decoration: _buildInputDecoration(
                      'Pilih kategori hidangan', Icons.category),
                  dropdownColor: const Color(0xFFF5EFEB),
                ),
              ),
              const SizedBox(height: 20),

              // --- FITUR BARU: STATUS PUBLIKASI ---
              _buildFormCard(
                label: 'Status Publikasi',
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Public',
                            style: TextStyle(fontSize: 14)),
                        value: true,
                        groupValue: _isPublic,
                        activeColor: const Color(0xFFFF4081),
                        onChanged: (val) => setState(() => _isPublic = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Private',
                            style: TextStyle(fontSize: 14)),
                        value: false,
                        groupValue: _isPublic,
                        activeColor: const Color(0xFFFF4081),
                        onChanged: (val) => setState(() => _isPublic = val!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Ingredients Section
              _buildFormCard(
                label: 'Bahan-Bahan',
                child: TextField(
                  controller: _descController,
                  maxLines: 5,
                  decoration: _buildInputDecoration(
                      'Tuliskan semua bahan...', Icons.list_alt),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Cooking Steps Section
              _buildFormCard(
                label: 'Langkah-Langkah Memasak',
                child: TextField(
                  controller: _stepsController,
                  maxLines: 5,
                  decoration: _buildInputDecoration(
                      'Tuliskan detail langkah...', Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 35),

              // 5. Submit Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8E9DA),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, color: Color(0xFF4F3A38)),
                      SizedBox(width: 10),
                      Text('Tambahkan Resep',
                          style: TextStyle(
                              color: Color(0xFF4F3A38),
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Helper untuk Scannability ---

  Widget _buildFormCard({required String label, required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F3A38))),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFC4AFA5)),
      filled: true,
      fillColor: const Color(0xFFF5EFEB),
      prefixIcon: Icon(icon, color: const Color(0xFFD9ACA3)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    );
  }

  void _submitData() {
    if (_nameController.text.isEmpty ||
        _selectedCategory == null ||
        _descController.text.isEmpty ||
        _stepsController.text.isEmpty) {
      _showErrorSnackBar('Mohon lengkapi semua data dan pilih kategori');
      return;
    }

    String? imagePath = _pickedImage?.path ?? widget.recipe?.imagePath;

    final newRecipe = Recipe(
      name: _nameController.text,
      imagePath: imagePath,
      description: _descController.text,
      steps: _stepsController.text,
      // Jangan lupa tambahkan field ini di model Recipe kamu:
      // category: _selectedCategory,
      // isPublic: _isPublic,
    );
    Navigator.pop(context, newRecipe);
  }
}