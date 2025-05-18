import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool isPassword;
  final TextInputType keyboardType;
  final Function(String) onChanged;
  final Function() onUnfocused;
  final List<String>? errorMessages;
  final TextEditingController? controller;
  final bool fillColor;
  final bool readOnly;
  final bool showLabel;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    required this.keyboardType,
    required this.onChanged,
    required this.onUnfocused,
    this.errorMessages,
    this.isPassword = false,
    this.controller,
    this.fillColor = true,
    this.readOnly = false,
    this.showLabel = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _obscureText = widget.isPassword;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (!_focusNode.hasFocus) {
      widget.onUnfocused();
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessages = widget.errorMessages ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showLabel
            ? Text(
                widget.label,
                style: AppTextStyles.bodyMediumMedium.copyWith(
                  color: AppColors.darkBlue,
                ),
              )
            : const SizedBox(),
        SizedBox(height: 8),
        TextFormField(
          readOnly: widget.readOnly,
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.isPassword ? _obscureText : false,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: AppTextStyles.bodySmallMedium.copyWith(
            color: AppColors.darkBlue,
            fontSize: 16,
          ),
          cursorColor: AppColors.darkBlue,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            hintText: widget.hintText,
            hintStyle: widget.fillColor
                ? AppTextStyles.bodySmallMedium.copyWith(
                    color: AppColors.darkBlue.withValues(alpha: 0.6),
                  )
                : AppTextStyles.bodySmallMedium.copyWith(
                    color: AppColors.darkBlue.withValues(alpha: 0.8),
                  ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: _isFocused
                  ? BorderSide(color: AppColors.blue, width: 1.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.blue, width: 1.5),
            ),
            fillColor: widget.fillColor
                ? AppColors.blue.withValues(alpha: 0.05)
                : AppColors.white,
            filled: true,
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
