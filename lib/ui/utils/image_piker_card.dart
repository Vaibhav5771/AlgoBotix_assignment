import 'dart:io';
import 'package:flutter/material.dart';

class ImagePickerCard extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const ImagePickerCard({
    super.key,
    required this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF6A57FE), width: 1.4),
          color: Colors.white,
        ),
        child: imageFile != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            imageFile!,
            fit: BoxFit.contain,
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Pick an image',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
