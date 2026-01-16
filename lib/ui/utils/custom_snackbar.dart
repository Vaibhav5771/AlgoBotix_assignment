import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showSuccessSnackBar(
    BuildContext context,
    String message, {
      String title = 'Success!',
      Duration duration = const Duration(seconds: 2),
      bool showIcon = true,
    }) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: ContentType.success,
        ),
      ),
    );
}

void showErrorSnackBar(
    BuildContext context,
    String message, {
      String title = 'Error',
      Duration duration = const Duration(seconds: 2),
    }) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: ContentType.failure,
        ),
      ),
    );
}

void showWarningSnackBar(
    BuildContext context,
    String message, {
      String title = 'Warning',
      Duration duration = const Duration(seconds: 2),
    }) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: ContentType.warning,
        ),
      ),
    );
}

void showInfoSnackBar(
    BuildContext context,
    String message, {
      String title = 'Info',
      Duration duration = const Duration(seconds: 2),
    }) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: ContentType.help,
        ),
      ),
    );
}

void showProductDeletedSnackBar(
    BuildContext context, {
      String title = 'Deleted',
      String message = 'Product deleted successfully',
      Duration duration = const Duration(seconds: 2),
    }) {
  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: duration,
        content: AwesomeSnackbarContent(
          title: title,
          message: message,
          contentType: ContentType.success,
        ),
      ),
    );
}