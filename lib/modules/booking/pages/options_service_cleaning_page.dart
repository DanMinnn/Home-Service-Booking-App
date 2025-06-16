import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/booking/models/booking_data.dart';
import 'package:home_service/modules/booking/widget/price_next_navbar.dart';
import 'package:home_service/modules/categories/bloc/service_package_cubit.dart';
import 'package:home_service/modules/categories/bloc/service_package_state.dart';
import 'package:home_service/modules/categories/repo/services_repo.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../providers/log_provider.dart';
import '../../../repo/user_repository.dart';
import '../../../themes/app_assets.dart';

class OptionsServiceCleaningPage extends StatefulWidget {
  const OptionsServiceCleaningPage({super.key});

  @override
  State<OptionsServiceCleaningPage> createState() =>
      _OptionsServiceCleaningPageState();
}

class _OptionsServiceCleaningPageState
    extends State<OptionsServiceCleaningPage> {
  LogProvider get logger => const LogProvider('OPTION-SERVICE-PAGE:::');
  final _navigationService = NavigationService();
  final UserRepository _userRepository = UserRepository();

  int? serviceId;
  String? serviceName;

  int? selectedDuration;
  int? selectedItemAddOn;
  late bool checked = false;

  String pricePerHour = '';
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
      serviceId = args['id'] as int?;
      serviceName = args['name'] as String?;

      bookingData = bookingData.copyWith(
        serviceId: serviceId,
        serviceName: serviceName,
        user: _userRepository.currentUser,
      );
    }
  }

  final List<Map<String, String>> addOnItems = [
    {"image": AppAssetIcons.cookingOutline, "title": "Cooking", "hours": "+1h"},
    {"image": AppAssetIcons.ironing, "title": "Ironing", "hours": "+1h"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocProvider(
        create: (context) => ServicePackageCubit(ServicesRepo())
          ..fetchServicePackages(serviceId!),
        child: BlocBuilder<ServicePackageCubit, ServicePackagesState>(
          builder: (context, state) {
            if (state is ServicePackagesLoading) {
              return const Center(
                child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(color: Color(0xFF386DF3)),
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
            }
            return SafeArea(
              child: SingleChildScrollView(
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
                          child: Image.asset(AppAssetIcons.arrowLeft)),
                      title: 'Options Cleaning',
                    ),
                    _buildDuration(state),
                    _addOnService(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: checked
          ? GestureDetector(
              onTap: () {
                logger.log('Navigating to ChooseWorkingTimePage');
                _navigationService.navigateTo(RouteName.chooseTime,
                    arguments: bookingData);
              },
              child: PriceNextNavbar(
                pricePerHour: pricePerHour,
              ),
            )
          : null,
    );
  }

  Widget _buildDuration(ServicePackagesState state) {
    if (state is ServicePackagesLoaded) {
      final servicePackages = state.servicePackages;
      logger.log('Selected duration: $servicePackages.');
      if (servicePackages.isEmpty) {
        return Center(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              'No service packages available',
              style: AppTextStyles.bodyLargeSemiBold.copyWith(
                color: AppColors.redMedium,
              ),
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration',
              style: AppTextStyles.h6Bold.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please estimate the exact area for cleaning',
              style: AppTextStyles.bodyMediumRegular.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
            ListView.builder(
              itemCount: servicePackages.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                String formattedPrice =
                    formatter.format(servicePackages[index].basePrice);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDuration = index;
                      checked = true;

                      pricePerHour =
                          '$formattedPrice VND/${servicePackages[index].name}';

                      bookingData = bookingData.copyWith(
                        packageId: servicePackages[index].id,
                        packageName: servicePackages[index].name,
                        packageDescription: servicePackages[index].description,
                        basePrice: servicePackages[index].basePrice,
                        formattedPrice: pricePerHour,
                      );

                      logger.log(
                          'Package variant: ${servicePackages[index].packageVariants}');
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: _buildAreaItem(
                      index,
                      servicePackages[index].name,
                      servicePackages[index].description,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
    return Center(
      child: Align(
        alignment: Alignment.center,
        child: Text(
          'No service packages available',
          style: AppTextStyles.bodyLargeSemiBold.copyWith(
            color: AppColors.redMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildAreaItem(int index, String hours, String description) {
    final bool isSelected = selectedDuration == index;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected
              ? AppColors.darkBlue
              : AppColors.darkBlue.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hours,
            style: AppTextStyles.bodyLargeSemiBold.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMediumRegular.copyWith(
              color: AppColors.darkBlue.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addOnService() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.darkBlue.withValues(alpha: 0.05),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add-on Service',
            style: AppTextStyles.h6Bold.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You can choose to add service',
            style: AppTextStyles.bodyMediumRegular.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 10),
          _buildAddOn(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Upcoming',
              style: AppTextStyles.bodyLargeRegular.copyWith(
                color: AppColors.red.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOn() {
    return Align(
      alignment: Alignment.center,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(2, (index) {
            final item = addOnItems[index];
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedItemAddOn = index;
                  });
                },
                child: _buildItemAddOn(
                  index,
                  item['image'] ?? '',
                  item['title'] ?? '',
                  item['hours'] ?? '',
                ),
              ),
            );
          })),
    );
  }

  Widget _buildItemAddOn(int index, String image, String title, String hours) {
    final bool isSelected = selectedItemAddOn == index;
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.darkBlue
                  : AppColors.darkBlue.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Image.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: AppTextStyles.bodyMediumMedium.copyWith(
            color: AppColors.darkBlue,
          ),
        ),
        Text(
          hours,
          style: AppTextStyles.bodyMediumRegular.copyWith(
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}
