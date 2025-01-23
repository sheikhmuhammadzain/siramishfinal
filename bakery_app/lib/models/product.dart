class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;

  const Product({
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
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? 'Fresh from our bakery',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      image: json['image']?.toString().isNotEmpty == true ? json['image'] as String : fallbackImage,
      category: json['category'] as String? ?? 'other',
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, category: $category)';
  }
}
