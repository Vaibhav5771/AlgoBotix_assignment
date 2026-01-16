import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/database/db_helper.dart';
import '../../data/models/product.dart';
import '../utils/custom_snackbar.dart';
import '../widgets/custom_button.dart';
import '../utils/custom_text_field.dart';
import '../utils/image_piker_card.dart';
import '../widgets/image_source_bottomsheet.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _stockController;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _idController = TextEditingController(text: widget.product.id);
    _nameController = TextEditingController(text: widget.product.name);
    _descController = TextEditingController(text: widget.product.description);
    _stockController =
        TextEditingController(text: widget.product.stock.toString());

    if (widget.product.imagePath.isNotEmpty) {
      _imageFile = File(widget.product.imagePath);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1200,
      );
      if (picked != null && mounted) {
        setState(() => _imageFile = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to pick image');
      }
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final newImagePath = _imageFile?.path ?? '';

    final updated = Product(
      id: widget.product.id, // immutable
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      stock: int.parse(_stockController.text.trim()),
      imagePath: newImagePath,
      addedBy: widget.product.addedBy,
      createdAt: widget.product.createdAt,
    );

    try {
      await DBHelper.updateProduct(updated);

      if (mounted) {
        showSuccessSnackBar(
          context,
          'Product updated successfully',
          title: 'Updated',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
          context,
          'Failed to update product: ${e.toString()}',
        );
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ImagePickerCard(
                imageFile: _imageFile,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => ImageSourceBottomSheet(
                      onCameraTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      onGalleryTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Disabled ID field
              CustomTextField(
                controller: _idController,
                label: 'Product ID',
                hint: 'Cannot be changed',
                enabled: false,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _nameController,
                label: 'Product Name',
                hint: 'Product name',
                validator: (value) =>
                value == null || value.trim().isEmpty
                    ? 'Required field'
                    : null,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Description (optional)',
                maxLines: 3,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _stockController,
                label: 'Stock',
                hint: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required field';
                  }
                  final stock = int.tryParse(value.trim());
                  if (stock == null || stock < 0) {
                    return 'Must be 0 or greater';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: 'Update Product',
                icon: Icons.save_alt_outlined,
                width: 220,
                onPressed: _updateProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}