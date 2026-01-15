import 'package:flutter/material.dart';
import '../../data/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  Color getStockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    if (stock < 50) return Colors.amber;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.inventory_2),
        title: Text(product.name),
        subtitle: Text('ID: ${product.id}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: getStockColor(product.stock),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product.stock.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
