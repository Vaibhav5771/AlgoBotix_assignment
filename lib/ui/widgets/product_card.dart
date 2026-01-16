import 'dart:io';
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

  Color getStockBgColor(int stock) {
    if (stock == 0) return Colors.red.shade100;
    if (stock < 10) return Colors.orange.shade100;
    if (stock < 50) return Colors.yellow.shade100;
    return Colors.green.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final stockColor = getStockColor(product.stock);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 90,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey.shade200,
                  image: product.imagePath.isNotEmpty
                      ? DecorationImage(
                    image: FileImage(File(product.imagePath)),
                    fit: BoxFit.contain,
                  )
                      : null,
                ),
                child: product.imagePath.isEmpty
                    ? const Icon(Icons.inventory_2, color: Colors.black54)
                    : null,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${product.id}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: getStockBgColor(product.stock),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.stock.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: stockColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
