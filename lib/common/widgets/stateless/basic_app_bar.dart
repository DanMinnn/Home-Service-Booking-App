import 'package:flutter/material.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

class BasicAppBar extends StatelessWidget {
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onPressed;
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Widget? action;
  final bool isLeading;
  final bool isTrailing;

  const BasicAppBar({
    super.key,
    this.onBackButtonPressed,
    this.onPressed,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.action,
    required this.isLeading,
    required this.isTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildLeading(),
              const SizedBox(width: 20),
              _buildTitle(),
            ],
          ),
          Row(
            children: [
              _buildAction(),
              const SizedBox(width: 20),
              _buildTrailing(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    return GestureDetector(
      onTap: onBackButtonPressed,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isLeading
              ? AppColors.darkBlue
              : AppColors.darkBlue.withValues(
                  alpha: 0.05,
                ),
          shape: BoxShape.circle,
        ),
        child: leading ?? const SizedBox(),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Text(
            title!,
            style: AppTextStyles.h5Bold.copyWith(color: AppColors.darkBlue),
          ),
        const SizedBox(height: 4),
        if (subtitle != null)
          Row(
            children: [
              Image.asset(AppAssetIcons.raiseHand),
              const SizedBox(width: 4),
              Text(
                subtitle!,
                style: AppTextStyles.bodyMediumMedium.copyWith(
                  color: AppColors.subTitle,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
      ],
    );
  }

  Widget _buildTrailing() {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 45,
        height: 45,
        decoration: isTrailing
            ? BoxDecoration(
                color: AppColors.darkBlue.withValues(
                  alpha: 0.05,
                ),
                shape: BoxShape.circle,
              )
            : null,
        child: trailing ?? const SizedBox(),
      ),
    );
  }

  Widget _buildAction() {
    return GestureDetector(
      onTap: onPressed,
      /*child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withValues(
            alpha: 0.05,
          ),
          shape: BoxShape.circle,
        ),
        child: action ?? const SizedBox(),
      ),*/
      child: action ?? const SizedBox(),
    );
  }
}
