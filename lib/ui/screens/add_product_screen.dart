import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/database/db_helper.dart';
import '../../data/models/product.dart';
import '../widgets/custom_button.dart';
import '../utils/custom_text_field.dart';
import '../utils/image_piker_card.dart';
import '../widgets/image_source_bottomsheet.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

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
    return RegExp(r'^[a-zA-Z0-9]{5}$').hasMatch(value);
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _idController.text.toUpperCase();

    if (await DBHelper.productExists(id)) {
      if (!context.mounted) return;

      // Clear any previous snackbars (optional but clean)
      ScaffoldMessenger.of(context).clearSnackBars();

      final snackBar = SnackBar(
        /// IMPORTANT: Set these properties for the best effect
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 4),
        content: AwesomeSnackbarContent(
          title: 'Oops!',
          message: 'Product ID already exists!',
          contentType: ContentType.failure,  // Gives red header + error icon
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

    if (!context.mounted) return;

    // Optional: Show success message before popping
    final successSnackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: const Duration(seconds: 3),
      content: AwesomeSnackbarContent(
        title: 'Success!',
        message: 'Product added successfully!',
        contentType: ContentType.success,  // Green header + check icon
      ),
    );

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(successSnackBar);

    Navigator.pop(context, true);
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

              CustomTextField(
                controller: _idController,
                label: 'Product ID',
                hint: '5 characters',
                onChanged: (value) {
                  _idController.value = _idController.value.copyWith(
                    text: value.toUpperCase(),
                    selection:
                    TextSelection.collapsed(offset: value.length),
                  );
                },
                validator: (value) =>
                value == null || !_isValidProductId(value)
                    ? 'Enter exactly 5 alphanumeric characters'
                    : null,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _nameController,
                label: 'Product Name',
                hint: 'Product name',
                validator: (value) =>
                value == null || value.isEmpty ? 'Required field' : null,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Description',
                maxLines: 3,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _stockController,
                label: 'Stock',
                hint: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || int.tryParse(value) == null
                    ? 'Enter valid number'
                    : null,
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: 'Add Product',
                icon: Icons.add,
                width: 200,
                onPressed: _saveProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
