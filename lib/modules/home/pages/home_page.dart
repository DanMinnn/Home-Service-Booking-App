import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/modules/categories/repo/services_repo.dart';
import 'package:home_service/repo/user_repository.dart';
import 'package:home_service/routes/route_name.dart';

import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../common/widgets/stateless/show_snack_bar.dart';
import '../../../providers/log_provider.dart';
import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/app_colors.dart';
import '../../../themes/styles_text.dart';
import '../../categories/bloc/service_cubit.dart';
import '../../categories/bloc/service_state.dart';
import '../../notifications/pages/notification_badge.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NavigationService _navigationService = NavigationService();
  final UserRepository _userRepository = UserRepository();

  LogProvider get logger => const LogProvider('HOMEPAGE:::');
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  String _userName = 'User';
  int _userId = 0;
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    //try get user from cache
    final currentUser = _userRepository.currentUser;
    if (currentUser != null && currentUser.name != null) {
      setState(() {
        _userName = currentUser.name!;
        _userId = currentUser.id ?? 0;
      });
      logger.log('Load user from cache: $_userName');
      return;
    }

    //if user data not in cache, get from local storage
    await _userRepository.loadUserFromStorage();
    final userStorage = _userRepository.currentUser;
    if (userStorage != null && userStorage.name != null) {
      setState(() {
        _userName = userStorage.name!;
        _userId = userStorage.id ?? 0;
      });
      logger.log('Load user from local storage: $_userName');
      return;
    }

    logger.log('Could not load user information');
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BasicAppBar(
              isLeading: true,
              isTrailing: true,
              leading: Image.asset(AppAssetIcons.logoHouse),
              title: 'Welcome,',
              subtitle: _userName,
              trailing: GestureDetector(
                onTap: () {
                  _navigationService.changeTab(1);
                },
                child: GestureDetector(
                  onTap: () {
                    _navigationService
                        .navigateTo(RouteName.notifications, arguments: {
                      'userId': _userId,
                    });
                  },
                  child: NotificationBadge(),
                ),
              ),
            ),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildCategories(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 70,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'All Service Available',
                hintStyle: AppTextStyles.bodyMediumMedium
                    .copyWith(color: AppColors.darkBlue.withValues(alpha: 0.4)),
                prefixIcon: Image.asset(AppAssetIcons.location),
                suffixIcon: Image.asset(AppAssetIcons.gps),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: _isFocused
                      ? BorderSide(
                          color: AppColors.darkBlue.withValues(alpha: 0.05),
                        )
                      : BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.darkBlue.withValues(alpha: 0.4),
                  ),
                ),
                fillColor: AppColors.darkBlue.withValues(alpha: 0.05),
                filled: true,
              ),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ColorFiltered(
                colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                child: Image.asset(AppAssetIcons
                    .search) // Icon(Icons.search, color: AppColors.white),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Categories',
                style: AppTextStyles.bodyLargeSemiBold.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: 20,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  logger.log('See All button pressed');
                  _navigationService.changeTab(2);
                },
                child: Text(
                  'See All',
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.darkBlue.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              )
            ],
          ),
          BlocProvider(
            create: (context) => ServiceCubit(ServicesRepo())..fetchServices(),
            child: BlocBuilder<ServiceCubit, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return const Center(
                    child: Align(
                      alignment: Alignment.center,
                      child:
                          CircularProgressIndicator(color: Color(0xFF386DF3)),
                    ),
                  );
                } else if (state is ServiceLoaded) {
                  final services = state.services;
                  if (services.isEmpty) {
                    return const Center(
                      child: Text('No services available'),
                    );
                  }
                  //filter cleaning and cooking services
                  final displayServices = [...services];
                  final cleaningService = services.firstWhere(
                    (s) => s.id == 20,
                  );

                  final cookingService = services.firstWhere(
                    (s) => s.id == 21,
                  );
                  if (displayServices.length > 6) {
                    displayServices
                        .removeWhere((s) => s.id == 20 || s.id == 21);
                    displayServices.insert(0, cleaningService);
                    displayServices.insert(1, cookingService);
                    while (displayServices.length > 6) {
                      displayServices.removeLast();
                    }
                  }
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 12,
                      childAspectRatio: 101 / 124,
                    ),
                    itemCount: displayServices.length,
                    itemBuilder: (context, index) {
                      return _buildItemGridView(
                        displayServices[index].name ?? '',
                        displayServices[index].icon ?? '',
                        displayServices[index].id ?? 0,
                      );
                    },
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
          ),
        ],
      ),
    );
  }

  Widget _buildItemGridView(String nameService, String image, int id) {
    return GestureDetector(
      onTap: () {
        if (id == 21) {
          _navigationService.navigateTo(
            RouteName.serviceCooking,
            arguments: {
              'id': id,
              'name': nameService,
            },
          );
        } else if (id == 20) {
          _navigationService.navigateTo(
            RouteName.serviceCleaning,
            arguments: {
              'id': id,
              'name': nameService,
            },
          );
        } else {
          ShowSnackBar.showSuccess(
              context, 'This service coming soon', 'Under development');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppAssetIcons.iconPath + image,
              width: 40,
              height: 40,
              filterQuality: FilterQuality.high,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              nameService,
              style: AppTextStyles.bodyMediumMedium.copyWith(
                color: AppColors.darkBlue.withValues(alpha: 0.8),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
