import 'package:flutter/material.dart';

enum SnackbarType { success, error, info, warning }

void showCustomSnackbar(
  BuildContext context,
  String message, {
  SnackbarType type = SnackbarType.info,
  IconData? icon,
}) {
  Color bgColor;
  IconData usedIcon;
  switch (type) {
    case SnackbarType.success:
      bgColor = Colors.green.shade700;
      usedIcon = icon ?? Icons.check_circle_rounded;
      break;
    case SnackbarType.error:
      bgColor = Colors.red.shade700;
      usedIcon = icon ?? Icons.error_rounded;
      break;
    case SnackbarType.warning:
      bgColor = Colors.orange.shade800;
      usedIcon = icon ?? Icons.warning_amber_rounded;
      break;
    case SnackbarType.info:
      bgColor = const Color(0xFF1B3C53);
      usedIcon = icon ?? Icons.info_rounded;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(usedIcon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      elevation: 8,
      duration: const Duration(seconds: 3),
    ),
  );
}
