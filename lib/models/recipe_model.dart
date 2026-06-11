class Comment {
  final String id;
  final String author;
  final String text;
  final DateTime timestamp;
  final String? userId;

  Comment({
    required this.id,
    required this.author,
    required this.text,
    required this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'user_id': userId,
  };

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    author: json['author'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
    userId: json['user_id'],
  );
}

class Rating {
  final String id;
  final int stars;
  final DateTime timestamp;
  final String? userId;

  Rating({
    required this.id,
    required this.stars,
    required this.timestamp,
    this.userId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'stars': stars,
    'timestamp': timestamp.toIso8601String(),
    'user_id': userId,
  };

  factory Rating.fromJson(Map<String, dynamic> json) => Rating(
    id: json['id'],
    stars: json['stars'],
    timestamp: DateTime.parse(json['timestamp']),
    userId: json['user_id'],
  );
}

class Recipe {
  final String id;
  final String name;
  final String? imagePath;
  final String? imageUrl;
  final String description;
  final String steps;
  final String category;
  final List<Comment> comments;
  final List<Rating> ratings;

  String? owner;
  String? userId;
  bool isPrivate;
  bool isPublic;
  DateTime? createdAt;
  DateTime? updatedAt;

  Recipe({
    required this.id,
    required this.name,
    this.imagePath,
    this.imageUrl,
    required this.description,
    required this.steps,
    required this.category,
    this.owner,
    this.userId,
    this.isPrivate = false,
    this.isPublic = true,
    List<Comment>? comments,
    List<Rating>? ratings,
    this.createdAt,
    this.updatedAt,
  })
  : comments = comments ?? [],
       ratings = ratings ?? [];

  double get averageRating {
    if (ratings.isEmpty) return 0;
    return ratings.fold(0.0, (sum, r) => sum + r.stars) / ratings.length;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
    'imageUrl': imageUrl,
    'description': description,
    'steps': steps,
    'category': category,
    'isPrivate': isPrivate,
    'isPublic': isPublic,
    'owner': owner,
    'userId': userId,
    'comments': comments.map((c) => c.toJson()).toList(),
    'ratings': ratings.map((r) => r.toJson()).toList(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] ?? '',
    name: json['name'],
    imagePath: json['imagePath'],
    imageUrl: json['imageUrl'] ?? json['image_url'],
    description: json['description'],
    steps: json['steps'],
    category: json['category'] ?? '',
    owner: json['owner'],
    userId: json['userId'] ?? json['user_id'],
    isPrivate: json['isPrivate'] ?? json['is_private'] ?? false,
    isPublic: json['isPublic'] ?? json['is_public'] ?? true,
    comments: (json['comments'] as List?)?.map((c) => Comment.fromJson(c as Map<String, dynamic>)).toList(),
    ratings: (json['ratings'] as List?)?.map((r) => Rating.fromJson(r as Map<String, dynamic>)).toList(),
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );
}