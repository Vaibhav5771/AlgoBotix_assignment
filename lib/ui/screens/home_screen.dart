import 'package:flutter/material.dart';
import 'package:inventory_app/ui/screens/product_detail_screen.dart';
import 'package:inventory_app/ui/screens/qr_scanner_screen.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/product.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/custom_button.dart';
import '../widgets/product_list.dart';
import '../widgets/search_bar.dart';
import 'add_product_screen.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await DBHelper.getProducts();
    setState(() {
      _products = data.map((e) => Product.fromMap(e)).toList();
    });
  }

  Future<void> _openQrScanner() async {
    final scannedId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (scannedId == null) return;

    final product = await DBHelper.getProductById(
      scannedId.toString().toUpperCase(),
    );

    if (product == null) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Product not found');
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );

    if (result == true && mounted) {
      _loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.trim().toUpperCase();

    final filteredProducts = _products.where((p) {
      if (query.isEmpty) return true;
      final idMatch = p.id.toUpperCase().contains(query);
      final nameMatch = p.name.toUpperCase().contains(query);
      return idMatch || nameMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.qrcode),
            onPressed: _openQrScanner,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search header
          Container(
            color: const Color(0xFF6A57FE),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: SearchBarWidget(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),


          Expanded(
            child: filteredProducts.isEmpty
                ? _buildEmptyState(query)
                : ProductList(
              products: filteredProducts,
              onProductTap: (product) async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(
                      product: product,
                      onStockUpdated: (updatedProduct) {
                        final index = _products.indexWhere(
                              (p) => p.id == updatedProduct.id,
                        );
                        if (index != -1) {
                          setState(() {
                            _products[index] = updatedProduct;
                          });
                        }
                      },
                    ),
                  ),
                );

                if (result == true && mounted) {
                  _loadProducts();
                }
              },
            ),
          ),


          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Add Product',
              icon: Icons.add,
              width: 220,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
                if (result == true && mounted) {
                  _loadProducts();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(fontSize: 20, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "+" to add your first product',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No products found',
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}