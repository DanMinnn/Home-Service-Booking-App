import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/common/widgets/custom_text_field.dart';
import 'package:home_service_admin/common/widgets/snackbar_success.dart';
import 'package:home_service_admin/modules/services/models/req/package_req.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:home_service_admin/themes/style_text.dart';

import '../../../providers/log_provider.dart';
import '../bloc/services_bloc.dart';
import '../bloc/services_event.dart';
import '../bloc/services_state.dart';
import '../models/req/category_req.dart';
import '../models/req/service_req.dart';
import '../models/req/variant_req.dart';
import '../models/services.dart';
import '../repo/services_repo.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  ServicesPageState createState() => ServicesPageState();
}

class ServicesPageState extends State<ServicesPage> {
  late ServicesBloc _servicesBloc;
  final LogProvider logger = LogProvider("::::SERVICES-PAGE::::");
  ServiceDetail? selectedService;
  final ServicesRepo servicesRepo = ServicesRepo();
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _servicesBloc = ServicesBloc(servicesRepo: ServicesRepo());
    _servicesBloc.add(FetchServiceCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: BlocProvider(
        create: (_) => _servicesBloc,
        child: BlocBuilder<ServicesBloc, ServicesState>(
          builder: (context, state) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Service Categories and Services
                Expanded(
                  flex: 3,
                  child: _buildServicesList(state),
                ),

                // Right side: Service details
                Expanded(
                  flex: 4,
                  child: _buildServiceDetails(),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return BlocProvider.value(
      value: _servicesBloc,
      child: BlocBuilder<ServicesBloc, ServicesState>(
        builder: (context, state) {
          if (state is ServiceDetailLoaded) {
            final service = state.serviceDetail;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit mode toggle button
                FloatingActionButton(
                  heroTag: 'editToggle',
                  backgroundColor:
                      isEditMode ? Colors.orange : AppColors.primary,
                  onPressed: () {
                    setState(() {
                      isEditMode = !isEditMode;
                    });
                  },
                  child: Icon(
                    isEditMode ? Icons.edit_off : Icons.edit,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // Add package button
                FloatingActionButton(
                  heroTag: 'addPackage',
                  backgroundColor: AppColors.accent,
                  onPressed: () {
                    _showAddPackageDialog(context, service.id);
                  },
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ],
            );
          }

          // Add new service button when no service is selected
          if (state is ServiceCategoriesLoaded) {
            final categories = state.categories;
            return FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: () {
                _showAddServiceDialog(context, categories);
              },
              child: const Icon(Icons.add_circle_outline, color: Colors.white),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildServicesList(ServicesState state) {
    if (state is ServicesLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3A36DB),
        ),
      );
    }

    List<ServiceCategory> categories = [];
    int pageNo = 0;
    int pageSize = 10;
    int totalPage = 0;

    if (state is ServiceCategoriesLoaded) {
      categories = state.categories;
      pageNo = state.pageNo;
      pageSize = state.pageSize;
      totalPage = state.totalPage;

      logger.log('Loaded ${categories.length} service categories');
    } else if (state is ServiceDetailLoaded) {
      categories = state.categories;
      pageNo = state.pageNo;
      pageSize = state.pageSize;
      totalPage = state.totalPage;

      logger.log(
          'Loaded ${categories.length} service categories from ServiceDetailLoaded state');
    }

    if (categories.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Service Categories',
                style: AppTextStyles.headlineSmall,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryItem(category);
                },
              ),
            ),
            // Use a common method to build pagination that works with both states
            _buildPaginationControls(pageNo, pageSize, totalPage),
          ],
        ),
      );
    }

    if (state is ServicesLoadFailure) {
      return Center(
        child: Text(
          'Something went wrong. Check your internet connection or try again later.',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
        ),
      );
    }

    return Center(
      child: Text(
        'No service categories available',
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildCategoryItem(ServiceCategory category) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(
            Icons.category,
            color: category.active ? AppColors.primary : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            category.name,
            style: AppTextStyles.titleMedium.copyWith(
              color: category.active ? AppColors.text : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          if (!category.active)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Inactive',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.edit_note_outlined,
              color: AppColors.secondary,
              size: 20,
            ),
            onPressed: () {
              _showEditCategoryDialog(context, category);
            },
            tooltip: 'Edit Category',
          ),
          IconButton(
            icon: Icon(
              category.active ? Icons.toggle_on : Icons.toggle_off,
              color: category.active ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            onPressed: () {
              _showToggleCategoryStatusDialog(context, category);
            },
            tooltip: category.active ? 'Deactivate' : 'Activate',
          ),
        ],
      ),
      children: category.services.map((service) {
        return ListTile(
          leading: service.icon != null
              ? Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_repair_service,
                    color: AppColors.primary,
                    size: 16,
                  ),
                )
              : null,
          title: Text(
            service.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: service.isActive ? AppColors.text : Colors.grey,
            ),
          ),
          subtitle: service.description != null &&
                  service.description!.isNotEmpty
              ? Text(
                  service.description!,
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: AppColors.secondary,
                  size: 18,
                ),
                onPressed: () {
                  _showEditServiceDialog(context, service);
                },
                tooltip: 'Edit Service',
              ),
              Transform.scale(
                scale: 0.6,
                child: Switch(
                  value: service.isActive,
                  activeColor: AppColors.accent,
                  onChanged: (value) {
                    _showToggleServiceStatusDialog(context, service);
                  },
                ),
              ),
            ],
          ),
          onTap: () {
            _servicesBloc.add(FetchServiceDetail(service.id));
          },
        );
      }).toList(),
    );
  }

  Widget _buildServiceDetails() {
    return BlocBuilder<ServicesBloc, ServicesState>(
      buildWhen: (previous, current) =>
          current is ServiceDetailLoaded || current is ServicesLoading,
      builder: (context, state) {
        if (state is ServiceDetailLoaded) {
          selectedService = state.serviceDetail;
          return _buildServiceDetailContent(state.serviceDetail);
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_repair_service_outlined,
                size: 64,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Select a service to view details',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceDetailContent(ServiceDetail service) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isEditMode
                    ? _buildEditableServiceName(service)
                    : Text(
                        service.name,
                        style: AppTextStyles.headlineSmall,
                      ),
                Row(
                  children: [
                    Text(
                      'Status: ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: isEditMode
                          ? () {
                              _showToggleDetailedServiceStatusDialog(
                                  context, service);
                            }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              service.active ? AppColors.accent : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                          border: isEditMode
                              ? Border.all(color: Colors.blueAccent, width: 2)
                              : null,
                        ),
                        child: Text(
                          service.active ? 'Active' : 'Inactive',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    if (isEditMode)
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _showDeleteServiceDialog(context, service);
                        },
                        tooltip: 'Delete Service',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Service Packages',
              style: AppTextStyles.titleMedium,
            ),
          ),
          Expanded(
            child: service.servicePackages.isEmpty
                ? Center(
                    child: Text(
                      'No packages available for this service',
                      style:
                          AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: service.servicePackages.length,
                    itemBuilder: (context, index) {
                      return _buildPackageItem(service.servicePackages[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableServiceName(ServiceDetail service) {
    final TextEditingController controller =
        TextEditingController(text: service.name);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          child: CommonTextField(
            controller: controller,
            textStyle: AppTextStyles.headlineSmall,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.check_circle,
            color: AppColors.primary,
          ),
          onPressed: () async {
            await servicesRepo.updateService(
              service.id,
              ServiceReq(
                name: controller.text,
                des: '',
                isActive: service.active,
              ),
            );
            if (mounted) {
              SnackBarSuccess.showSuccess(
                  context, 'Service name updated to: ${controller.text}');
            }
          },
          tooltip: 'Save name change',
        ),
      ],
    );
  }

  Widget _buildPackageItem(ServicePackage package) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isEditMode
                  ? _buildEditablePackageName(package)
                  : Text(
                      package.name,
                      style: AppTextStyles.titleMedium,
                    ),
              Row(
                children: [
                  isEditMode
                      ? _buildEditablePackagePrice(package)
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_formatCurrency(package.basePrice)}₫',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                  if (isEditMode)
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        _showDeletePackageDialog(context, package);
                      },
                      tooltip: 'Delete Package',
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          isEditMode
              ? _buildEditablePackageDescription(package)
              : Text(
                  package.description,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                ),

          if (package.variants.isNotEmpty) const Divider(height: 32),

          // Variants
          if (package.variants.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Variants',
                      style: AppTextStyles.titleMedium,
                    ),
                    if (isEditMode)
                      TextButton.icon(
                        icon: Icon(Icons.add_circle,
                            size: 16, color: AppColors.primary),
                        label: const Text('Add Variant'),
                        onPressed: () {
                          _showAddVariantDialog(context, package);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                ...package.variants
                    .map((variant) => _buildVariantItem(variant, package)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEditablePackageName(ServicePackage package) {
    final TextEditingController controller =
        TextEditingController(text: package.name);

    return SizedBox(
      width: 120,
      height: 40,
      child: CommonTextField(
        controller: controller,
        textStyle: AppTextStyles.titleMedium,
        suffixIcon: const Icon(Icons.check, size: 16),
        onSuffixPressed: () async {
          await servicesRepo.updatePackage(
              package.id,
              PackageReq(
                packageName: controller.text,
                packageDescription: package.description,
                packagePrice: package.basePrice.toDouble(),
              ));
          if (mounted) {
            SnackBarSuccess.showSuccess(
                context, 'Package name updated to: ${controller.text}');
          }
        },
      ),
    );
  }

  Widget _buildEditablePackagePrice(ServicePackage package) {
    final TextEditingController controller =
        TextEditingController(text: package.basePrice.toString());

    return SizedBox(
        width: 120,
        child: CommonTextField(
          controller: controller,
          textStyle: AppTextStyles.titleSmall,
          suffixText: '₫',
          keyboardType: TextInputType.number,
          suffixIcon: const Icon(Icons.check, size: 16),
          onSuffixPressed: () async {
            double? newPrice = double.tryParse(controller.text);
            if (newPrice != null) {
              await servicesRepo.updatePackage(
                  package.id,
                  PackageReq(
                    packageName: package.name,
                    packageDescription: package.description,
                    packagePrice: newPrice,
                  ));
              if (mounted) {
                SnackBarSuccess.showSuccess(context,
                    'Package price updated to: ${_formatCurrency(newPrice)}₫');
              }
            }
          },
        ));
  }

  Widget _buildEditablePackageDescription(ServicePackage package) {
    final TextEditingController controller =
        TextEditingController(text: package.description);

    return Row(
      children: [
        Expanded(
          child: CommonTextField(
            controller: controller,
            textStyle: AppTextStyles.bodyMedium,
            hintText: 'Package description',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, size: 16),
          onPressed: () async {
            await servicesRepo.updatePackage(
                package.id,
                PackageReq(
                  packageName: package.name,
                  packageDescription: controller.text,
                  packagePrice: package.basePrice,
                ));
            if (mounted) {
              SnackBarSuccess.showSuccess(
                  context, 'Package description updated');
            }
          },
        ),
      ],
    );
  }

  Widget _buildVariantItem(PackageVariant variant, ServicePackage package) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(
            Icons.circle,
            size: 6,
            color: Colors.black54,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: isEditMode
                ? _buildEditableVariant(variant)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        variant.name,
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (variant.description != null)
                        Text(
                          variant.description!,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.grey),
                        ),
                    ],
                  ),
          ),
          isEditMode
              ? _buildEditableVariantPrice(variant)
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '+ ${_formatCurrency(variant.additionalPrice!)}₫',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
          if (isEditMode)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 18,
              ),
              onPressed: () {
                _showDeleteVariantDialog(context, variant, package);
              },
              tooltip: 'Delete Variant',
            ),
        ],
      ),
    );
  }

  Widget _buildEditableVariant(PackageVariant variant) {
    final TextEditingController nameController =
        TextEditingController(text: variant.name);
    final TextEditingController descController =
        TextEditingController(text: variant.description);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
                width: 150,
                child: CommonTextField(
                  controller: nameController,
                  textStyle: AppTextStyles.bodyMedium,
                  hintText: 'Variant Name',
                )),
            IconButton(
              icon: const Icon(Icons.check, size: 16),
              onPressed: () async {
                await servicesRepo.updateVariant(
                  variant.id,
                  Variant(
                    variantName: nameController.text,
                    variantDes: variant.description ?? '',
                    additionalPrice: variant.additionalPrice ?? 0.0,
                  ),
                );
                if (mounted) {
                  SnackBarSuccess.showSuccess(context,
                      'Variant name updated to: ${nameController.text}');
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (variant.description != null)
          Row(
            children: [
              SizedBox(
                width: 150,
                child: CommonTextField(
                  controller: descController,
                  textStyle: AppTextStyles.bodySmall,
                  hintText: 'Description',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.check, size: 16),
                onPressed: () async {
                  await servicesRepo.updateVariant(
                    variant.id,
                    Variant(
                      variantName: variant.name,
                      variantDes: descController.text,
                      additionalPrice: variant.additionalPrice ?? 0.0,
                    ),
                  );
                  if (mounted) {
                    SnackBarSuccess.showSuccess(
                        context, 'Variant description updated');
                  }
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildEditableVariantPrice(PackageVariant variant) {
    final TextEditingController controller =
        TextEditingController(text: variant.additionalPrice.toString());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 32,
          child: CommonTextField(
            controller: controller,
            textStyle: AppTextStyles.bodyMedium,
            suffixText: '+ ₫',
            keyboardType: TextInputType.number,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, size: 16),
          onPressed: () async {
            await servicesRepo.updateVariant(
              variant.id,
              Variant(
                variantName: variant.name,
                variantDes: variant.description ?? '',
                additionalPrice: controller.text.isNotEmpty
                    ? double.tryParse(controller.text) ?? 0.0
                    : 0.0,
              ),
            );
            if (mounted) {
              SnackBarSuccess.showSuccess(context,
                  'Variant price updated to: ${_formatCurrency(double.tryParse(controller.text) ?? 0.0)}₫');
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaginationControls(int pageNo, int pageSize, int totalPage) {
    // If there's only one page, don't show pagination
    if (totalPage <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: pageNo > 0
                ? () {
                    _servicesBloc.add(ChangePage(pageNo - 1));
                  }
                : null,
            color: pageNo > 0 ? AppColors.primary : Colors.grey,
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
              'Page ${pageNo + 1} of $totalPage',
              style: AppTextStyles.bodyMedium,
            ),
          ),

          // Next page button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: pageNo < totalPage - 1
                ? () {
                    _servicesBloc.add(ChangePage(pageNo + 1));
                  }
                : null,
            color: pageNo < totalPage - 1 ? AppColors.primary : Colors.grey,
          ),

          // Items per page dropdown
          const SizedBox(width: 16),
          Text('Items per page:', style: AppTextStyles.bodySmall),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: pageSize,
            items: [10, 20, 50, 100].map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value', style: AppTextStyles.bodyMedium),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null && value != pageSize) {
                _servicesBloc.add(ChangeItemsPerPage(value));
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

  String _formatCurrency(double amount) {
    // Format the number with commas as thousands separators
    final String formatted = amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return formatted;
  }

  // Dialog methods for editing, adding, and deleting
  void _showEditCategoryDialog(BuildContext context, ServiceCategory category) {
    final TextEditingController nameController =
        TextEditingController(text: category.name);

    bool isActive = category.active;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: const Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldDialog(
                controller: nameController,
                labelText: 'Category Name',
                labelStyle: AppTextStyles.titleSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status:'),
                const SizedBox(width: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<bool>(
                      value: isActive,
                      dropdownColor: AppColors.neutral,
                      style: AppTextStyles.bodyMedium,
                      items: const [
                        DropdownMenuItem(
                          value: true,
                          child: Text('Active'),
                        ),
                        DropdownMenuItem(
                          value: false,
                          child: Text('Inactive'),
                        ),
                      ],
                      onChanged: (bool? value) {
                        setState(() {
                          isActive = value!;
                        });
                        logger.log('Category status changed to: $isActive');
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              await servicesRepo.updateCategory(
                category.id,
                CategoryReq(
                  categoryName: nameController.text,
                  isActive: isActive,
                ),
              );
              SnackBarSuccess.showSuccess(
                  context, 'Category updated to: ${nameController.text}');
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showToggleCategoryStatusDialog(
      BuildContext context, ServiceCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: Text('${category.active ? 'Deactivate' : 'Activate'} Category'),
        content: Text(
            'Are you sure you want to ${category.active ? 'deactivate' : 'activate'} "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  category.active ? AppColors.secondary : AppColors.accent,
            ),
            onPressed: () async {
              await servicesRepo.updateCategory(
                category.id,
                CategoryReq(
                  categoryName: category.name,
                  isActive: category.active ? false : true,
                ),
              );
              SnackBarSuccess.showSuccess(context,
                  'Category "${category.name}" ${category.active ? 'deactivated' : 'activated'}');

              Navigator.of(context).pop();
            },
            child: Text(
              category.active ? 'Deactivate' : 'Activate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, Service service) {
    final TextEditingController nameController =
        TextEditingController(text: service.name);
    final TextEditingController descController =
        TextEditingController(text: service.description ?? '');
    bool isActive = service.isActive;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: const Text('Edit Service'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldDialog(
                controller: nameController, labelText: 'Service Name'),
            const SizedBox(height: 16),
            TextFieldDialog(
                controller: descController, labelText: 'Description'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Status:'),
                const SizedBox(width: 16),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Transform.scale(
                      scale: 0.6,
                      child: Switch(
                        value: isActive,
                        activeColor: AppColors.accent,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                          logger.log('Service status changed to: $isActive');
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              await servicesRepo.updateService(
                service.id,
                ServiceReq(
                  name: nameController.text,
                  des: descController.text,
                  isActive: isActive,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service updated to: ${nameController.text}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showToggleServiceStatusDialog(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: Text('${service.isActive ? 'Deactivate' : 'Activate'} Service'),
        content: Text(
            'Are you sure you want to ${service.isActive ? 'deactivate' : 'activate'} "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  service.isActive ? AppColors.secondary : AppColors.accent,
            ),
            onPressed: () async {
              await servicesRepo.updateService(
                service.id,
                ServiceReq(
                  name: service.name,
                  des: service.description ?? '',
                  isActive: !service.isActive,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Service "${service.name}" ${service.isActive ? 'deactivated' : 'activated'}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            child: Text(
              service.isActive ? 'Deactivate' : 'Activate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showToggleDetailedServiceStatusDialog(
      BuildContext context, ServiceDetail service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: Text('${service.active ? 'Deactivate' : 'Activate'} Service'),
        content: Text(
            'Are you sure you want to ${service.active ? 'deactivate' : 'activate'} "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  service.active ? AppColors.secondary : AppColors.accent,
            ),
            onPressed: () async {
              await servicesRepo.updateService(
                service.id,
                ServiceReq(
                  name: service.name,
                  des: '',
                  isActive: !service.active,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Service "${service.name}" ${service.active ? 'deactivated' : 'activated'}'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            child: Text(
              service.active ? 'Deactivate' : 'Activate',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteServiceDialog(BuildContext context, ServiceDetail service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: const Text('Delete Service'),
        content: Text(
            'Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await servicesRepo.deleteService(service.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service "${service.name}" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
              _servicesBloc.add(FetchServiceCategories());
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddServiceDialog(
      BuildContext context, List<ServiceCategory> category) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    String? selectedCategory;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: const Text('Add New Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldDialog(
                  controller: nameController, labelText: 'Service Name'),
              const SizedBox(height: 16),
              TextFieldDialog(
                controller: descController,
                labelText: 'Description',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: AppTextStyles.bodyMedium,
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                dropdownColor: AppColors.neutral,
                style: AppTextStyles.bodyMedium,
                items: category.map((ServiceCategory cat) {
                  return DropdownMenuItem<String>(
                    value: cat.id.toString(),
                    child: Text(cat.name, style: AppTextStyles.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value;
                  logger.log('Selected category: $selectedCategory');
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Active:'),
                  StatefulBuilder(builder: (context, setState) {
                    return Transform.scale(
                      scale: 0.6,
                      child: Switch(
                        value: isActive,
                        activeColor: AppColors.accent,
                        onChanged: (value) {
                          setState(() {
                            isActive = value;
                          });
                          logger.log(
                              'Service active status changed to: $isActive');
                        },
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty && selectedCategory != null) {
                await servicesRepo.addService(
                  int.parse(selectedCategory!),
                  ServiceReq(
                    name: nameController.text,
                    des: descController.text,
                    isActive: isActive,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service "${nameController.text}" created'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
                // Refresh service categories
                _servicesBloc.add(FetchServiceCategories());
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeletePackageDialog(BuildContext context, ServicePackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: const Text('Delete Package'),
        content:
            Text('Are you sure you want to delete package "${package.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await servicesRepo.deletePackage(package.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Package "${package.name}" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddPackageDialog(BuildContext context, int serviceId) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: const Text('Add New Package'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldDialog(
                  controller: nameController, labelText: 'Package Name'),
              const SizedBox(height: 16),
              TextFieldDialog(
                controller: descController,
                labelText: 'Description',
              ),
              const SizedBox(height: 16),
              TextFieldDialog(
                controller: priceController,
                labelText: 'Base Price (₫)',
                suffixText: '₫',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  int.tryParse(priceController.text) != null) {
                await servicesRepo.addPackage(
                  serviceId,
                  PackageReq(
                    packageName: nameController.text,
                    packageDescription: descController.text,
                    packagePrice: double.parse(priceController.text),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Package "${nameController.text}" created'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();

                // Refresh service details
                if (selectedService != null) {
                  _servicesBloc.add(FetchServiceDetail(selectedService!.id));
                }
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddVariantDialog(BuildContext context, ServicePackage package) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral,
        title: const Text('Add New Variant'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'For package: ${package.name}',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFieldDialog(
                controller: nameController,
                labelText: 'Variant Name',
              ),
              const SizedBox(height: 16),
              TextFieldDialog(
                controller: descController,
                labelText: 'Description',
              ),
              const SizedBox(height: 16),
              TextFieldDialog(
                controller: priceController,
                labelText: 'Additional Price (₫)',
                suffixText: '₫',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  priceController.text.isNotEmpty &&
                  int.tryParse(priceController.text) != null) {
                await servicesRepo.addVariant(
                  package.id,
                  Variant(
                    variantName: nameController.text,
                    variantDes: descController.text,
                    additionalPrice: double.parse(priceController.text),
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Variant "${nameController.text}" added to package "${package.name}"'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();

                // Refresh service details
                if (selectedService != null) {
                  _servicesBloc.add(FetchServiceDetail(selectedService!.id));
                }
              }
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteVariantDialog(
      BuildContext context, PackageVariant variant, ServicePackage package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Variant'),
        content: Text(
            'Are you sure you want to delete variant "${variant.name}" from package "${package.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.text)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await servicesRepo.deleteVariant(variant.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Variant "${variant.name}" deleted'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
