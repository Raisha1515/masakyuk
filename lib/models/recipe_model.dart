class Recipe {
  String name;
  String? imagePath;
  String description;
  String steps;
  String? owner; // username of creator
  bool isPrivate;

  Recipe({
    required this.name,
    this.imagePath,
    required this.description,
    required this.steps,
    this.owner,
    this.isPrivate = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? '',
      imagePath: json['imagePath'],
      description: json['description'] ?? '',
      steps: json['steps'] ?? '',
      owner: json['owner'],
      isPrivate: json['isPrivate'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'description': description,
      'steps': steps,
      'owner': owner,
      'isPrivate': isPrivate,
    };
  }
}