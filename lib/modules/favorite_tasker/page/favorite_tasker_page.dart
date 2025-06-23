import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/show_snack_bar.dart';
import 'package:home_service/modules/favorite_tasker/bloc/ftasker_bloc.dart';
import 'package:home_service/modules/favorite_tasker/model/tasker.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/routes/route_name.dart';
import 'package:home_service/themes/styles_text.dart';

import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/app_colors.dart';
import '../bloc/ftasker_event.dart';
import '../bloc/ftasker_state.dart';
import '../model/chat_room_req.dart';
import '../repo/favorite_tasker_repo.dart';

class FavoriteTaskerPage extends StatefulWidget {
  const FavoriteTaskerPage({super.key});

  @override
  State<FavoriteTaskerPage> createState() => _FavoriteTaskerPageState();
}

class _FavoriteTaskerPageState extends State<FavoriteTaskerPage> {
  final LogProvider logger = LogProvider(':::::FAVORITE-TASKER-PAGE:::::');
  final _navigationService = NavigationService();
  int userId = 0;
  late FTaskerBloc _fTaskerBloc;
  final FavoriteTaskerRepo _favoriteTaskerRepo = FavoriteTaskerRepo();

  // Map to store processed images for each tasker
  final Map<int, Uint8List?> _processedAvatars = {};

  List<Color> bgColors = [
    AppColors.avtBg,
    AppColors.darkBlue20,
    AppColors.darkBlue.withValues(alpha: 0.1),
  ];

  @override
  void initState() {
    super.initState();
    _fTaskerBloc = FTaskerBloc(FavoriteTaskerRepo());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      setState(() {
        userId = args['userId'] ?? 0;
      });
      logger.log('User ID: $userId');
    } else {
      logger.log('No arguments passed to FavoriteTaskerPage');
    }
  }

  // Process the avatar for a tasker
  Future<void> _processTaskerAvatar(Tasker tasker) async {
    if (tasker.profileImage != null &&
        !_processedAvatars.containsKey(tasker.id)) {
      try {
        final processedImage =
            await _favoriteTaskerRepo.removeBg(tasker.profileImage!);
        if (processedImage != null) {
          setState(() {
            _processedAvatars[tasker.id] = processedImage;
          });
        }
      } catch (e) {
        logger.log('Failed to process avatar for tasker ${tasker.id}: $e');
      }
    }
  }

  // Process all taskers' avatars
  Future<void> _processTaskersAvatars(List<Tasker> taskers) async {
    for (final tasker in taskers) {
      if (tasker.profileImage != null) {
        await _processTaskerAvatar(tasker);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
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
              title: 'Favorite Tasker',
            ),
            const SizedBox(height: 16),
            BlocProvider.value(
              value: _fTaskerBloc
                ..add(
                  FTaskerLoadEvent(userId: userId),
                ),
              child: Expanded(
                child: BlocBuilder<FTaskerBloc, FTaskerState>(
                  builder: (context, state) {
                    if (state is FTaskerLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: AppColors.blue,
                        ),
                      );
                    } else if (state is FTaskerError) {
                      return Center(
                        child: Text('Something went wrong',
                            style: AppTextStyles.bodyLargeRegular.copyWith(
                              color: AppColors.red,
                            )),
                      );
                    } else if (state is FTaskerLoaded) {
                      final taskers = state.taskers;
                      if (taskers.isEmpty) {
                        return Center(
                          child: Text(
                            'No favorite taskers found.',
                            style: AppTextStyles.bodyLargeRegular.copyWith(
                              color: AppColors.red,
                            ),
                          ),
                        );
                      } else {
                        // Process avatars when taskers are loaded
                        _processTaskersAvatars(taskers);

                        return SingleChildScrollView(
                          child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                              ),
                              itemBuilder: (context, index) {
                                return _buildCardTasker(taskers[index],
                                    bgColors[index % bgColors.length]);
                              },
                              itemCount: taskers.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics()),
                        );
                      }
                    } else if (state is ChatRoomCreated) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ShowSnackBar.showSuccess(
                            context, state.message, 'Chat Room Created');
                        _navigationService.navigateTo(RouteName.chatPage);
                      });
                    }
                    return Center(
                      child: Text('Loading...'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTasker(Tasker tasker, Color bgColor) {
    final processedAvatar = _processedAvatars[tasker.id];
    bool isRemoveTasker = false;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text('Do you want to chat with tasker?'),
                  titleTextStyle: AppTextStyles.bodyLargeSemiBold
                      .copyWith(color: AppColors.darkBlue),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: AppTextStyles.bodyMediumRegular.copyWith(
                          color: AppColors.darkBlue.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await Future.delayed(Duration(milliseconds: 100));
                          final chatRoomReq = ChatRoomReq(
                            taskerId: tasker.id,
                            userId: userId,
                          );
                          _fTaskerBloc.add(ChatTaskerEvent(
                            chatRoomReq: chatRoomReq,
                          ));
                        },
                        child: Text(
                          'Chat',
                          style: AppTextStyles.bodyMediumRegular.copyWith(
                            color: AppColors.green,
                          ),
                        )),
                  ],
                );
              });
        },
        child: Container(
          width: 157,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: tasker.profileImage != null
                        ? Image.network(
                            tasker.profileImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.asset(
                            AppAssetsBackgrounds.avt,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ), /*processedAvatar != null
                        ? Image.memory(
                            processedAvatar,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : tasker.profileImage != null
                            ? Stack(
                                children: [
                                  // Show loading indicator while processing
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.blue,
                                    ),
                                  ),
                                  // Default avatar image
                                  Image.asset(
                                    AppAssetsBackgrounds.avt,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ],
                              )
                            : Image.asset(
                                AppAssetsBackgrounds.avt,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),*/
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () async {
                      isRemoveTasker = await _favoriteTaskerRepo
                          .removeFavoriteTasker(tasker.id);
                      logger.log(
                          'Remove tasker: ${tasker.fullName}, success: $isRemoveTasker');

                      if (isRemoveTasker) {
                        _fTaskerBloc.add(FTaskerLoadEvent(userId: userId));
                        ShowSnackBar.showSuccess(context,
                            'Tasker removed successfully.', 'Well done!');
                      } else {
                        ShowSnackBar.showError(
                          context,
                          'Something went wrong',
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            AppColors.green,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            AppAssetIcons.heartFilledIc,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.darkBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      tasker.fullName,
                      style: AppTextStyles.bodyMediumSemiBold.copyWith(
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            AppColors.green,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            AppAssetIcons.starFilledIc,
                            width: 16,
                            height: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tasker.review != null
                              ? normalizeTo5(tasker.review!.reputationScore)
                                  .toStringAsFixed(1)
                              : '0.0',
                          style: AppTextStyles.bodyMediumRegular.copyWith(
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tasker.review != null
                              ? '(${tasker.review?.totalReviews ?? 0}) reviews'
                              : '(0 reviews)',
                          style: AppTextStyles.bodyMediumRegular.copyWith(
                            color: AppColors.darkBlue.withValues(alpha: 0.6),
                          ),
                        ),
                        const Spacer(),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  double normalizeTo5(double value, {double min = 1.9, double max = 2.0}) {
    final normalized = ((value - min) / (max - min)) * 4 + 1;
    return normalized.clamp(1.0, 5.0);
  }
}
