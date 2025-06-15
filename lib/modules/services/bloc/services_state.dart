import 'package:equatable/equatable.dart';

import '../models/services.dart';

abstract class ServicesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {}

class ServicesLoading extends ServicesState {}

class ServicesLoadFailure extends ServicesState {
  final String errorMessage;

  ServicesLoadFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class ServiceCategoriesLoaded extends ServicesState {
  final List<ServiceCategory> categories;
  final int pageNo;
  final int pageSize;
  final int totalPage;

  ServiceCategoriesLoaded({
    required this.categories,
    required this.pageNo,
    required this.pageSize,
    required this.totalPage,
  });

  @override
  List<Object?> get props => [categories, pageNo, pageSize, totalPage];
}

class ServiceDetailLoaded extends ServicesState {
  final ServiceDetail serviceDetail;
  final List<ServiceCategory> categories;
  final int pageNo;
  final int pageSize;
  final int totalPage;

  ServiceDetailLoaded({
    required this.serviceDetail,
    required this.categories,
    required this.pageNo,
    required this.pageSize,
    required this.totalPage,
  });

  @override
  List<Object?> get props =>
      [serviceDetail, categories, pageNo, pageSize, totalPage];
}
