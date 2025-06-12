import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/user/bloc/user_event.dart';
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
  int currentPage = 0;
  int pageSize = 10;
  int totalPages = 1;
  int totalItems = 0;
  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userRepo: UserRepo());
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
                            pageNo: currentPage,
                            pageSize: pageSize,
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
                              // Update total pages based on response data
                              if (state.metadata != null) {
                                totalItems = state.metadata!.totalItems;
                                totalPages = state.metadata!.totalPage;
                              }

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
                                                    AppAssetsIcons.clientIc,
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
                                      SizedBox(height: 16),
                                      _buildPagination(context),
                                    ],
                                  ),
                                );
                              }
                            } else if (state is UserError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 48),
                                    SizedBox(height: 16),
                                    Text(
                                      'Error: ${state.message}',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
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

  Widget _buildPagination(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Page size selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  'Show:',
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(width: 8),
                _buildPageSizeDropdown(),
              ],
            ),
          ),
          SizedBox(width: 24),
          // Previous page button
          _buildPaginationButton(
            icon: Icons.chevron_left,
            onPressed:
                currentPage > 0 ? () => _changePage(currentPage - 1) : null,
          ),
          SizedBox(width: 8),
          // Page numbers
          ..._buildPageNumbers(),
          SizedBox(width: 8),
          // Next page button
          _buildPaginationButton(
            icon: Icons.chevron_right,
            onPressed: currentPage < totalPages - 1
                ? () => _changePage(currentPage + 1)
                : null,
          ),
          SizedBox(width: 24),
          // Total items counter
          Text(
            'Total: $totalItems items',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageNumbers = [];

    // Determine which page numbers to show
    int startPage = currentPage - 2;
    int endPage = currentPage + 2;

    if (startPage < 0) {
      endPage = endPage - startPage;
      startPage = 0;
    }

    if (endPage > totalPages - 1) {
      endPage = totalPages - 1;
    }

    // Add first page button
    if (startPage > 0) {
      pageNumbers.add(_buildPageNumberButton(0));
      if (startPage > 1) {
        pageNumbers.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('...', style: AppTextStyles.bodyMedium),
        ));
      }
    }

    // Add visible page range
    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(_buildPageNumberButton(i));
    }

    // Add last page button
    if (endPage < totalPages - 1) {
      if (endPage < totalPages - 2) {
        pageNumbers.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('...', style: AppTextStyles.bodyMedium),
        ));
      }
      pageNumbers.add(_buildPageNumberButton(totalPages - 1));
    }

    return pageNumbers;
  }

  Widget _buildPageNumberButton(int pageNumber) {
    bool isActive = pageNumber == currentPage;
    return InkWell(
      onTap: () => _changePage(pageNumber),
      child: Container(
        width: 36,
        height: 36,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            (pageNumber + 1).toString(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationButton(
      {required IconData icon, VoidCallback? onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onPressed != null ? Colors.transparent : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? AppColors.text : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildPageSizeDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<int>(
        value: pageSize,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, size: 20),
        items: [5, 10, 20, 50].map((size) {
          return DropdownMenuItem<int>(
            value: size,
            child: Text(size.toString(), style: AppTextStyles.bodyMedium),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null && value != pageSize) {
            setState(() {
              pageSize = value;
              currentPage = 0; // Reset to first page when changing page size
            });
            _refreshTaskers();
          }
        },
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.text,
        ),
        dropdownColor: Colors.white,
      ),
    );
  }

  void _changePage(int newPage) {
    if (newPage != currentPage && newPage >= 0 && newPage < totalPages) {
      setState(() {
        currentPage = newPage;
      });
      _refreshTaskers();
    }
  }

  void _refreshTaskers() {
    _userBloc.add(TaskerFetchEvent(
      pageNo: currentPage,
      pageSize: pageSize,
    ));
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
