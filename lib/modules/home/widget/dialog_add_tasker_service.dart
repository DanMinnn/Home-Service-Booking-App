import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/widget/show_snack_bar.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/styles_text.dart';
import '../../services/bloc/service_bloc.dart';
import '../../services/bloc/service_event.dart';
import '../../services/bloc/service_state.dart';
import '../../services/model/tasker_service_req.dart';
import '../../services/repo/service_repo.dart';

class DialogAddTaskerService extends StatelessWidget {
  const DialogAddTaskerService({super.key});

  final int maxSelectedServices = 3;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Map<int, String>> selectedServices = ValueNotifier({});

    return BlocProvider(
      create: (context) =>
          ServiceBloc(ServiceRepo())..add(GetAllServiceEvent()),
      child: BlocBuilder<ServiceBloc, ServiceState>(
        builder: (context, state) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Which service do you want to subscribe to?',
                      style: AppTextStyles.headline4
                          .copyWith(color: AppColors.dodgerBlue),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (state is ServiceLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (state is ServiceError)
                      Center(
                        child: Text(
                          'Something went wrong',
                          style: AppTextStyles.headline4
                              .copyWith(color: AppColors.alertFailed),
                        ),
                      )
                    else if (state is ServiceLoaded)
                      // checkbox list
                      Flexible(
                        child: ValueListenableBuilder<Map<int, String>>(
                          valueListenable: selectedServices,
                          builder: (context, selected, _) => ListView.builder(
                            shrinkWrap: true,
                            itemCount: state.services.length,
                            itemBuilder: (context, index) {
                              final service = state.services[index];
                              final serviceName = service.name;
                              final serviceId = service.id;
                              final isSelected =
                                  selected.containsKey(serviceId);
                              return GestureDetector(
                                onTap: () {
                                  if (isSelected) {
                                    final newMap =
                                        Map<int, String>.from(selected);
                                    newMap.remove(serviceId);
                                    selectedServices.value = newMap;
                                  } else if (selected.length <
                                      maxSelectedServices) {
                                    final newMap =
                                        Map<int, String>.from(selected);
                                    newMap[serviceId] = serviceName;
                                    selectedServices.value = newMap;
                                  } else {
                                    ShowSnackBar.showError(context,
                                        'You can only select up to $maxSelectedServices services');
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.shade100
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (_) {
                                          if (isSelected) {
                                            final newMap =
                                                Map<int, String>.from(selected);
                                            newMap.remove(serviceId);
                                            selectedServices.value = newMap;
                                          } else if (selected.length <
                                              maxSelectedServices) {
                                            final newMap =
                                                Map<int, String>.from(selected);
                                            newMap[serviceId] = serviceName;
                                            selectedServices.value = newMap;
                                          } else {
                                            ShowSnackBar.showError(context,
                                                'You can only select up to $maxSelectedServices services');
                                          }
                                        },
                                        checkColor: AppColors.white,
                                        activeColor: AppColors.primary,
                                      ),
                                      Expanded(child: Text(serviceName)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    // Show selection counter
                    ValueListenableBuilder<Map<int, String>>(
                      valueListenable: selectedServices,
                      builder: (context, selected, _) => Text(
                        '${selected.length}/$maxSelectedServices services selected',
                        style: AppTextStyles.headline5.copyWith(
                          color: selected.length >= maxSelectedServices
                              ? Colors.red
                              : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          final selected = selectedServices.value;
                          if (selected.isEmpty) {
                            ShowSnackBar.showError(
                                context, 'Please select at least one service');
                            return;
                          } else {
                            context
                                .read<ServiceBloc>()
                                .add(AddTaskerServiceEvent(
                                  req: TaskerServiceReq(
                                      taskerId: 24,
                                      serviceIds: selected.keys.toList()),
                                ));
                            ShowSnackBar.showSuccess(
                                context,
                                'You have successfully registered for the service.',
                                'Well done!');
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
