import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor = const Color(0xFF6A57FE),
    this.textColor = Colors.white,
    this.height = 50,
    this.width = 250,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: backgroundColor.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
        ),
        child: isLoading
            ? SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.8,
            color: textColor,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.2,
                letterSpacing: 0.2,
                color: textColor,
              ),
            ),
            const SizedBox(width: 12),
            if (icon != null) ...[
              Icon(
                icon,
                size: 22,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}