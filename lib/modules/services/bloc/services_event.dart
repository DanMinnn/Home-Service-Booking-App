import 'package:equatable/equatable.dart';

abstract class ServicesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchServiceCategories extends ServicesEvent {
  final int pageNo;
  final int pageSize;

  FetchServiceCategories({
    this.pageNo = 0,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [pageNo, pageSize];
}

class FetchServiceDetail extends ServicesEvent {
  final int serviceId;

  FetchServiceDetail(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

class ChangePage extends ServicesEvent {
  final int pageNo;

  ChangePage(this.pageNo);

  @override
  List<Object?> get props => [pageNo];
}

class ChangeItemsPerPage extends ServicesEvent {
  final int pageSize;

  ChangeItemsPerPage(this.pageSize);

  @override
  List<Object?> get props => [pageSize];
}
