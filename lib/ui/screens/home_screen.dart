import 'package:flutter/material.dart';
import 'package:inventory_app/ui/screens/product_detail_screen.dart';
import 'package:inventory_app/ui/screens/qr_scanner_screen.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/product.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';

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
    print(data);
    setState(() {
      _products = data.map((e) => Product.fromMap(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products
        .where((p) => p.id.contains(_searchQuery.toUpperCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final scannedId = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              );

              if (scannedId == null) return;

              final product =
              await DBHelper.getProductById(scannedId.toString().toUpperCase());

              if (product == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product not found')),
                );
                return;
              }

              // 🔥 Open Product Details directly
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: product),
                ),
              );

              // Refresh home after returning
              if (result == true) {
                _loadProducts();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result == true) _loadProducts();
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by Product ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: _products.isEmpty
                ? const Center(child: Text('No products found'))
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (_, index) {
                final product = filteredProducts[index]; // ✅ DEFINE IT
                return ProductCard(
                  product: product,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          product: product,
                          onStockUpdated: (updatedProduct) {
                            // Update the product in the list
                            final index = _products.indexWhere((p) => p.id == updatedProduct.id);
                            if (index != -1) {
                              setState(() {
                                _products[index] = updatedProduct;
                              });
                            }
                          },
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadProducts();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
