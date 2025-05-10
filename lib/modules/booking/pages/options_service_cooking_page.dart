import 'package:flutter/material.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';

import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/styles_text.dart';
import '../widget/price_next_navbar.dart';

class OptionsServiceCookingPage extends StatefulWidget {
  const OptionsServiceCookingPage({super.key});

  @override
  State<OptionsServiceCookingPage> createState() =>
      _OptionsServiceCookingPageState();
}

class _OptionsServiceCookingPageState extends State<OptionsServiceCookingPage> {
  LogProvider get logger =>
      const LogProvider('OPTIONS-SERVICE-COOKING-PAGE:::');
  final NavigationService _navigationService = NavigationService();
  final TextEditingController _courseName = TextEditingController();

  int _count = 2;
  final int _minCount = 2;
  final int _maxCount = 8;

  // Track which course is selected
  String? _selectedCourse;
  // Track which prefer style is selected
  String? _selectedPreferStyle;

  @override
  void dispose() {
    super.dispose();
    _courseName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicAppBar(
              isLeading: false,
              isTrailing: false,
              leading: GestureDetector(
                onTap: () {
                  _navigationService.goBack();
                },
                child: Image.asset(AppAssetIcons.arrowLeft),
              ),
              title: 'Choose Options Cooking',
            ),
            _buildSelectPerson(),
            const SizedBox(height: 16),
            _buildCourse(),
            const SizedBox(height: 16),
            _buildPreferStyle(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: PriceNextNavbar(
        pricePerHour: '192,000 VND',
      ),
    );
  }

  Widget _buildSelectPerson() {
    bool canDecrease = _count > _minCount;
    bool canIncrease = _count < _maxCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'People',
            style: AppTextStyles.h6Bold.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: canDecrease
                        ? AppColors.darkBlue.withValues(alpha: 0.05)
                        : AppColors.darkBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: canDecrease
                        ? () {
                            setState(() {
                              _count--;
                            });
                          }
                        : null,
                    icon: Image.asset(
                      AppAssetIcons.minus,
                      color: canDecrease
                          ? AppColors.darkBlue
                          : AppColors.darkBlue.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Text(
                  '$_count',
                  style: AppTextStyles.bodyMediumMedium.copyWith(
                    fontSize: 18,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: canIncrease
                        ? AppColors.darkBlue.withValues(alpha: 0.05)
                        : AppColors.darkBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: canIncrease
                        ? () {
                            setState(() {
                              _count++;
                            });
                          }
                        : null,
                    icon: Image.asset(
                      AppAssetIcons.add,
                      color: canIncrease
                          ? AppColors.darkBlue
                          : AppColors.darkBlue.withValues(alpha: 0.1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourse() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course',
            style: AppTextStyles.h6Bold.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 14),
          _buildCourseItem('2 courses'),
          const SizedBox(height: 8),
          _buildCourseItem('3 courses'),
          const SizedBox(height: 8),
          _buildCourseItem('4 courses'),
        ],
      ),
    );
  }

  Widget _buildCourseItem(String course) {
    final bool isSelected = _selectedCourse == course;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // Toggle selection - if already selected, deselect it
              _selectedCourse = isSelected ? null : course;
            });
            logger.log('Selected course: $course');
          },
          child: Container(
            padding: const EdgeInsets.all(12.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected
                    ? AppColors.blue
                    : AppColors.darkBlue.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  course,
                  style: AppTextStyles.bodyLargeMedium.copyWith(
                    fontWeight: FontWeight.w400,
                    color: isSelected ? AppColors.blue : AppColors.darkBlue,
                  ),
                ),
                if (isSelected)
                  Image.asset(
                    AppAssetIcons.tickCourse,
                    color: AppColors.blue,
                  ),
              ],
            ),
          ),
        ),
        // Show the course details if this course is selected
        if (isSelected) _buildItemCourseDetail(course),
      ],
    );
  }

  Widget _buildItemCourseDetail(String course) {
    // Extract the number from the course string (e.g., "2 courses" -> 2)
    final int courseCount = int.parse(course.split(' ')[0]);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.darkBlue.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 1; i <= courseCount; i++)
              _buildItemDetail('Course $i'),
          ],
        ),
      ),
    );
  }

  Widget _buildItemDetail(String courses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
          child: Text(
            courses,
            style: AppTextStyles.bodyMediumMedium,
          ),
        ),
        TextField(
          controller: _courseName,
          decoration: InputDecoration(
            hintText: 'Enter course name',
            hintStyle: AppTextStyles.bodyMediumMedium.copyWith(
              color: AppColors.darkBlue.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            fillColor: AppColors.darkBlue.withValues(alpha: 0.05),
            filled: true,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPreferStyle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prefer Style',
            style: AppTextStyles.h6Bold.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 14),
          _buildPreferStyleItem('Northern'),
          const SizedBox(height: 8),
          _buildPreferStyleItem('Central'),
          const SizedBox(height: 8),
          _buildPreferStyleItem('Southern'),
        ],
      ),
    );
  }

  Widget _buildPreferStyleItem(String preferStyle) {
    bool isSelected = _selectedPreferStyle == preferStyle;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreferStyle = isSelected ? null : preferStyle;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppColors.blue
                : AppColors.darkBlue.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Text(
              preferStyle,
              style: AppTextStyles.bodyLargeMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: AppColors.darkBlue,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Image.asset(
                AppAssetIcons.tickCourse,
                color: AppColors.blue,
              ),
          ],
        ),
      ),
    );
  }
}
