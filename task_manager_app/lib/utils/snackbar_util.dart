import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static void showError(BuildContext context, String message) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.errorContainer,
          content: Text(
            message,
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
        ),
      );
  }
}
