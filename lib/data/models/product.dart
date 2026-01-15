class Product {
  final String id; // 5-char alphanumeric
  final String name;
  final String description;
  final int stock;
  final String imagePath;
  final String addedBy;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.stock,
    required this.imagePath,
    required this.addedBy,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'stock': stock,
      'imagePath': imagePath,
      'addedBy': addedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      stock: map['stock'],
      imagePath: map['imagePath'],
      addedBy: map['addedBy'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
