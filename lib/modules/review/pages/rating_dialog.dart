import 'package:flutter/material.dart';
import 'package:home_service/modules/favorite_tasker/repo/favorite_tasker_repo.dart';
import 'package:home_service/modules/review/repo/review_repo.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';

import '../model/review_req.dart';

class RatingDialog extends StatefulWidget {
  final String taskerName;
  final String taskerAvatar;
  final int taskerId;
  final int bookingId;
  final int reviewerId;
  const RatingDialog({
    super.key,
    required this.taskerName,
    this.taskerAvatar = '',
    required this.taskerId,
    required this.bookingId,
    required this.reviewerId,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();

  static Future<void> show(
    BuildContext context, {
    required String taskerName,
    String taskerAvatar = '',
    required int taskerId,
    required int bookingId,
    required int reviewerId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => RatingDialog(
        taskerName: taskerName,
        taskerAvatar: taskerAvatar,
        taskerId: taskerId,
        bookingId: bookingId,
        reviewerId: reviewerId,
      ),
    );
  }
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  int _selectedRating = 0;
  bool _showFeedbackOptions = false;
  bool _isOtherSelected = false;
  final List<String> _selectedFeedbacks = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final TextEditingController _feedbackController = TextEditingController();
  final ReviewRepo _reviewRepo = ReviewRepo();
  final FavoriteTaskerRepo _favoriteTaskerRepo = FavoriteTaskerRepo();
  bool _isInFavorites = false;
  bool _isCheckingFavorite = false;
  final List<String> _feedbackOptions = [
    'Không đúng giờ',
    'Thái độ không tốt',
    'Không cẩn thận',
    'Không sạch sẽ',
    'Siêng năng, cẩn thận',
    'Thân thiện, vui vẻ',
    'Tay nghề tốt, chuyên nghiệp',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    // Check if tasker is already in favorites when dialog opens
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      setState(() {
        _isCheckingFavorite = true;
      });

      final isInFavorites = await _favoriteTaskerRepo.isTaskerInFavorites(
          widget.reviewerId, widget.taskerId);

      setState(() {
        _isInFavorites = isInFavorites;
        _isCheckingFavorite = false;
      });
    } catch (e) {
      setState(() {
        _isCheckingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavoriteStatus() async {
    try {
      final result = await _favoriteTaskerRepo.toggleFavoriteTasker(
          widget.reviewerId, widget.taskerId, widget.bookingId);

      setState(() {
        _isInFavorites = result;
      });

      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _isInFavorites ? AppColors.green : AppColors.red,
          content: Text(
              _isInFavorites ? 'Added to favorites' : 'Removed from favorites'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorites'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _onRatingSelected(int rating) {
    setState(() {
      _selectedRating = rating;
      _showFeedbackOptions = true;
      _selectedFeedbacks.clear();
    });

    if (_showFeedbackOptions) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _toggleFeedback(String feedback) {
    setState(() {
      if (_selectedFeedbacks.contains(feedback)) {
        _selectedFeedbacks.remove(feedback);
      } else {
        _selectedFeedbacks.add(feedback);
      }
    });
  }

  Future<void> _submitRating() async {
    await _reviewRepo.createReview(
      ReviewReq(
        bookingId: widget.bookingId,
        reviewerId: widget.reviewerId,
        rating: _selectedRating,
        comment: _isOtherSelected
            ? _feedbackController.text.trim().isNotEmpty
                ? _feedbackController.text.trim()
                : null
            : _selectedFeedbacks.isNotEmpty
                ? _selectedFeedbacks.join(', ')
                : null,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Spacer(),
                    _isCheckingFavorite
                        ? SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.blue,
                            ),
                          )
                        : GestureDetector(
                            onTap: _toggleFavoriteStatus,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  _isInFavorites
                                      ? AppColors.green
                                      : AppColors.darkBlue,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  _isInFavorites
                                      ? AppAssetIcons.heartFilledIc
                                      : AppAssetIcons.heart,
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),

              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.darkBlue20,
                  shape: BoxShape.circle,
                ),
                child: widget.taskerAvatar.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          widget.taskerAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(),
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),

              SizedBox(height: 12),

              // Title
              Text('Rating',
                  style: AppTextStyles.bodyLargeSemiBold.copyWith(
                    color: AppColors.blue,
                  )),

              SizedBox(height: 8),

              // Tasker name
              if (widget.taskerName.isNotEmpty) ...[
                Text(widget.taskerName.toUpperCase(),
                    style: AppTextStyles.h6SemiBold.copyWith(
                      color: AppColors.black,
                    )),
                SizedBox(height: 16),
              ] else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                      'Tasker was completed successfully. Please rate the tasker.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMediumRegular.copyWith(
                        color: AppColors.darkBlue,
                      )),
                ),
                SizedBox(height: 20),
              ],

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => _onRatingSelected(index + 1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          index < _selectedRating
                              ? AppColors.blue
                              : AppColors.darkBlue20,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          AppAssetIcons.starIc,
                          width: 32,
                          height: 32,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // Feedback Section (Animated)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _showFeedbackOptions ? null : 0,
                child: _showFeedbackOptions
                    ? SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Text(
                                    'What is the reason making you dissatisfied?',
                                    style:
                                        AppTextStyles.bodyMediumMedium.copyWith(
                                      color: AppColors.black,
                                    )),
                                SizedBox(height: 16),

                                // Feedback Options
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: !_isOtherSelected
                                      ? _feedbackOptions.map((feedback) {
                                          final isSelected = _selectedFeedbacks
                                              .contains(feedback);
                                          return GestureDetector(
                                            onTap: () =>
                                                _toggleFeedback(feedback),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.orange
                                                        .withValues(alpha: 0.1)
                                                    : Colors.grey[100],
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.orange
                                                      : Colors.grey[300]!,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                feedback,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isSelected
                                                      ? Colors.orange
                                                      : Colors.black87,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w500
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList()
                                      : [],
                                ),
                                SizedBox(height: 10),
                                // Other button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isOtherSelected = !_isOtherSelected;
                                      if (_isOtherSelected) {
                                        _selectedFeedbacks.clear();
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isOtherSelected
                                          ? Colors.orange.withValues(alpha: 0.1)
                                          : Colors.grey[100],
                                      border: Border.all(
                                          color: _isOtherSelected
                                              ? Colors.orange
                                              : Colors.grey[300]!),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Other',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _isOtherSelected
                                            ? Colors.orange
                                            : AppColors.black,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 16),
                                // review text
                                if (_isOtherSelected)
                                  SizedBox(
                                    height: 60,
                                    child: TextField(
                                      controller: _feedbackController,
                                      maxLines: 3,
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                        hintText: 'Please enter your review',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide:
                                              BorderSide(color: AppColors.blue),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        // Handle text input
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ),

              // Submit Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedRating > 0 ? _submitRating : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRating > 0
                          ? AppColors.blue
                          : AppColors.loginWith,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlue20,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 40,
        color: AppColors.loginWith,
      ),
    );
  }
}
