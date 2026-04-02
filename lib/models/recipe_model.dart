class Recipe {
  final String name;
  final String? imagePath; // Pastikan namanya imagePath (p kecil, P besar)
  final String description;
  final String steps; // Tambahkan ini agar error di baris 59 hilang

  Recipe({
    required this.name,
    this.imagePath,
    required this.description,
    required this.steps,
  });
}