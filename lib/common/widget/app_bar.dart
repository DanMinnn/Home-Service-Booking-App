import 'package:flutter/material.dart';
import 'package:home_service_tasker/theme/app_assets.dart';
import 'package:home_service_tasker/theme/styles_text.dart';

import '../../theme/app_colors.dart';

class BasicAppBar extends StatelessWidget {
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onPressed;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool icon;
  final bool backgroundColor;
  // final bool isLeading;
  // final bool isTrailing;

  const BasicAppBar({
    super.key,
    this.onBackButtonPressed,
    this.onPressed,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.icon = false,
    this.backgroundColor = false,
    // this.isLeading = false,
    // this.isTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      color: backgroundColor ? AppColors.dark : AppColors.white,
      child: Padding(
        padding: icon
            ? const EdgeInsets.symmetric(horizontal: 24)
            : const EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            leading ?? const SizedBox(),
            _buildTitle(),
            trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeading() {
    return GestureDetector(
      onTap: onBackButtonPressed,
      child: leading ?? const SizedBox(),
    );
  }

  Widget _buildTitle() {
    return icon
        ? Row(
            children: [
              Image.asset(
                AppAssetsIcons.logoAppBar,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 4),
              Text('$title',
                  style:
                      AppTextStyles.headline4.copyWith(color: AppColors.white))
            ],
          )
        : Text(
            '$title',
            style: AppTextStyles.headline4.copyWith(color: AppColors.white),
          );
  }

  Widget _buildTrailing() {
    return GestureDetector(
      onTap: onPressed,
      child: trailing ?? const SizedBox(),
    );
  }
}
