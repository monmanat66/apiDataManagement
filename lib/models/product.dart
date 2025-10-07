class Product {
  final int? id;
  String title;
  double price;
  String description;
  String category;
  String image;

  Product({
    this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
        title: json['title'] ?? '',
        price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
        description: json['description'] ?? '',
        category: json['category'] ?? '',
        image: json['image'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'price': price,
        'description': description,
        'image': image,
        'category': category,
      };
}
