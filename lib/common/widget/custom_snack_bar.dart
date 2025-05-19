import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../theme/styles_text.dart';

class CustomSnackBar extends StatelessWidget {
  final String title;
  final String message;
  final String icon;
  final Color backgroundColor;
  final Color bubbleColor;
  final Color closeColor;

  const CustomSnackBar({
    super.key,
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.bubbleColor,
    required this.closeColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Make the container more compact to avoid overflow
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 80,
          decoration: BoxDecoration(
              color: backgroundColor, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headline4.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      message,
                      style: AppTextStyles.headline5.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
            ),
            child: SvgPicture.asset(
              "assets/images/icons/bubbles.svg",
              height: 48,
              width: 40,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                bubbleColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 10,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/icons/fail.svg",
                height: 40,
                colorFilter: ColorFilter.mode(
                  closeColor,
                  BlendMode.srcIn,
                ),
              ),
              Positioned(
                top: 10,
                child: SvgPicture.asset(icon, height: 16),
              ),
            ],
          ),
        )
      ],
    );
  }
}
