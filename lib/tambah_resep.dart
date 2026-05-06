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
    }
  }

  Future<void> _pickImage() async {
    try {
      // For web platform, skip permission request
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
        setState(() {
          _pickedImage = pickedFile;
        });
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F3A38),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image Section
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
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isPickingImage
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : _pickedImage != null
                                        ? ClipOval(
                                            child: kIsWeb
                                                ? Image.network(
                                                    _pickedImage!.path,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(_pickedImage!.path),
                                                    fit: BoxFit.cover,
                                                  ),
                                          )
                                        : (widget.recipe?.imagePath != null
                                            ? ClipOval(
                                                child: kIsWeb
                                                    ? Image.network(
                                                        widget.recipe!.imagePath!,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(widget.recipe!.imagePath!),
                                                        fit: BoxFit.cover,
                                                      ),
                                              )
                                            : const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo,
                                              size: 60, color: Colors.white),
                                          SizedBox(height: 5),
                                          Text(
                                            'Tap Upload',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      )),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Unggah Foto Makananmu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F3A38),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),

              // Recipe Name Section
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nama Resep',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F3A38),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Color(0xFF4F3A38),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Masukkan nama resep...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFC4AFA5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5EFEB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.restaurant,
                            color: Color(0xFFD9ACA3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Ingredients Section
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bahan-Bahan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F3A38),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descController,
                        maxLines: 5,
                        style: const TextStyle(
                          color: Color(0xFF4F3A38),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tuliskan semua bahan-bahan yang digunakan...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFC4AFA5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5EFEB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Icon(
                              Icons.list_alt,
                              color: Color(0xFFD9ACA3),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Cooking Steps Section
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Langkah-Langkah Memasak',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F3A38),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _stepsController,
                        maxLines: 5,
                        style: const TextStyle(
                          color: Color(0xFF4F3A38),
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Tuliskan langkah-langkah memasak dengan detail...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFC4AFA5),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5EFEB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Icon(
                              Icons.format_list_numbered,
                              color: Color(0xFFD9ACA3),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty) {
                      _showErrorSnackBar('Mohon isi nama resep');
                      return;
                    }
                    if (_descController.text.isEmpty) {
                      _showErrorSnackBar('Mohon isi bahan-bahan');
                      return;
                    }
                    if (_stepsController.text.isEmpty) {
                      _showErrorSnackBar('Mohon isi langkah-langkah memasak');
                      return;
                    }

                    String? imagePath;
                    if (_pickedImage != null) {
                      imagePath = _pickedImage!.path;
                    } else if (widget.recipe?.imagePath != null) {
                      imagePath = widget.recipe!.imagePath;
                    }

                    final newRecipe = Recipe(
                      name: _nameController.text,
                      imagePath: imagePath,
                      description: _descController.text,
                      steps: _stepsController.text,
                    );
                    Navigator.pop(context, newRecipe);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8E9DA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF4F3A38),
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Tambahkan Resep',
                        style: TextStyle(
                          color: Color(0xFF4F3A38),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}