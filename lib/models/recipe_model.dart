class Comment {
  final String id;
  final String author;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    author: json['author'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class Rating {
  final String id;
  final int stars;
  final DateTime timestamp;

  Rating({
    required this.id,
    required this.stars,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'stars': stars,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json['id'],
    stars: json['stars'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

class Recipe {
  final String id;
  final String name;
  final String? imagePath;
  final String description;
  final String steps;
  final String category;
  final bool isPublic;
  final List<Comment> comments;
  final List<Rating> ratings;

  Recipe({
    required this.id,
    required this.name,
    this.imagePath,
    required this.description,
    required this.steps,
    required this.category,
    this.isPublic = true,
    List<Comment>? comments,
    List<Rating>? ratings,
  }) : comments = comments ?? [],
       ratings = ratings ?? [];

  double get averageRating {
    if (ratings.isEmpty) return 0;
    return ratings.fold(0.0, (sum, r) => sum + r.stars) / ratings.length;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
    'description': description,
    'steps': steps,
    'category': category,
    'isPublic': isPublic,
    'comments': comments.map((c) => c.toJson()).toList(),
    'ratings': ratings.map((r) => r.toJson()).toList(),
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] ?? '',
    name: json['name'],
    imagePath: json['imagePath'],
    description: json['description'],
    steps: json['steps'],
    category: json['category'] ?? '',
    isPublic: json['isPublic'] ?? true,
    comments: (json['comments'] as List?)?.map((c) => Comment.fromJson(c as Map<String, dynamic>)).toList(),
    ratings: (json['ratings'] as List?)?.map((r) => Rating.fromJson(r as Map<String, dynamic>)).toList(),
  );
}