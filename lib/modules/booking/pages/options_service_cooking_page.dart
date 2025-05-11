import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/custom_snack_bar.dart';
import 'package:home_service/modules/booking/models/booking_data.dart';
import 'package:home_service/modules/categories/bloc/service_package_cubit.dart';
import 'package:home_service/modules/categories/bloc/service_package_state.dart';
import 'package:home_service/modules/categories/models/service_package.dart';
import 'package:home_service/modules/categories/repo/services_repo.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:intl/intl.dart';

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
  final Map<String, TextEditingController> _courseControllers = {};

  int _peopleCount = 2;
  final int _minPeopleCount = 2;
  final int _maxPeopleCount = 8;

  // Track which course is selected
  String? _selectedCourse;
  int _dishCount = 2; // Default dish count

  // Track which prefer style is selected
  String? _selectedPreferStyle;

  late int serviceId;
  String? serviceName;

  // Selected package and variant
  ServicePackages? _selectedPackage; // 2, 2.5, 3, 3.5 hours
  double _totalPrice = 0;

  final formatter = NumberFormat('#,###');

  late BookingData bookingData = BookingData(
    serviceId: serviceId,
    serviceName: serviceName,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      serviceId = args['id'] as int;
      serviceName = args['name'] as String?;

      bookingData = bookingData.copyWith(
        serviceId: serviceId,
        serviceName: serviceName,
      );
    }
  }

  @override
  void dispose() {
    // Dispose all course controllers
    for (var controller in _courseControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Find the appropriate package based on dishes and people count
  void _updateSelectedPackage(List<ServicePackages> packages) {
    // Reset current selection
    _selectedPackage = null;
    _totalPrice = 0;

    for (var package in packages) {
      if (package.packageVariants != null) {
        for (var variant in package.packageVariants!) {
          // Parse the variant name to get dish and people ranges
          if (variant.name != null) {
            bool isMatch =
                _isVariantMatch(variant.name!, _dishCount, _peopleCount);

            if (isMatch) {
              setState(() {
                _selectedPackage = package;
                _totalPrice = package.basePrice;
              });
              logger.log(
                  'Selected package: ${package.name}, Price: $_totalPrice');
              return;
            }
          }
        }
      }
    }

    // If no match found, find closest package
    _findClosestPackage(packages);
  }

  void _findClosestPackage(List<ServicePackages> packages) {
    // Default to first package if no match
    if (packages.isNotEmpty) {
      setState(() {
        _selectedPackage = packages[0];
        _totalPrice = packages[0].basePrice;
        // if (packages[0].packageVariants != null &&
        //     packages[0].packageVariants!.isNotEmpty) {
        //   _totalPrice += packages[0].packageVariants![0].additionalPrice ?? 0;
        // }
      });
    }
  }

  bool _isVariantMatch(String variantName, int dishCount, int peopleCount) {
    // Parse variant name like "02–03 dishes, 02–04 persons"
    try {
      final parts = variantName.split(',');
      if (parts.length >= 2) {
        // Parse dishes part
        final dishesPart = parts[0].trim();
        final dishesRange = _parseRange(dishesPart);

        // Parse persons part
        final personsPart = parts[1].trim();
        final personsRange = _parseRange(personsPart);

        // Check if dish count and people count are within range
        final isDishInRange =
            dishCount >= dishesRange.$1 && dishCount <= dishesRange.$2;
        final isPeopleInRange =
            peopleCount >= personsRange.$1 && peopleCount <= personsRange.$2;

        return isDishInRange && isPeopleInRange;
      }
    } catch (e) {
      logger.log('Error parsing variant range: $e');
    }
    return false;
  }

  (int start, int end) _parseRange(String rangeText) {
    // Extract numbers from strings like "02–03 dishes" or "02–04 persons"
    final numbers = RegExp(r'(\d+)')
        .allMatches(rangeText)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    if (numbers.length >= 2) {
      return (numbers[0], numbers[1]);
    }
    return (2, 8); // Default range if parsing fails
  }

  void _updateDishCount() {
    if (_selectedCourse == null) {
      _dishCount = 2; // Default
      return;
    }

    // Extract dish count from selection, e.g., "2 courses" -> 2
    _dishCount = int.parse(_selectedCourse!.split(' ')[0]);
    logger.log('Updated dish count: $_dishCount');
  }

  bool _areAllCourseFieldsFilled() {
    if (_selectedCourse == null) {
      return false;
    }

    final int courseCount = int.parse(_selectedCourse!.split('')[0]);

    for (int i = 1; i <= courseCount; i++) {
      final controller = _courseControllers['Course $i'];
      if (controller == null || controller.text.trim().isEmpty) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocProvider(
        create: (context) => ServicePackageCubit(ServicesRepo())
          ..fetchServicePackages(serviceId),
        child: BlocBuilder<ServicePackageCubit, ServicePackagesState>(
          builder: (context, state) {
            if (state is ServicePackagesLoading) {
              return const Center(
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (state is ServicePackagesError) {
              return Center(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Error loading service packages',
                    style: AppTextStyles.bodyLargeSemiBold.copyWith(
                      color: AppColors.redMedium,
                    ),
                  ),
                ),
              );
            } else if (state is ServicePackagesLoaded) {
              if (_selectedPackage == null) {
                Future.microtask(() {
                  _updateSelectedPackage(state.servicePackages);
                });
              }

              return SingleChildScrollView(
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
                    _buildSelectPerson(state),
                    const SizedBox(height: 16),
                    _buildCourse(state),
                    const SizedBox(height: 16),
                    _buildPreferStyle(),
                    if (_selectedPackage != null) ...[
                      const SizedBox(height: 16),
                      _buildSelectedPackageInfo(),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          if (_selectedCourse == null) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const CustomSnackBar(
                backgroundColor: AppColors.snackBarError,
                closeColor: AppColors.iconClose,
                bubbleColor: AppColors.bubbles,
                title: "Oh snap!",
                message: "Please select a course option",
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.transparent,
              elevation: 0,
              duration: const Duration(seconds: 3),
            ));
            return;
          }
          if (!_areAllCourseFieldsFilled()) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const CustomSnackBar(
                backgroundColor: AppColors.snackBarError,
                closeColor: AppColors.iconClose,
                bubbleColor: AppColors.bubbles,
                title: "Oh snap!",
                message: "Please fill your course name",
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.transparent,
              elevation: 0,
              duration: const Duration(seconds: 3),
            ));
            return;
          }

          logger.log(
              'Selected course: ${_courseControllers.values.map((e) => e.text).toList()}');

          bookingData = bookingData.copyWith(
            packageId: _selectedPackage?.id,
            packageName: _selectedPackage?.name,
            variantName: _selectedPackage?.packageVariants?[0].name,
            basePrice: _totalPrice,
            formattedPrice:
                '${formatter.format(_totalPrice)} VND/ ${_selectedPackage?.name}',
            numberOfPeople: _peopleCount,
            numberOfCourses: _dishCount,
            coursesNames: _courseControllers.values
                .map((controller) => controller.text)
                .toList(),
            preferStyle: _selectedPreferStyle,
          );

          _navigationService.navigateTo(RouteName.chooseTime,
              arguments: bookingData);
        },
        child: PriceNextNavbar(
          pricePerHour: _totalPrice > 0
              ? '${formatter.format(_totalPrice)} VND/ ${_selectedPackage?.name}'
              : '0 VND',
        ),
      ),
    );
  }

  Widget _buildSelectedPackageInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected Package',
              style: AppTextStyles.bodyLargeSemiBold.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedPackage?.name ?? 'No package selected',
              style: AppTextStyles.bodyMediumMedium.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
            Text(
              _selectedPackage?.description ?? '',
              style: AppTextStyles.bodySmallRegular.copyWith(
                color: AppColors.darkBlue.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ${formatter.format(_totalPrice)} VND',
              style: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectPerson(ServicePackagesLoaded state) {
    bool canDecrease = _peopleCount > _minPeopleCount;
    bool canIncrease = _peopleCount < _maxPeopleCount;

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
                              _peopleCount--;
                              _updateSelectedPackage(state.servicePackages);
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
                  '$_peopleCount',
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
                              _peopleCount++;
                              _updateSelectedPackage(state.servicePackages);
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

  Widget _buildCourse(ServicePackagesLoaded state) {
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
          _buildCourseItem('2 courses', state),
          const SizedBox(height: 8),
          _buildCourseItem('3 courses', state),
          const SizedBox(height: 8),
          _buildCourseItem('4 courses', state),
        ],
      ),
    );
  }

  Widget _buildCourseItem(String course, ServicePackagesLoaded state) {
    final bool isSelected = _selectedCourse == course;
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              // Toggle selection - if already selected, deselect it
              _selectedCourse = isSelected ? null : course;
              _updateDishCount();
              _updateSelectedPackage(state.servicePackages);
            });
            logger.log('Selected course: $_selectedCourse');
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
    // Create controller if it doesn't exist
    if (!_courseControllers.containsKey(courses)) {
      _courseControllers[courses] = TextEditingController();
    }

    _courseControllers[courses]!.addListener(() {
      setState(() {});
    });
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
          controller: _courseControllers[courses],
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
          onChanged: (value) {
            if (value.isNotEmpty) {
              // Field is filled
            }
          },
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
