import 'package:flutter/material.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final String? initialValue;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.isPassword,
    this.initialValue,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _hasFocus = hasFocus;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasFocus ? AppColors.primary : AppColors.grey,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white,
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.isPassword && _obscureText,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null,
              ),
              style: AppTextStyles.paragraph3,
            ),
          ),
        ),
      ],
    );
  }
}
