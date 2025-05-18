import 'package:flutter/material.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

class BasicButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final Widget? prefixIcon;
  final VoidCallback? onPressed;

  const BasicButton({
    super.key,
    this.onPressed,
    required this.backgroundColor,
    required this.textColor,
    required this.text,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: prefixIcon != null
          ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    const SizedBox(width: 10),
                  ],
                  Text(text, style: AppTextStyles.headline6),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(text, style: AppTextStyles.headline6),
            ),
    );
  }
}
