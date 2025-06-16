import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/modules/posts/blocs/post_state.dart';
import 'package:home_service/modules/posts/models/post.dart';
import 'package:home_service/modules/posts/repos/posts_repo.dart';
import 'package:home_service/modules/review/pages/rating_dialog.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/repo/user_repository.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';
import 'package:intl/intl.dart';

import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../blocs/post_bloc.dart';
import '../blocs/post_event.dart';

class BookingPost extends StatefulWidget {
  const BookingPost({super.key});

  @override
  State<BookingPost> createState() => _BookingPostState();
}

class _BookingPostState extends State<BookingPost> {
  final LogProvider logger = const LogProvider('::::BOOKING-POST::::');
  final UserRepository _userRepository = UserRepository();
  final NavigationService _navigationService = NavigationService();
  int _userId = 0;
  late PostBloc _postBloc;
  bool _isCompleted = false;
  int _currentPage = 0;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    //try get user from cache
    final currentUser = _userRepository.currentUser;
    if (currentUser != null && currentUser.name != null) {
      setState(() {
        _userId = currentUser.id!;
      });
      return;
    }

    //if user data not in cache, get from local storage
    await _userRepository.loadUserFromStorage();
    final userStorage = _userRepository.currentUser;
    if (userStorage != null && userStorage.name != null) {
      setState(() {
        _userId = userStorage.id!;
      });
      return;
    }
  }

  void _loadPosts() {
    _postBloc.add(
      PostFetchEvent(
        userId: _userId,
        status: selectedValue?.toLowerCase() == 'all'
            ? null
            : selectedValue?.toLowerCase(),
        pageNo: _currentPage,
        pageSize: _pageSize,
      ),
    );
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
                  _navigationService.goBackToPreviousTab();
                },
                child: Image.asset(AppAssetIcons.arrowLeft),
              ),
              title: 'Bookings',
            ),
            _sortByStatus(),
            const SizedBox(height: 16),
            Expanded(
              child: BlocProvider(
                create: (context) {
                  _postBloc = PostBloc(PostsRepo())
                    ..add(
                      PostFetchEvent(
                        userId: _userId,
                        status: selectedValue?.toLowerCase() == 'all'
                            ? null
                            : selectedValue?.toLowerCase(),
                        pageNo: _currentPage,
                        pageSize: _pageSize,
                      ),
                    );
                  return _postBloc;
                },
                child: BlocBuilder<PostBloc, PostState>(
                  builder: (context, state) {
                    if (state is PostLoading) {
                      return const Center(
                        child:
                            CircularProgressIndicator(color: Color(0xFF386DF3)),
                      );
                    } else if (state is PostLoaded) {
                      final posts = state.posts;
                      if (posts.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24),
                            child: Text(
                              'No bookings found for this status',
                              style: AppTextStyles.bodySmallSemiBold.copyWith(
                                color: AppColors.redMedium,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: posts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 0),
                              itemBuilder: (context, index) {
                                return _buildBookingCard(posts[index]);
                              },
                            ),
                            if (state.totalPage > 1)
                              _buildPaginationControls(
                                  state.pageNo, state.totalPage),
                          ],
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        'No bookings found',
                        style: AppTextStyles.bodySmallSemiBold.copyWith(
                          color: AppColors.redMedium,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildPaginationControls(int currentPage, int totalPages) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 0
                ? () {
                    setState(() {
                      _currentPage = currentPage - 1;
                    });
                    _loadPosts();
                  }
                : null,
            icon: Icon(
              Icons.arrow_back_ios,
              color:
                  currentPage > 0 ? AppColors.darkBlue : AppColors.darkBlue20,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: currentPage < totalPages - 1
                ? () {
                    setState(() {
                      _currentPage = currentPage + 1;
                    });
                    _loadPosts();
                  }
                : null,
            icon: Icon(
              Icons.arrow_forward_ios,
              color: currentPage < totalPages - 1
                  ? AppColors.darkBlue
                  : AppColors.darkBlue20,
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown button for sorting by status
  final List<String> items = [
    'All',
    'Pending',
    'Assigned',
    'In Progress',
    'Completed',
    'Cancelled',
    'Rescheduled',
  ];

  String? selectedValue;

  Widget _sortByStatus() {
    logger.log('Selected value: $selectedValue');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            hint: Row(
              children: [
                Expanded(
                  child: Text(
                    'All',
                    style: AppTextStyles.bodyMediumMedium.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: AppTextStyles.bodyMediumSemiBold.copyWith(
                          color: AppColors.darkBlue.withValues(alpha: 0.8),
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            value: selectedValue,
            onChanged: (value) {
              setState(() {
                selectedValue = value;
                _currentPage = 0;
                String? statusFilter;
                if (value?.toLowerCase() == 'all') {
                  statusFilter = null;
                } else if (value?.toLowerCase() == 'in progress') {
                  statusFilter = 'in_progress';
                } else {
                  statusFilter = value?.toLowerCase();
                }
                _postBloc.add(PostFetchEvent(
                  userId: _userId,
                  status: statusFilter,
                  pageNo: _currentPage,
                  pageSize: _pageSize,
                ));
                _isCompleted = value == 'Completed';
              });
            },
            buttonStyleData: ButtonStyleData(
              height: 50,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.darkBlue.withValues(alpha: 0.05),
              ),
            ),
            iconStyleData: IconStyleData(
              icon: Image.asset(AppAssetIcons.arrowDown),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.white,
              ),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all(6),
                thumbVisibility: WidgetStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(Post post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _buildBookingFirstRow(post),
            _buildBookingSecondRow(post),
            if (post.status!.compareTo('pending') == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.tanHide,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Wait for the tasker to accept your booking',
                    style: AppTextStyles.bodySmallSemiBold.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingFirstRow(Post post) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.serviceName ?? '',
                style: AppTextStyles.bodySmallBold.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppAssetIcons.dollarFiled),
                  const SizedBox(width: 4),
                  Text(
                    '${formatPrice(post.price ?? 0)} đ',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: AppColors.darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: _getStatus(post.status ?? ''),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Text(
                capitalize(post.status ?? ''),
                style: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.tanHide;
      case 'assigned':
        return AppColors.blue.withValues(alpha: 0.2);
      case 'in_progress':
        return AppColors.accent.withValues(alpha: 0.2);
      case 'completed':
        return AppColors.green.withValues(alpha: 0.2);
      case 'cancelled':
        return AppColors.redMedium.withValues(alpha: 0.2);
      case 'rescheduled':
        return AppColors.darkBlue20.withValues(alpha: 0.2);
      default:
        return AppColors.darkBlue20; // Default color for unknown status
    }
  }

  Widget _buildBookingSecondRow(Post post) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildItemRow(AppAssetIcons.calendarFilled,
                  showDateWork(post.scheduledStart)),
              const SizedBox(height: 12),
              _buildItemRow(AppAssetIcons.timer,
                  showDurationTime(post.scheduledStart, post.scheduledEnd)),
              const SizedBox(height: 8),
              _buildItemRow(AppAssetIcons.locationFilled, post.address ?? ''),
              if (_isCompleted) ...[
                const SizedBox(height: 8),
                _buildItemRow(AppAssetIcons.completedIc,
                    'Task completed at ${showCompletedAt(post.completedAt)}'),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      RatingDialog.show(
                        context,
                        bookingId: post.bookingId ?? 0,
                        reviewerId: _userId,
                        taskerId: post.taskerId ?? 0,
                        taskerName: post.taskerName ?? '',
                        taskerAvatar: post.taskerImage ?? '',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Review',
                      style: AppTextStyles.bodyLargeSemiBold,
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(String icon, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            content,
            style: AppTextStyles.bodySmallSemiBold.copyWith(
              color: AppColors.darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  String formatPrice(double price) {
    final formatter = NumberFormat('#,###');
    String formattedPrice = formatter.format(price);
    return formattedPrice;
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String showDurationTime(DateTime? startTime, DateTime? endTime) {
    try {
      final timeFormatter = DateFormat('H:mm');
      return '${timeFormatter.format(startTime!)} - ${timeFormatter.format(endTime!)}';
    } catch (e) {
      logger.log("Error parsing date: $e");
      return 'Invalid date';
    }
  }

  String showDateWork(DateTime? startTime) {
    try {
      final outputFormat = DateFormat('dd/MM/yyyy');
      return outputFormat.format(startTime!);
    } catch (e) {
      logger.log("Error parsing date: $e");
      return 'Invalid date';
    }
  }

  String showCompletedAt(DateTime? completedAt) {
    try {
      final outputFormat = DateFormat('dd/MM/yyyy H:mm');
      return outputFormat.format(completedAt!);
    } catch (e) {
      logger.log("Error parsing date: $e");
      return 'Invalid date';
    }
  }
}
