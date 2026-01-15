import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/ui/screens/stock_history_screen.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_history.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product)? onStockUpdated; // New callback

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.onStockUpdated,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _stock;
  late int _originalStock;

  @override
  void initState() {
    super.initState();
    _stock = widget.product.stock;
    _originalStock = widget.product.stock;
  }

  Future<void> _updateStock(int change) async {
    final newStock = _stock + change;
    if (newStock < 0) return;
    setState(() => _stock = newStock);
  }

  Future<void> _saveChanges() async {
    // Only save if stock changed
    if (_stock != _originalStock) {
      await DBHelper.updateProductStock(widget.product.id, _stock);

      await DBHelper.insertStockHistory(
        StockHistory(
          productId: widget.product.id,
          change: _stock - _originalStock,
          timestamp: DateTime.now(),
        ),
      );

      // Create updated product
      final updatedProduct = Product(
        id: widget.product.id,
        name: widget.product.name,
        description: widget.product.description,
        stock: _stock,
        imagePath: widget.product.imagePath,
        addedBy: widget.product.addedBy,
        createdAt: widget.product.createdAt,
      );

      // Call callback if provided
      widget.onStockUpdated?.call(updatedProduct);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock updated successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    // Go back
    Navigator.pop(context, true);
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DBHelper.deleteProduct(widget.product.id);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date =
    DateFormat('dd MMM yyyy, hh:mm a').format(widget.product.createdAt);

    return WillPopScope(
      onWillPop: () async {
        // Ask to save if there are changes
        if (_stock != _originalStock) {
          final shouldSave = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('Do you want to save your changes?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Discard'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save'),
                ),
              ],
            ),
          );

          if (shouldSave == true) {
            await _saveChanges();
            return false; // Already popped in _saveChanges
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product Details'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProductScreen(product: widget.product),
                  ),
                );
                if (result == true) {
                  Navigator.pop(context, true);
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteProduct,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: widget.product.imagePath.isNotEmpty
                    ? FileImage(File(widget.product.imagePath))
                    : null,
                child: widget.product.imagePath.isEmpty
                    ? const Icon(Icons.inventory, size: 40)
                    : null,
              ),
              const SizedBox(height: 20),

              // Show save indicator when there are unsaved changes
              if (_stock != _originalStock)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info,
                        color: Colors.orange[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unsaved changes: ${_stock - _originalStock > 0 ? '+' : ''}${_stock - _originalStock}',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.name,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Product ID: ${widget.product.id}'),
                      const SizedBox(height: 8),
                      Text(widget.product.description),
                      const SizedBox(height: 12),
                      Text('Added By: ${widget.product.addedBy}'),
                      Text('Created At: $date'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text('Current Stock',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                _stock.toString(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Show original stock for comparison
              if (_stock != _originalStock)
                Text(
                  'Original: $_originalStock',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle, size: 36),
                    onPressed: () => _updateStock(-1),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.add_circle, size: 36),
                    onPressed: () => _updateStock(1),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Save button at the bottom
              if (_stock != _originalStock)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Stock History Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StockHistoryScreen(productId: widget.product.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('View Stock History'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}