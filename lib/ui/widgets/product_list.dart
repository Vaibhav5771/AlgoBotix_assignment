import 'package:flutter/material.dart';
import '../../data/models/product.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductTap;

  const ProductList({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: products.length + 1,
      itemBuilder: (_, index) {
        if (index == products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Center(
              child: Text(
                'No more products',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }

        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => onProductTap(product),
        );
      },
    );
  }
}
