import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe_model.dart';
import '../services/recipe_service.dart';
import '../services/storage_service.dart';

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

  String? _selectedCategory;
  bool _isPublic = true;
  final List<String> _categories = [
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Diet',
    'Dessert'
  ];

  XFile? _pickedImage;
  bool _isPickingImage = false;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  late RecipeService recipeService;
  late StorageService storageService;
  String? userId;

  @override
  void initState() {
    super.initState();
    recipeService = RecipeService();
    storageService = StorageService();
    userId = Supabase.instance.client.auth.currentUser?.id;

    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _descController.text = widget.recipe!.description;
      _stepsController.text = widget.recipe!.steps;
      _selectedCategory = widget.recipe!.category;
      _isPublic = widget.recipe!.isPublic;
    }
  }

  Future<void> _pickImage() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // 1. Cek dulu status Permission.photos (Android 13+)
      status = await Permission.photos.status;
      
      if (status.isDenied) {
        status = await Permission.photos.request();
      }

      // 2. FALLBACK: Jika status masih ditolak/tidak aktif, coba minta Permission.storage (Android 12 kebawah)
      if (status.isDenied) {
        status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      }
    } else {
      // Untuk iOS
      status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
    }

    // Jika salah satu izin diberikan oleh sistem
    if (status.isGranted || status.isLimited) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          setState(() {
            _pickedImage = pickedFile; 
          });
        }
      } catch (e) {
        _showSnackBar("Gagal mengambil gambar: $e");
      }
    } 
    else if (status.isPermanentlyDenied) {
      _showSetupPermissionDialog();
    } 
    else {
      _showSnackBar("Izin akses galeri ditolak.");
    }
  }

  void _showSnackBar(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.redAccent),
    );
  }

  void _showSetupPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Izin Galeri Diperlukan"),
        content: const Text(
          "Aplikasi memerlukan izin galeri untuk mengunggah foto makanan. "
          "Silakan aktifkan izin di pengaturan aplikasi Anda.",
        ),
        actions: [
          TextButton(
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Buka Pengaturan", style: TextStyle(color: Colors.pink)),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
          ),
        ],
      ),
    );
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isPickingImage || _isSubmitting ? null : _pickImage,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : _pickedImage != null
                                ? ClipOval(
                                    child: kIsWeb
                                        ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
                                        : Image.file(File(_pickedImage!.path), fit: BoxFit.cover),
                                  )
                                : (widget.recipe?.imageUrl != null
                                    ? ClipOval(
                                        child: Image.network(widget.recipe!.imageUrl!, fit: BoxFit.cover),
                                      )
                                    : const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_a_photo, size: 60, color: Colors.white),
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
              _buildFormCard(
                label: 'Nama Resep',
                child: TextField(
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  decoration: _buildInputDecoration('Masukkan nama resep...', Icons.restaurant),
                ),
              ),
              const SizedBox(height: 20),
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
                  onChanged: _isSubmitting ? null : (value) => setState(() => _selectedCategory = value),
                  decoration: _buildInputDecoration('Pilih kategori hidangan', Icons.category),
                  dropdownColor: const Color(0xFFF5EFEB),
                ),
              ),
              const SizedBox(height: 20),
              _buildFormCard(
                label: 'Bahan-Bahan',
                child: TextField(
                  controller: _descController,
                  enabled: !_isSubmitting,
                  maxLines: 5,
                  decoration: _buildInputDecoration('Tuliskan semua bahan...', Icons.list_alt),
                ),
              ),
              const SizedBox(height: 20),
              _buildFormCard(
                label: 'Langkah-Langkah Memasak',
                child: TextField(
                  controller: _stepsController,
                  enabled: !_isSubmitting,
                  maxLines: 5,
                  decoration: _buildInputDecoration('Tuliskan detail langkah...', Icons.format_list_numbered),
                ),
              ),
              const SizedBox(height: 20),
              _buildFormCard(
                label: 'Publikasi',
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isPublic ? 'Resep akan terlihat oleh semua' : 'Resep hanya untuk Anda',
                        style: const TextStyle(color: Color(0xFF4F3A38)),
                      ),
                    ),
                    Switch(
                      value: _isPublic,
                      onChanged: _isSubmitting ? null : (value) => setState(() => _isPublic = value),
                      activeColor: const Color(0xFFFF4081),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8E9DA),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F3A38)),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Color(0xFF4F3A38)),
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
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F3A38),
              ),
            ),
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    );
  }

  Future<void> _submitData() async {
    if (_nameController.text.isEmpty ||
        _selectedCategory == null ||
        _descController.text.isEmpty ||
        _stepsController.text.isEmpty) {
      _showErrorSnackBar('Mohon lengkapi semua data dan pilih kategori');
      return;
    }

    if (userId == null) {
      _showErrorSnackBar('User tidak terautentikasi');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? imageUrl;

      // Upload image jika ada
      if (_pickedImage != null) {
        final tempRecipeId = widget.recipe?.id ?? _generateRecipeId();

        if (kIsWeb) {
          final bytes = await _pickedImage!.readAsBytes();
          imageUrl = await storageService.uploadRecipeImage(
            recipeId: tempRecipeId,
            imageFile: bytes,
          );
        } else {
          final file = File(_pickedImage!.path);
          imageUrl = await storageService.uploadRecipeImage(
            recipeId: tempRecipeId,
            imageFile: file,
          );
        }

        if (imageUrl == null) {
          throw Exception('Gagal upload gambar');
        }
      }

      // Create atau update recipe di database
      if (widget.recipe != null) {
        // Update existing
        await recipeService.updateRecipe(
          recipeId: widget.recipe!.id,
          title: _nameController.text,
          description: _descController.text,
          steps: _stepsController.text,
          category: _selectedCategory!,
          imageUrl: imageUrl,
          isPublic: _isPublic,
          isPrivate: !_isPublic,
        );
        final updatedRecipe = Recipe(
        id: widget.recipe!.id, // tetap pakai ID lama
        userId: widget.recipe!.userId,
        name: _nameController.text,       // Ambil dari controller form Anda
        category: _selectedCategory!,
        description: _descController.text,
        steps: _stepsController.text,
        imageUrl: imageUrl ?? widget.recipe!.imageUrl, // atau variabel penampung gambar Anda
        owner: widget.recipe!.owner,
        isPublic: _isPublic,
        isPrivate: !_isPublic,
      );

      // 2. Kembalikan objek updatedRecipe ini ke halaman detail
      if (!mounted) return;
      Navigator.pop(context, updatedRecipe);
        
        _showSuccessSnackBar('Resep berhasil diperbarui!');
      } else {
        // Create new
        final recipeId = await recipeService.createRecipe(
          userId: userId!,
          title: _nameController.text,
          description: _descController.text,
          steps: _stepsController.text,
          category: _selectedCategory!,
          imageUrl: imageUrl,
          isPublic: _isPublic,
          isPrivate: !_isPublic
        );

        final newRecipe = Recipe(
          id: recipeId,
          name: _nameController.text,
          imageUrl: imageUrl,
          description: _descController.text,
          steps: _stepsController.text,
          category: _selectedCategory!,
          isPublic: _isPublic,
          isPrivate: !_isPublic,
        );

        if (!mounted) return;
        Navigator.pop(context, newRecipe);
        return;
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Error: $e');
      print('Submit error: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _generateRecipeId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (DateTime.now().microsecond % 10000).toString().padLeft(4, '0');
    return 'recipe_${timestamp}_$random';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _stepsController.dispose();
    super.dispose();
  }
}
