import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';

class ConfirmBox extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ConfirmBox({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyLargeMedium,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildChildrenWithDivider(),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildChildrenWithDivider() {
    final spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      if (i != 0) {
        spacedChildren.add(const SizedBox(height: 8));
        spacedChildren.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: DottedLine(
            direction: Axis.horizontal,
            lineLength: double.infinity,
            dashColor: AppColors.darkBlue.withValues(alpha: 0.2),
          ),
        ));
        spacedChildren.add(const SizedBox(height: 8));
      }
      spacedChildren.add(children[i]);
    }
    return spacedChildren;
  }
}
