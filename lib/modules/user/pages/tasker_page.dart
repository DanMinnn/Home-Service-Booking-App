import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/user/bloc/user_event.dart';
import 'package:home_service_admin/providers/log_provider.dart';
import 'package:home_service_admin/themes/app_assets.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:home_service_admin/themes/style_text.dart';

import '../bloc/user_bloc.dart';
import '../bloc/user_state.dart';
import '../repo/user_repo.dart';

class TaskerPage extends StatefulWidget {
  const TaskerPage({super.key});

  @override
  TaskerPageState createState() => TaskerPageState();
}

class TaskerPageState extends State<TaskerPage> {
  bool showAddCustomerForm = false;
  late UserBloc _userBloc;
  final LogProvider logger = LogProvider("::::TASKER-PAGE::::");
  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userRepo: UserRepo());
    _userBloc.add(TaskerFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F4FA),
      body: Row(
        children: [
          // Main Content
          Expanded(
            child: Stack(
              children: [
                // Customer List
                Container(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tasker List',
                            style: AppTextStyles.headlineMedium,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                showAddCustomerForm = true;
                              });
                            },
                            icon:
                                Icon(Icons.add, size: 16, color: Colors.white),
                            label: Text('Add Tasker'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'ID',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Name',
                                style: AppTextStyles.bodyMedium,
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Text(
                                  'Email',
                                  style: AppTextStyles.bodyMedium,
                                )),
                            Expanded(
                                flex: 2,
                                child: Text(
                                  'Phone number',
                                  style: AppTextStyles.bodyMedium,
                                )),
                            Expanded(
                                flex: 2,
                                child: Text(
                                  'Created At',
                                  style: AppTextStyles.bodyMedium,
                                )),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  'Is Active',
                                  style: AppTextStyles.bodyMedium,
                                )),
                            const SizedBox(width: 16),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  'Status',
                                  style: AppTextStyles.bodyMedium,
                                )),
                            SizedBox(width: 40),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Customer List
                      BlocProvider.value(
                        value: _userBloc
                          ..add(TaskerFetchEvent(
                            pageNo: 0,
                            pageSize: 10,
                          )),
                        child: BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
                            if (state is UserLoading) {
                              return Padding(
                                padding: const EdgeInsets.all(100.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            } else if (state is UserLoaded) {
                              final taskers = state.users;

                              if (taskers.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No tasker yet!',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                );
                              } else {
                                return Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          itemBuilder: (_, index) {
                                            final tasker = taskers[index];
                                            return _buildTaskerRow(
                                                tasker.id,
                                                tasker.firstLastName,
                                                tasker.email,
                                                tasker.phoneNumber,
                                                tasker.status!,
                                                tasker.profileImage ??
                                                    'https://sm.ign.com/ign_nordic/cover/a/avatar-gen/avatar-generations_prsz.jpg',
                                                formatCreatedAt(
                                                    tasker.createdAt ??
                                                        DateTime.now()),
                                                tasker.isActive!);
                                          },
                                          itemCount: taskers.length,
                                          shrinkWrap: true,
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                        ),
                                      ),
                                      _buildPaginationControls(state),
                                    ],
                                  ),
                                );
                              }
                            } else if (state is UserError) {
                              return Center(
                                child: Text(
                                  'Something went wrong. Check your internet connection.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            }

                            return Center(
                              child: Text(
                                'Something went wrong',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Add Customer Form Overlay
                if (showAddCustomerForm)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Container(
                        width: 400,
                        height: 600,
                        margin: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Add Tasker',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        showAddCustomerForm = false;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Form Content
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    // Avatar Upload
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.blue.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.camera_alt,
                                          color: Colors.blue, size: 24),
                                    ),
                                    SizedBox(height: 32),
                                    // Form Fields
                                    _buildFormField('Headline', 'Title'),
                                    SizedBox(height: 16),
                                    _buildFormField('Headline', 'Title'),
                                    SizedBox(height: 16),
                                    _buildFormField('Headline', 'Title',
                                        isDropdown: true),
                                    Spacer(),
                                    // Submit Button
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          showAddCustomerForm = false;
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: Text('Add Tasker',
                                          style: TextStyle(fontSize: 16)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildPaginationControls(UserState state) {
    // If we don't have data yet or metadata is null, don't show pagination
    if (state is! UserLoaded) {
      logger.log("User state is not loaded, skipping pagination controls.");
      return const SizedBox.shrink();
    }

    final metadata = state.metadata!;

    // If there's only one page, don't show pagination
    if (metadata.totalPage <= 1) {
      logger.log(
          "User state is not loaded, skipping pagination controls. Only one page available.");
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: metadata.pageNo > 0
                ? () {
                    _userBloc.add(ChangePage(metadata.pageNo - 1));
                  }
                : null,
            color: metadata.pageNo > 0 ? AppColors.primary : Colors.grey,
          ),

          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Page ${metadata.pageNo + 1} of ${metadata.totalPage}',
              style: AppTextStyles.bodyMedium,
            ),
          ),

          // Next page button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: metadata.pageNo < metadata.totalPage - 1
                ? () {
                    _userBloc.add(ChangePage(metadata.pageNo + 1));
                  }
                : null,
            color: metadata.pageNo < metadata.totalPage - 1
                ? AppColors.primary
                : Colors.grey,
          ),

          // Items per page dropdown
          const SizedBox(width: 16),
          Text('Items per page:', style: AppTextStyles.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: metadata.pageSize,
            items: [10, 20, 50, 100].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value', style: AppTextStyles.bodyMedium),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && value != metadata.pageSize) {
                _userBloc.add(ChangeItemsPerPage(value));
              }
            },
            style: AppTextStyles.bodyMedium,
            underline: Container(
              height: 1,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskerRow(int id, String name, String email, String phone,
      String status, String avatar, String createdAt, bool isActive) {
    return Container(
      width: MediaQuery.of(context).size.width - 300,
      margin: EdgeInsets.only(bottom: 25),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              id.toString(),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(avatar),
                ),
                SizedBox(width: 12),
                Text(name, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Image.asset(AppAssetsIcons.emailIc),
                SizedBox(width: 8),
                Text(
                  email,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              phone,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              createdAt,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isActive.toString() == 'true'
                    ? AppColors.accent
                    : AppColors.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                isActive.toString().toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: status == 'available'
                    ? AppColors.accent
                    : AppColors.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                status.toUpperCase(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutral,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(
              width: 40, child: Icon(Icons.more_horiz, color: AppColors.text)),
        ],
      ),
    );
  }

  String formatCreatedAt(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildFormField(String label, String hint, {bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              if (isDropdown)
                Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
