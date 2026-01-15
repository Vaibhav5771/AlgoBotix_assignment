import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/product.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}


class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _stockController = TextEditingController();

  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  bool _isValidProductId(String value) {
    final regex = RegExp(r'^[a-zA-Z0-9]{5}$');
    return regex.hasMatch(value);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _idController.text.toUpperCase();

    if (await DBHelper.productExists(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product ID already exists')),
      );
      return;
    }

    final product = Product(
      id: id,
      name: _nameController.text,
      description: _descController.text,
      stock: int.parse(_stockController.text),
      imagePath: _imageFile?.path ?? '',
      addedBy: 'Admin',
      createdAt: DateTime.now(),
    );

    await DBHelper.insertProduct(product);

    Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text('Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => SafeArea(
                      child: Wrap(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Camera'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('Gallery'),
                            onTap: () {
                              Navigator.pop(context);
                              _pickImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                  _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _idController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Product ID (5 chars)',
                ),
                onChanged: (value) {
                  _idController.value = _idController.value.copyWith(
                    text: value.toUpperCase(),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                },
                validator: (value) {
                  if (value == null || !_isValidProductId(value)) {
                    return 'Enter exactly 5 alphanumeric characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                value!.isEmpty ? 'Required field' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: 'Initial Stock'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Enter valid number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  child: const Text('Save Product'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
