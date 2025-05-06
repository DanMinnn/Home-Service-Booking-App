import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/themes/app_assets.dart';

import '../../../services/navigation_service.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';
import '../../home/bloc/categories/service_cubit.dart';
import '../../home/bloc/categories/service_state.dart';
import '../../home/repo/services_repo.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _navigationService = NavigationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BasicAppBar(
                isLeading: false,
                isTrailing: false,
                leading: Image.asset(AppAssetIcons.arrowLeft),
                title: 'Category',
                onBackButtonPressed: () {
                  // Go back to the previous tab instead of hardcoding to home
                  _navigationService.goBackToPreviousTab();
                },
              ),
              _buildCategories(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return BlocProvider(
      create: (context) => ServiceCubit(ServicesRepo())..fetchServices(),
      child: BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          if (state is ServiceLoading) {
            return const Center(
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is ServiceLoaded) {
            final services = state.services;
            if (services.isEmpty) {
              return const Center(
                child: Text('No services available'),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.6,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) => _buildItemGridView(
                  services[index].name ?? '',
                  services[index].icon ?? '',
                ),
              ),
            );
          }
          return Center(
            child: Align(
              alignment: Alignment.center,
              child: Text(
                'Sorry, something went wrong',
                style: AppTextStyles.bodyLargeSemiBold.copyWith(
                  color: AppColors.redMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemGridView(String title, String image) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: AppColors.darkBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              AppAssetIcons.iconPath + image,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.captionMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.darkBlue,
          ),
        )
      ],
    );
  }
}
