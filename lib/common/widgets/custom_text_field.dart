import 'package:flutter/material.dart';
import 'package:home_service_admin/themes/style_text.dart';

import '../../themes/app_colors.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextStyle? textStyle;
  final TextInputType? keyboardType;
  final String? suffixText;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final InputDecoration? decoration;
  final String? hintText;

  const CommonTextField({
    super.key,
    required this.controller,
    this.textStyle,
    this.keyboardType,
    this.suffixText,
    this.suffixIcon,
    this.onSuffixPressed,
    this.decoration,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColors.primary.withValues(alpha: 0.5),
          selectionHandleColor: AppColors.primary,
          cursorColor: AppColors.primary,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: textStyle,
        decoration: decoration ??
            InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              hintText: hintText,
              suffixText: suffixText,
              suffixIcon: suffixIcon != null
                  ? IconButton(
                      icon: suffixIcon!,
                      onPressed: onSuffixPressed,
                    )
                  : null,
            ),
      ),
    );
  }
}

class TextFieldDialog extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? suffixText;
  final String? labelText;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final int? maxLines;
  final TextStyle? labelStyle;
  const TextFieldDialog({
    super.key,
    required this.controller,
    this.keyboardType,
    this.suffixText,
    this.labelText,
    this.enabledBorder,
    this.focusedBorder,
    this.maxLines = 1,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: AppColors.primary.withValues(alpha: 0.5),
          selectionHandleColor: AppColors.primary,
          cursorColor: AppColors.primary,
        ),
      ),
      child: TextField(
        cursorColor: AppColors.primary,
        maxLines: maxLines,
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          suffixText: suffixText,
          labelText: labelText,
          labelStyle: labelStyle ?? AppTextStyles.bodyMedium,
          enabledBorder: enabledBorder ??
              UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
          focusedBorder: focusedBorder ??
              UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
        ),
      ),
    );
  }
}
