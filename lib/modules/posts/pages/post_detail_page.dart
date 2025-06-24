import 'package:flutter/material.dart';
import 'package:home_service/common/widgets/stateless/basic_app_bar.dart';
import 'package:home_service/modules/posts/models/post.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/services/navigation_service.dart';
import 'package:home_service/themes/app_assets.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:home_service/themes/styles_text.dart';
import 'package:intl/intl.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final LogProvider logger = const LogProvider('::::POST-DETAIL::::');
  final NavigationService _navigationService = NavigationService();

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
                onTap: () => _navigationService.goBack(),
                child: Image.asset(AppAssetIcons.arrowLeft),
              ),
              title: 'Task Details',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskStatusSection(),
                    const SizedBox(height: 24),
                    _buildTaskInfoSection(),
                    const SizedBox(height: 24),
                    _buildTaskerInfoSection(),
                    const SizedBox(height: 24),
                    _buildActionsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskStatusSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.post.serviceName ?? 'Service',
                style: AppTextStyles.bodyLargeSemiBold.copyWith(
                  color: AppColors.darkBlue,
                  fontSize: 20,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatStatus(widget.post.status ?? ''),
                  style: AppTextStyles.captionMedium.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Image.asset(AppAssetIcons.dollarFiled, height: 20),
              const SizedBox(width: 8),
              Text(
                '${_formatCurrency(widget.post.price ?? 0)} đ',
                style: AppTextStyles.bodyMediumSemiBold.copyWith(
                  color: AppColors.blue,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Booking ID: #${widget.post.bookingId}',
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.darkBlue.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Task Information',
            style: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.darkBlue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            AppAssetIcons.calendarFilled,
            'Date',
            _formatDate(widget.post.scheduledStart),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppAssetIcons.timer,
            'Time',
            _formatTimeRange(
                widget.post.scheduledStart, widget.post.scheduledEnd),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppAssetIcons.timer,
            'Duration',
            '${widget.post.duration ?? 0} minutes',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppAssetIcons.locationFilled,
            'Location',
            widget.post.address ?? 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            AppAssetIcons.paymentCash,
            'Payment Status',
            _formatPaymentStatus(widget.post.paymentStatus ?? 'unpaid'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskerInfoSection() {
    if (widget.post.taskerId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tasker Information',
            style: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.darkBlue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: widget.post.taskerImage != null &&
                            widget.post.taskerImage!.isNotEmpty
                        ? NetworkImage(widget.post.taskerImage!)
                        : const AssetImage(AppAssetIcons.profileFilled)
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.taskerName ?? 'Unknown',
                      style: AppTextStyles.bodyMediumSemiBold.copyWith(
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Professional Tasker',
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.darkBlue.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(
                icon: Icons.phone,
                label: 'Call',
                onTap: () {
                  // Implement call functionality
                },
                color: AppColors.blue,
              ),
              _buildContactButton(
                icon: Icons.message,
                label: 'Message',
                onTap: () {
                  _navigationService.changeTab(3);
                },
                color: AppColors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodySmallSemiBold.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: AppTextStyles.bodyMediumSemiBold.copyWith(
              color: AppColors.darkBlue,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.post.status?.toLowerCase() == 'assigned'
                      ? () {
                          // Implement reschedule functionality
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: AppColors.darkBlue20,
                  ),
                  child: Text(
                    'Reschedule',
                    style: AppTextStyles.bodyMediumSemiBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.post.status?.toLowerCase() == 'assigned'
                      ? () {
                          // Implement cancel functionality
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redMedium,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: AppColors.darkBlue20,
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.bodyMediumSemiBold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String iconPath, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPath, height: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.captionMedium.copyWith(
                  color: AppColors.darkBlue.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodySmallSemiBold.copyWith(
                  color: AppColors.darkBlue,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatStatus(String status) {
    if (status.toLowerCase() == 'in_progress') {
      return 'In Progress';
    }
    return status.isEmpty
        ? 'Unknown'
        : status[0].toUpperCase() + status.substring(1);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not specified';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTimeRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Not specified';
    return '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
  }

  String _formatPaymentStatus(String status) {
    return status.isEmpty
        ? 'Unknown'
        : status[0].toUpperCase() + status.substring(1);
  }
}
