class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String category;
  final double rating;
  final int soldCount;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.rating,
    required this.soldCount,
  });

  List<String> get images => [image, image, image];

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingData = (json['rating'] as Map<String, dynamic>?) ?? {};
    return Product(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      image: (json['image'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      rating: (ratingData['rate'] as num?)?.toDouble() ?? 4.5,
      soldCount: (ratingData['count'] as int?) ?? 100,
    );
  }

  factory Product.fromStorageJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      image: (json['image'] ?? '') as String,
      category: (json['category'] ?? '') as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      soldCount: (json['soldCount'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'rating': rating,
      'soldCount': soldCount,
    };
  }
}
