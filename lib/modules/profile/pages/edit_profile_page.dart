import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_tasker/modules/profile/model/update_tasker.dart';
import 'package:home_service_tasker/modules/profile/repo/tasker_repo.dart';
import 'package:home_service_tasker/providers/log_provider.dart';
import 'package:home_service_tasker/repo/tasker_repository.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/widget/app_bar.dart';
import '../../../common/widget/custom_text_field.dart';
import '../../../common/widget/show_snack_bar.dart';
import '../../../theme/app_assets.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';
import '../../../widgets/notification_badge.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final LogProvider logger = LogProvider("::::EDIT-PROFILE-PAGE::::");
  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TaskerRepository _taskerRepository = TaskerRepository();

  bool _formValid = true;
  int _taskerId = 0;
  String _taskerEmail = '';
  bool _isUpdating = false;
  File? _imageFile;
  String _taskerImage = '';
  String _initialName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _taskerId = args['id'];
      _taskerEmail = args['email'];
      _taskerImage = args['image'];

      if (args['name'] != null) {
        _initialName = args['name'];
        _fullName.text = _initialName;
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (_fullName.text.isEmpty || _address.text.isEmpty) {
        final tasker = await _taskerRepository.loadTaskerByEmail(_taskerEmail);
        if (tasker != null) {
          setState(() {
            _initialName = tasker.name ?? '';
            _fullName.text = _initialName;
          });
        }
      }
    } catch (e) {
      logger.log("Error loading user data: $e");
    }
  }

  @override
  void dispose() {
    _fullName.dispose();
    _address.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _formValid =
          _fullName.text.trim().isNotEmpty || _address.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark,
      body: Column(
        children: [
          BasicAppBar(
            title: 'Edit Profile',
            backgroundColor: true,
            leading: ColorFiltered(
              colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset(AppAssetsIcons.arrowLeft),
              ),
            ),
            trailing: NotificationBadge(),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: BlocProvider(
                create: (context) => ProfileBloc(TaskerRepo()),
                child: BlocConsumer<ProfileBloc, ProfileState>(
                  listener: (context, state) {
                    if (state is ProfileStateSuccess) {
                      setState(() {
                        _isUpdating = false;
                      });

                      _taskerRepository.loadTaskerByEmail(_taskerEmail);
                      ShowSnackBar.showSuccess(context,
                          'Profile updated successfully', 'Well done!');
                    } else if (state is ProfileStateLoading) {
                      setState(() {
                        _isUpdating = true;
                      });
                    } else if (state is ProfileStateError) {
                      setState(() {
                        _isUpdating = false;
                      });
                      ShowSnackBar.showError(
                          context, 'Update failed: ${state.error}');
                    }
                  },
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  _buildUpdateAvatar(),
                                  const SizedBox(height: 24),
                                  _buildFullNameField(),
                                  const SizedBox(height: 24),
                                  _buildAddressField(),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                          _buildBtnSave(
                            context: context,
                            enable: _formValid && !_isUpdating,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildUpdateAvatar() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _taskerImage.isNotEmpty
                      ? Image.network(
                          _taskerImage,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        (loadingProgress.expectedTotalBytes ??
                                            1)
                                    : null,
                                color: AppColors.primary,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultAvatar();
                          },
                        )
                      : _buildDefaultAvatar(),
            ),
            Positioned(
              child: GestureDetector(
                onTap: _pickImage,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Image.asset(AppAssetsIcons.cameraIc),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.dark,
      child: Center(
          child: Icon(
        Icons.person,
        color: AppColors.dark,
        size: 50,
      )),
    );
  }

  Widget _buildFullNameField() {
    return CustomInputField(
      controller: _fullName,
      label: 'Full Name',
      onChanged: (value) {
        _validateForm();
      },
      isPassword: false,
      errorMessages: [],
    );
  }

  Widget _buildAddressField() {
    return CustomInputField(
      controller: _address,
      label: 'Address',
      onChanged: (value) {
        _validateForm();
      },
      isPassword: false,
      errorMessages: [],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      logger.log('Picked image: ${pickedFile.path}');
    }
  }

  Widget _buildBtnSave({
    required BuildContext context,
    required bool enable,
  }) {
    return ElevatedButton(
      onPressed: enable
          ? () {
              final req = UpdateTasker(
                name: _fullName.text.trim(),
                address: _address.text.trim(),
              );

              context
                  .read<ProfileBloc>()
                  .add(ProfileEventUpdate(_taskerId, req, _imageFile!));
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enable ? AppColors.primary : AppColors.grey,
        foregroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: _isUpdating
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2,
              ),
            )
          : Text('Save Changes', style: AppTextStyles.headline6),
    );
  }
}
