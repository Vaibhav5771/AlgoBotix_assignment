import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:inventory_app/ui/screens/stock_history_screen.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/product.dart';
import '../../data/models/stock_history.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/custom_button.dart';
import '../utils/image_piker_card.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(Product)? onStockUpdated;

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

      final updatedProduct = Product(
        id: widget.product.id,
        name: widget.product.name,
        description: widget.product.description,
        stock: _stock,
        imagePath: widget.product.imagePath,
        addedBy: widget.product.addedBy,
        createdAt: widget.product.createdAt,
      );

      widget.onStockUpdated?.call(updatedProduct);

      if (mounted) {
        showSuccessSnackBar(context, 'Stock updated successfully');
      }
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDeleteConfirmationDialog(),
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await DBHelper.deleteProduct(widget.product.id);

      if (mounted) {
        // ← using the new specialized snackbar
        showProductDeletedSnackBar(context);
        Navigator.pop(context, true); // tell list to refresh
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Failed to delete product',
        );
      }
    }
  }

  Widget _buildDeleteConfirmationDialog() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade700,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "Do you really want to\ndelete ?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            "This action cannot be undone.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "No",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy, hh:mm a').format(widget.product.createdAt);

    return WillPopScope(
      onWillPop: () async {
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
            return false;
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
                if (result == true && mounted) {
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
              ImagePickerCard(
                imageFile: widget.product.imagePath.isNotEmpty
                    ? File(widget.product.imagePath)
                    : null,
                onTap: () {},
              ),
              const SizedBox(height: 20),

              if (_stock != _originalStock)
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(label: 'Product ID', value: widget.product.id),
                    const SizedBox(height: 10),
                    _infoRow(
                        label: 'Description', value: widget.product.description),
                    const SizedBox(height: 10),
                    _infoRow(label: 'Added By', value: widget.product.addedBy),
                    const SizedBox(height: 10),
                    _infoRow(label: 'Created At', value: date),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text('Current Stock',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              Text(
                _stock.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              if (_stock != _originalStock) ...[
                const SizedBox(height: 8),
                Text(
                  'Original: $_originalStock',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stockActionButton(
                    text: '−',
                    bgColor: Colors.red.shade100,
                    textColor: Colors.red,
                    onPressed: () => _updateStock(-1),
                  ),
                  const SizedBox(width: 24),
                  _stockActionButton(
                    text: '+',
                    bgColor: Colors.green.shade100,
                    textColor: Colors.green,
                    onPressed: () => _updateStock(1),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              if (_stock != _originalStock) ...[
                CustomButton(
                  text: 'Save Changes',
                  icon: Icons.save_alt,
                  width: 220,
                  onPressed: _saveChanges,
                ),
                const SizedBox(height: 16),
              ],

              CustomButton(
                text: 'View History',
                icon: Icons.history,
                width: 220,
                backgroundColor: Colors.white,
                textColor: const Color(0xFF6A57FE),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StockHistoryScreen(productId: widget.product.id),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow({
    required String label,
    required String value,
  }) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 15),
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stockActionButton({
    required String text,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onPressed,
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}