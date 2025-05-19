import 'package:flutter/material.dart';
import 'package:home_service_tasker/theme/app_colors.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final String? initialValue;
  final Function(String) onChanged;
  final List<String>? errorMessages;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.isPassword,
    this.initialValue,
    this.errorMessages,
    required this.onChanged,
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
    final errorMessages = widget.errorMessages ?? [];
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
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
              color: AppColors.white,
            ),
            child: TextField(
              onChanged: widget.onChanged,
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
        SizedBox(height: 4),
        ...errorMessages.map(
          (msg) => Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              msg,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
