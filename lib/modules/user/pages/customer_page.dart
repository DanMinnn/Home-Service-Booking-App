import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/user/bloc/user_bloc.dart';
import 'package:home_service_admin/modules/user/bloc/user_event.dart';
import 'package:home_service_admin/modules/user/bloc/user_state.dart';
import 'package:home_service_admin/modules/user/repo/user_repo.dart';
import 'package:home_service_admin/themes/app_assets.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:home_service_admin/themes/style_text.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  CustomerPageState createState() => CustomerPageState();
}

class CustomerPageState extends State<CustomerPage> {
  bool showAddCustomerForm = false;

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
                            'Customer List',
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
                            label: Text('Add Customer'),
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
                      // Table Header
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
                              flex: 1,
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
                                flex: 1,
                                child: Text(
                                  'Phone number',
                                  style: AppTextStyles.bodyMedium,
                                )),
                            Expanded(
                                flex: 1,
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
                            SizedBox(width: 40),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Customer List
                      BlocProvider(
                        create: (context) => UserBloc(userRepo: UserRepo())
                          ..add(CustomerFetchEvent()),
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
                              final customers = state.users;
                              if (customers.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No customer yet!',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                );
                              } else {
                                return Expanded(
                                  flex: 1,
                                  child: ListView.builder(
                                    itemBuilder: (_, index) {
                                      final customer = customers[index];
                                      return _buildCustomerRow(
                                          customer.id,
                                          customer.firstLastName,
                                          customer.email,
                                          customer.phoneNumber,
                                          customer.profileImage!,
                                          formatCreatedAt(customer.createdAt ??
                                              DateTime.now()),
                                          customer.isActive!);
                                    },
                                    itemCount: customers.length,
                                    shrinkWrap: true,
                                    physics: AlwaysScrollableScrollPhysics(),
                                  ),
                                );
                              }
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
                                    'Add Customer',
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
                                      child: Text('Add Customer',
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

  Widget _buildCustomerRow(int id, String name, String email, String phone,
      String avatar, String createdAt, bool isActive) {
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
            flex: 1,
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
          Expanded(
            flex: 1,
            child: Text(
              phone,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
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
