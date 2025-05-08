import 'package:flutter/material.dart';
import 'package:home_service/modules/booking/widget/price_next_navbar.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../providers/log_provider.dart';
import '../../../themes/app_assets.dart';

class OptionsServicePage extends StatefulWidget {
  const OptionsServicePage({super.key});

  @override
  State<OptionsServicePage> createState() => _OptionsServicePageState();
}

class _OptionsServicePageState extends State<OptionsServicePage> {
  LogProvider get logger => const LogProvider('OPTION-SERVICE-PAGE:::');
  final _navigationService = NavigationService();
  int? serviceId;
  String? serviceName;

  int? selectedDuration;
  int? selectedItemAddOn;
  late bool checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      serviceId = args['id'] as int?;
      serviceName = args['name'] as String?;
    }
  }

  final List<Map<String, String>> areaItems = [
    {"hours": "2 hours", "desc": "Maximum 55m2 or 2 rooms"},
    {"hours": "3 hours", "desc": "Maximum 85m2 or 3 rooms"},
    {"hours": "4 hours", "desc": "Maximum 105m2 or 4 rooms"},
  ];

  final List<Map<String, String>> addOnItems = [
    {"image": AppAssetIcons.cookingOutline, "title": "Cooking", "hours": "+1h"},
    {"image": AppAssetIcons.ironing, "title": "Ironing", "hours": "+1h"},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: GestureDetector(
              onTap: Navigator.of(context).pop,
              child: Image.asset(AppAssetIcons.arrowLeft)),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("154 Đường Lý Thường Kiệt",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              Text("Phường 6, Quận Tân Bình",
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BasicAppBar(
              //   isLeading: false,
              //   isTrailing: false,
              //   leading: Image.asset(AppAssetIcons.arrowLeft),
              //   title: 'Options',
              //   onBackButtonPressed: () {
              //     // Go back to the previous tab instead of hardcoding to home
              //     Navigator.of(context).pop();
              //   },
              // ),
              Center(
                child: Text(
                  'Service ID: $serviceId',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.redMedium,
                  ),
                ),
              ),
              _buildDuration(),
              _addOnService(),
            ],
          ),
        ),
        bottomNavigationBar: checked
            ? GestureDetector(
                onTap: () {
                  logger.log('Navigating to ChooseWorkingTimePage');
                  _navigationService.navigateTo(RouteName.chooseTime);
                },
                child: PriceNextNavbar(
                  pricePerHour: '192,000 VND/2h',
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildDuration() {
    return Container(
      padding: const EdgeInsets.all(16),
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
            itemCount: areaItems.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = areaItems[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDuration = index;
                    checked = true;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildAreaItem(
                    index,
                    item['hours'] ?? '',
                    item['desc'] ?? '',
                  ),
                ),
              );
            },
          ),
        ],
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
            color: AppColors.white,
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
