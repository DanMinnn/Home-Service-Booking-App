import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_service_admin/modules/bookings/bloc/booking_bloc.dart';
import 'package:home_service_admin/modules/bookings/bloc/booking_event.dart';
import 'package:home_service_admin/modules/bookings/bloc/booking_state.dart';
import 'package:home_service_admin/modules/bookings/models/booking.dart';
import 'package:home_service_admin/modules/bookings/models/filter_sort_model.dart';
import 'package:home_service_admin/modules/bookings/repo/booking_repo.dart';
import 'package:home_service_admin/themes/app_assets.dart';
import 'package:home_service_admin/themes/app_colors.dart';
import 'package:home_service_admin/themes/style_text.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  BookingsPageState createState() => BookingsPageState();
}

class BookingsPageState extends State<BookingsPage> {
  final TextEditingController _customerSearchController =
      TextEditingController();
  final TextEditingController _taskerSearchController = TextEditingController();
  late BookingBloc _bookingBloc;

  @override
  void initState() {
    super.initState();
    _bookingBloc = BookingBloc(bookingRepo: BookingRepo());
    _bookingBloc.add(FetchBookings());
  }

  @override
  void dispose() {
    _customerSearchController.dispose();
    _taskerSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FA),
      body: BlocProvider.value(
        value: _bookingBloc,
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            return Row(
              children: [
                // Main Content
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Booking List',
                                  style: AppTextStyles.headlineMedium,
                                ),
                                _buildFilterSection(state),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Filter Chips
                            _buildActiveFilters(state),

                            const SizedBox(height: 16),

                            // Table Header
                            _buildTableHeader(state),

                            const SizedBox(height: 8),

                            // Booking List
                            Expanded(
                              flex: 2,
                              child: state is BookingLoading
                                  ? const Center(
                                      child: CircularProgressIndicator())
                                  : state is BookingLoaded
                                      ? _buildBookingList(state.bookings)
                                      : state is BookingError
                                          ? Center(
                                              child: Text(
                                              'Something went wrong. Check your connection',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                color: Colors.red,
                                              ),
                                            ))
                                          : const Center(
                                              child: Text('No bookings found')),
                            ),

                            // Pagination controls
                            _buildPaginationControls(state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterSection(BookingState state) {
    return Row(
      children: [
        // Filter button
        ElevatedButton.icon(
          onPressed: () {
            _showFilterDialog(state);
          },
          icon: const Icon(
            Icons.filter_list,
            color: Colors.white,
          ),
          label: const Text('Filter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),

        // Reset button
        if (state.filterModel.customerSearch != null ||
            state.filterModel.taskerSearch != null ||
            state.filterModel.selectedDate != null ||
            state.filterModel.status != null)
          OutlinedButton(
            onPressed: () {
              _bookingBloc.add(ResetFilters());
            },
            child: const Text('Reset Filters'),
          ),
      ],
    );
  }

  Widget _buildActiveFilters(BookingState state) {
    final List<Widget> filterChips = [];

    if (state.filterModel.customerSearch != null) {
      filterChips.add(_buildFilterChip(
        'Customer: ${state.filterModel.customerSearch}',
        () {
          final updatedFilter =
              state.filterModel.copyWith(clearCustomerSearch: true);
          _bookingBloc.add(ApplyFilter(updatedFilter));
        },
      ));
    }

    if (state.filterModel.taskerSearch != null) {
      filterChips.add(_buildFilterChip(
        'Tasker: ${state.filterModel.taskerSearch}',
        () {
          final updatedFilter =
              state.filterModel.copyWith(clearTaskerSearch: true);
          _bookingBloc.add(ApplyFilter(updatedFilter));
        },
      ));
    }

    if (state.filterModel.selectedDate != null) {
      final dateFormatter = DateFormat('yyyy-MM-dd');
      filterChips.add(_buildFilterChip(
        'Date: ${dateFormatter.format(state.filterModel.selectedDate!)}',
        () {
          final updatedFilter =
              state.filterModel.copyWith(clearSelectedDate: true);
          _bookingBloc.add(ApplyFilter(updatedFilter));
        },
      ));
    }

    if (state.filterModel.status != null) {
      filterChips.add(_buildFilterChip(
        'Status: ${state.filterModel.status}',
        () {
          final updatedFilter = state.filterModel.copyWith(clearStatus: true);
          _bookingBloc.add(ApplyFilter(updatedFilter));
        },
      ));
    }

    return filterChips.isEmpty
        ? const SizedBox.shrink()
        : Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filterChips,
          );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Chip(
      label: Text(label),
      onDeleted: onRemove,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      deleteIconColor: AppColors.primary,
    );
  }

  Widget _buildTableHeader(BookingState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              'Service',
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildSortableHeader('Customer', 'customer', state),
          ),
          Expanded(
            flex: 1,
            child: _buildSortableHeader('Tasker', 'tasker', state),
          ),
          Expanded(
            flex: 1,
            child: _buildSortableHeader('Date', 'date', state),
          ),
          Expanded(
            flex: 1,
            child: _buildSortableHeader('Start Time', 'startTime', state),
          ),
          Expanded(
            flex: 1,
            child: _buildSortableHeader('End Time', 'endTime', state),
          ),
          Expanded(
            flex: 1,
            child: _buildSortableHeader('Address', 'address', state),
          ),
          Expanded(
            flex: 1,
            child: _buildSortableHeader(
              'Status',
              'status',
              state,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSortableHeader(String title, String field, BookingState state,
      {TextAlign? textAlign}) {
    final sortModel = state.sortModel;
    final isSorted = sortModel.field == field;
    final sortOrder = isSorted ? sortModel.order : SortOrder.none;

    Widget? sortIcon;
    if (sortOrder == SortOrder.ascending) {
      sortIcon = const Icon(Icons.arrow_upward, size: 16);
    } else if (sortOrder == SortOrder.descending) {
      sortIcon = const Icon(Icons.arrow_downward, size: 16);
    }

    return InkWell(
      onTap: () {
        _bookingBloc.add(ApplySort(field));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium,
            textAlign: textAlign,
          ),
          if (sortIcon != null) sortIcon,
        ],
      ),
    );
  }

  Widget _buildBookingList(List<Booking> bookings) {
    return bookings.isEmpty
        ? const Center(child: Text('No bookings found'))
        : ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingRow(
                booking.service ?? 'Unknown',
                booking.customer ?? 'Unknown',
                booking.tasker ?? 'Waiting...',
                booking.date ?? '2023-10-01',
                booking.startTime ?? '10:00 AM',
                booking.endTime ?? '12:00 PM',
                booking.status ?? 'Pending',
                booking.address ?? 'No address provided',
              );
            },
          );
  }

  Widget _buildBookingRow(
      String service,
      String customer,
      String tasker,
      String date,
      String startTime,
      String endTime,
      String status,
      String address) {
    return Container(
      width: MediaQuery.of(context).size.width - 300,
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(service, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Text(customer, style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Text(status == 'Pending' ? 'Waiting...' : tasker,
                style: AppTextStyles.bodyMedium),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                    child: Image.asset(AppAssetsIcons.calendarDaysIc)),
                const SizedBox(width: 8),
                Text(
                  date,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              startTime,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              endTime,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              address,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.neutral,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(
              width: 40, child: Icon(Icons.more_horiz, color: AppColors.text)),
        ],
      ),
    );
  }

  void _showFilterDialog(BookingState state) {
    showDialog(
      context: context,
      builder: (context) {
        _customerSearchController.text = state.filterModel.customerSearch ?? '';
        _taskerSearchController.text = state.filterModel.taskerSearch ?? '';

        DateTime? selectedDate = state.filterModel.selectedDate;
        String? selectedStatus = state.filterModel.status;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.neutral,
              title: Text(
                'Filter Bookings',
                style: AppTextStyles.titleMedium,
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Customer search
                    TextFormField(
                      controller: _customerSearchController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name',
                        labelStyle: AppTextStyles.bodyMedium,
                        prefixIcon: Icon(
                          Icons.person_search,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tasker search
                    TextFormField(
                      controller: _taskerSearchController,
                      decoration: InputDecoration(
                        focusColor: AppColors.primary,
                        labelText: 'Tasker Name',
                        labelStyle: AppTextStyles.bodyMedium,
                        prefixIcon:
                            Icon(Icons.person_search, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date picker
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: AppColors.primary,
                                hintColor: AppColors.primary,
                                colorScheme: ColorScheme.light(
                                    primary: AppColors.primary),
                                buttonTheme: ButtonThemeData(
                                    textTheme: ButtonTextTheme.primary),
                              ),
                              child: child!,
                            );
                          },
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          focusColor: AppColors.primary,
                          labelText: 'Date',
                          labelStyle: AppTextStyles.bodyMedium,
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                        ),
                        child: Text(
                          selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                              : 'Select Date',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status dropdown
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        labelStyle: AppTextStyles.bodyMedium,
                        prefixIcon: Icon(Icons.flag, color: AppColors.primary),
                      ),
                      style: AppTextStyles.bodyMedium,
                      dropdownColor: AppColors.neutral,
                      items: [
                        'Completed',
                        'Pending',
                        'Cancelled',
                        'Assigned',
                      ].map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Apply filters
                    final newFilter = BookingFilterModel(
                      customerSearch: _customerSearchController.text.isNotEmpty
                          ? _customerSearchController.text
                          : null,
                      taskerSearch: _taskerSearchController.text.isNotEmpty
                          ? _taskerSearchController.text
                          : null,
                      selectedDate: selectedDate,
                      status: selectedStatus,
                    );

                    _bookingBloc.add(ApplyFilter(newFilter));
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Apply Filters',
                    style: AppTextStyles.titleSmall,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPaginationControls(BookingState state) {
    // If we don't have data yet, don't show pagination
    if (state is! BookingLoaded) {
      return const SizedBox.shrink();
    }

    final metadata = state.metadata;

    // If there's only one page, don't show pagination
    if (metadata.totalPage <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: metadata.pageNo > 0
                ? () {
                    _bookingBloc.add(ChangePage(metadata.pageNo - 1));
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
                    _bookingBloc.add(ChangePage(metadata.pageNo + 1));
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
                _bookingBloc.add(ChangeItemsPerPage(value));
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.accent;
      case 'pending':
        return AppColors.primary.withValues(alpha: 0.5);
      case 'cancelled':
        return AppColors.secondary;
      default:
        return const Color(0xFF6B7280);
    }
  }
}
