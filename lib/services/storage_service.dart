import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;
  static const String bucketName = 'recipe-images';

  Future<String?> uploadRecipeImage({
  required String recipeId,
  required dynamic imageFile,
}) async {
  try {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // 1. Deteksi ekstensi file secara dinamis agar tidak memaksa .jpg
    String extension = 'jpg'; 
    if (!kIsWeb && imageFile is File) {
      extension = imageFile.path.split('.').last.toLowerCase();
    }
    
    final fileName = 'recipe_${recipeId}_$timestamp.$extension';

    if (kIsWeb) {
      // Web: imageFile is bytes
      Uint8List bytes;
      if (imageFile is Uint8List) {
        bytes = imageFile;
      } else if (imageFile is List<int>) {
        bytes = Uint8List.fromList(imageFile);
      } else {
        throw Exception('Tipe file gambar tidak valid untuk Web');
      }
      
      // Menggunakan uploadBinary
      await supabase.storage.from(bucketName).uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );
    } else {
      // Mobile: Pastikan objek benar-base tipe File dart:io
      if (imageFile is File) {
        // Cek apakah file benar-benar ada di storage lokal sebelum diupload
        if (!await imageFile.exists()) {
          throw Exception('File gambar lokal tidak ditemukan di perangkat');
        }

        await supabase.storage.from(bucketName).upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(
            cacheControl: '3600', 
            upsert: false,
          ),
        );
      } else {
        throw Exception('Data yang dikirim di Mobile harus berupa File');
      }
    }

    // 2. Ambil Public URL setelah proses upload dipastikan selesai tanpa error
    final String imageUrl = supabase.storage
        .from(bucketName)
        .getPublicUrl(fileName);

    print('Upload sukses! URL Gambar: $imageUrl');
    return imageUrl;
  } catch (e) {
    // Print error secara spesifik di console debug biar kelihatan masalah aslinya
    print('Error detail saat uploading recipe image ke Supabase: $e');
    return null;
  }
}

  Future<String?> uploadUserAvatar({
    required String userId,
    required dynamic imageFile,
  }) async {
    try {
      const bucketName = 'user-avatars';
      final fileName = 'avatar_$userId.jpg';

      if (kIsWeb) {
        Uint8List bytes;
        if (imageFile is Uint8List) {
          bytes = imageFile;
        } else if (imageFile is List<int>) {
          bytes = Uint8List.fromList(imageFile);
        } else {
          throw Exception('Invalid image file type');
        }
        await supabase.storage.from(bucketName).updateBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );
      } else {
        if (imageFile is File) {
          await supabase.storage.from(bucketName).update(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
        }
      }

      final imageUrl = supabase.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print('Error uploading user avatar: $e');
      return null;
    }
  }

  Future<void> deleteRecipeImage(String imagePath) async {
    try {
      if (imagePath.contains(bucketName)) {
        final fileName = imagePath.split('/').last;
        await supabase.storage.from(bucketName).remove([fileName]);
      }
    } catch (e) {
      print('Error deleting recipe image: $e');
    }
  }

  Future<void> deleteUserAvatar(String userId) async {
    try {
      const bucketName = 'user-avatars';
      final fileName = 'avatar_$userId.jpg';
      await supabase.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      print('Error deleting user avatar: $e');
    }
  }
}
