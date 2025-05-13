import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';
import 'custom_snack_bar.dart';

class SnackBarError {
  static void showError(BuildContext context, String message) {
    // Clear any existing SnackBars to prevent conflicts
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: CustomSnackBar(
        backgroundColor: AppColors.snackBarError,
        closeColor: AppColors.iconClose,
        bubbleColor: AppColors.bubbles,
        title: "Oh snap!",
        message: message,
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 3),
    ));
  }
}
