class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    const fallbackImage = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?ixlib=rb-4.0.3';
    
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? 'Fresh from our bakery',
      price: double.parse(json['price'].toString()),
      image: json['image']?.toString().isNotEmpty == true ? json['image'] : fallbackImage,
      category: json['category'] ?? 'other',
    );
  }
}
