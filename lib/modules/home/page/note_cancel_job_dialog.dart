import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/common/widget/btn_action_dialog.dart';
import 'package:home_service_tasker/common/widget/show_snack_bar.dart';
import 'package:home_service_tasker/modules/home/bloc/task_event.dart';
import 'package:home_service_tasker/modules/home/repo/task_repo.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';

class NoteCancelJobDialog extends StatefulWidget {
  final int bookingId;

  const NoteCancelJobDialog({super.key, required this.bookingId});

  @override
  State<NoteCancelJobDialog> createState() => _NoteCancelJobDialogState();
}

class _NoteCancelJobDialogState extends State<NoteCancelJobDialog> {
  int selectReason = -1;

  int bookingId = 0;

  @override
  void initState() {
    super.initState();
    bookingId = widget.bookingId;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text(
                    'Please note to cancel a job',
                    style: AppTextStyles.headline4
                        .copyWith(color: AppColors.dodgerBlue),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                _buildText(
                    content: 'You is allowed to cancel 2 jobs within 7 days.',
                    textColor: AppColors.dark),
                const SizedBox(height: 4),
                _buildText(
                    content: 'The cancellation policy is as follow:',
                    textColor: AppColors.dark),
                const SizedBox(height: 4),
                _buildText(
                    content:
                        '1. Cancellation more than 8 hours: penalty 20,000 VND',
                    textColor: AppColors.dark),
                const SizedBox(height: 8),
                _buildText(
                    content:
                        '2. Cancellation more than 2 hours: penalty 50% of work value',
                    textColor: AppColors.dark),
                const SizedBox(height: 8),
                _buildText(
                    content:
                        '3. Cancellation less than 2 hours: penalty 100% of work value',
                    textColor: AppColors.dark),
                const SizedBox(height: 16),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    BtnActionDialog(
                        text: 'Close',
                        backgroundColor: AppColors.dodgerBlue,
                        onPressed: () {
                          Navigator.of(context).pop();
                        }),
                    BtnActionDialog(
                        text: 'Confirm',
                        backgroundColor: AppColors.sunsetOrange,
                        onPressed: () {
                          Future.delayed(Duration.zero, () {
                            _showReasonCancelDialog();
                          });
                        }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modified to open the dialog and handle the result
  void _showReasonCancelDialog() async {
    final result = await showDialog(
      context: context,
      builder: (context) => SelectReasonCancelDialog(bookingId: bookingId),
    );

    if (result == true) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildText({required String content, required Color textColor}) {
    return Text(
      content,
      style: AppTextStyles.paragraph1.copyWith(
        color: textColor,
      ),
      textDirection: TextDirection.ltr,
    );
  }
}

class SelectReasonCancelDialog extends StatefulWidget {
  final int bookingId;
  const SelectReasonCancelDialog({super.key, required this.bookingId});

  @override
  State<SelectReasonCancelDialog> createState() =>
      _SelectReasonCancelDialogState();
}

class _SelectReasonCancelDialogState extends State<SelectReasonCancelDialog> {
  int selectedReason = -1;
  int bookingId = 0;
  final List<String> cancelReasons = [
    'Accidentally took a job too far away.',
    'Check wrong day so can not work.',
    'Force majeure incident unable to go to work.',
  ];

  @override
  void initState() {
    super.initState();
    bookingId = widget.bookingId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskBloc(TaskRepo()),
      child: SizedBox(
        width: double.infinity,
        child: Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      'Please select a reason',
                      style: AppTextStyles.headline4
                          .copyWith(color: AppColors.dark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(cancelReasons.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: _buildReasonOption(
                        context: context,
                        content: cancelReasons[index],
                        index: index,
                        isSelected: selectedReason == index,
                        onTap: () {
                          setState(() {
                            selectedReason = index;
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  BlocBuilder<TaskBloc, TaskState>(
                    builder: (context, state) {
                      final bool isLoading = state is TaskLoadingState;
                      if (state is TaskErrorState) {
                        Future.delayed(Duration.zero, () {
                          if (!context.mounted) return;
                          ShowSnackBar.showError(context, state.error);
                        });
                      } else if (state is LoadingSuccessState) {
                        Future.delayed(Duration.zero, () {
                          if (!context.mounted) return;
                          Navigator.of(context).pop(true);
                          ShowSnackBar.showSuccess(
                              context, state.message, 'Well done!');
                        });
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          BtnActionDialog(
                              text: 'Close',
                              backgroundColor: AppColors.dodgerBlue,
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          BtnActionDialog(
                            text: isLoading ? 'Processing...' : 'Confirm',
                            backgroundColor: selectedReason >= 0 && !isLoading
                                ? AppColors.sunsetOrange
                                : Colors.grey,
                            onPressed: (selectedReason >= 0 && !isLoading)
                                ? () {
                                    context.read<TaskBloc>().add(
                                          CancelTaskEvent(
                                            bookingId: bookingId,
                                            reason:
                                                cancelReasons[selectedReason],
                                          ),
                                        );
                                    //Navigator.of(context).pop();
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReasonOption({
    required BuildContext context,
    required String content,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.dodgerBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.dodgerBlue : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            isSelected
                ? const Icon(Icons.check_circle,
                    color: AppColors.dodgerBlue, size: 20)
                : const Icon(Icons.circle_outlined,
                    color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                content,
                style: AppTextStyles.paragraph1.copyWith(
                  color: isSelected ? AppColors.dodgerBlue : AppColors.dark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
