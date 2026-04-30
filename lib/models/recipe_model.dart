class Recipe {
  final String name;
  final String? imagePath;
  final String description;
  final String steps;

  Recipe({
    required this.name,
    this.imagePath,
    required this.description,
    required this.steps,
  });
}