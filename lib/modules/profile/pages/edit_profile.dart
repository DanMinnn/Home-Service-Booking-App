import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service/common/widgets/stateless/show_snack_bar.dart';
import 'package:home_service/modules/authentication/widgets/custom_text_field.dart';
import 'package:home_service/modules/profile/bloc/profile_event.dart';
import 'package:home_service/modules/profile/models/update_user.dart';
import 'package:home_service/modules/profile/repo/user_repo.dart';
import 'package:home_service/providers/log_provider.dart';
import 'package:home_service/repo/user_repository.dart';
import 'package:home_service/themes/app_colors.dart';
import 'package:image_picker/image_picker.dart';

import '../../../blocs/app_state_bloc.dart';
import '../../../common/widgets/stateless/basic_app_bar.dart';
import '../../../services/navigation_service.dart';
import '../../../themes/app_assets.dart';
import '../../../themes/styles_text.dart';
import '../../authentication/pages/auth_screen.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final NavigationService _navigationService = NavigationService();
  final UserRepository _userRepository = UserRepository();

  LogProvider get logger => LogProvider(":::EDIT-PROFILE:::");
  bool _isEmpty = false;
  int _userId = 0;
  String _userName = '';
  String _userEmail = '';
  bool _isUpdating = false;
  File _imageUrl = File('');
  String _userImage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _userId = args['id'];
      _userEmail = args['email'];
      _userName = args['name'];
      _userImage = args['image'];
      _name.text = _userName;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocProvider(
        create: (context) => ProfileBloc(UserRepo()),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileStateSuccess) {
              setState(() {
                _userName = _name.text;
                _isUpdating = false;
              });

              // Update the user data in the repository
              _userRepository.loadUserByEmail(_userEmail);
              ShowSnackBar.showSuccess(
                  context, 'Updated successfully', 'Well done!');
            } else if (state is ProfileStateLoading) {
              _isUpdating = true;
            } else if (state is ProfileStateError) {
              _isUpdating = false;
              ShowSnackBar.showError(context, 'Updated failed');
            } else if (state is ProfileStateDeleteAccountSuccess) {
              _isUpdating = false;

              context.read<AppStateBloc>().logout();
              Future.delayed(const Duration(milliseconds: 300), () {
                // _navigationService
                //     .navigateToAndClearStack(RouteName.authScreen);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                  (route) => false,
                );
              });
            } else if (state is ProfileStateDeleteAccountError) {
              // Handle delete account error
              _isUpdating = false;
              ShowSnackBar.showError(context, 'Failed to delete account');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BasicAppBar(
                      isLeading: false,
                      isTrailing: false,
                      leading: GestureDetector(
                        onTap: () {
                          _navigationService.goBack(true);
                        },
                        child: Image.asset(AppAssetIcons.arrowLeft),
                      ),
                      title: 'Profile',
                    ),
                    const SizedBox(height: 20),
                    _buildProfileImage(),
                    const SizedBox(height: 10),
                    _buildProfileInfo(),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 24),
                    _buildEditName(),
                    const SizedBox(height: 16),
                    _buildAddress(),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: _buttonSave(
                          context: context,
                          enable: !_isEmpty && !_isUpdating,
                          backgroundColor: AppColors.blue),
                    ),
                    const SizedBox(height: 40),
                    _buildDeleteAccount(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.darkBlue.withValues(alpha: 0.05),
          child: ClipOval(
            child: _imageUrl.path.isNotEmpty
                ? Image.file(
                    _imageUrl,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to default image on error
                      return Image.asset(
                        AppAssetIcons.profile,
                        fit: BoxFit.fill,
                        width: 100,
                        height: 100,
                      );
                    },
                  )
                : Image.network(
                    _userImage,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to default image on error
                      return Image.asset(
                        AppAssetIcons.profile,
                        fit: BoxFit.fill,
                        width: 100,
                        height: 100,
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 34,
              width: 34,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  AppAssetIcons.galleryEdit,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      children: [
        Text(
          _userName,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _userEmail,
          style: AppTextStyles.bodyLargeMedium.copyWith(
            color: AppColors.darkBlue.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppColors.darkBlue20,
      height: 1,
      thickness: 1,
    );
  }

  Widget _buildEditName() {
    return CustomTextField(
      controller: _name,
      label: 'First and Last Name',
      hintText: 'John Doe',
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {
          _isEmpty = value.isEmpty;
        });
      },
      onUnfocused: () {},
      fillColor: true,
      errorMessages: const [],
      prefixIcon: null,
    );
  }

  Widget _buildAddress() {
    return CustomTextField(
      controller: _address,
      label: 'Address',
      hintText: '123 Main St, City, Country',
      keyboardType: TextInputType.text,
      onChanged: (value) {
        setState(() {
          _isEmpty = value.isEmpty;
        });
      },
      onUnfocused: () {},
      fillColor: true,
      errorMessages: const [],
      prefixIcon: null,
    );
  }

  Widget _buttonSave(
      {required BuildContext context,
      required bool enable,
      required Color backgroundColor}) {
    return ElevatedButton(
      onPressed: enable
          ? () {
              final req = UpdateUser(
                name: _name.text.trim(),
                address: _address.text.trim(),
              );

              context
                  .read<ProfileBloc>()
                  .add(ProfileEventUpdate(_userId, req, _imageUrl));
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: _isUpdating
          ? const CircularProgressIndicator(color: AppColors.white)
          : Text(
              'Save Changes',
              style: AppTextStyles.bodyLargeMedium
                  .copyWith(color: AppColors.white),
            ),
    );
  }

  Widget _buildDeleteAccount(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          _showDeleteConfirmation(context);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(AppAssetIcons.trash),
            const SizedBox(width: 8),
            Text(
              'Delete Account',
              style: AppTextStyles.bodyMediumSemiBold.copyWith(
                color: AppColors.darkBlue.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _imageUrl = file;
      });
      logger.log('Picked image: ${file.path}');
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final profileBloc = context.read<ProfileBloc>();
    AwesomeDialog(
      context: context,
      dialogBackgroundColor: AppColors.white,
      customHeader: Image.asset(
        AppAssetIcons.trash,
        fit: BoxFit.cover,
      ),
      title: 'Delete Account',
      titleTextStyle: AppTextStyles.h5Bold.copyWith(
        color: AppColors.darkBlue,
      ),
      desc:
          'Are you sure you want to delete your account? This action cannot be undone.',
      descTextStyle: AppTextStyles.bodyLargeRegular.copyWith(
        color: AppColors.darkBlue.withValues(alpha: 0.8),
      ),
      btnOk: Container(
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
            _deleteAccount(profileBloc);
          },
          child: Text(
            'Delete',
            style: AppTextStyles.bodyLargeSemiBold.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ),
      btnCancel: Container(
        decoration: BoxDecoration(
          color: AppColors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancel',
            style: AppTextStyles.bodyLargeSemiBold.copyWith(
              color: AppColors.darkBlue,
            ),
          ),
        ),
      ),
    ).show();
  }

  void _deleteAccount(ProfileBloc profileBloc) {
    setState(() {
      _isUpdating = true;
    });
    profileBloc.add(ProfileEventDeleteAccount(_userId));
  }
}
